import 'dart:math';
import 'package:flutter/material.dart';

import 'package:pictolearn/models/pictogram.dart';
import 'package:pictolearn/services/pictogram_image_service.dart';
import 'package:pictolearn/services/tts_service.dart';
import 'package:pictolearn/theme/app_colors.dart';
import 'package:pictolearn/widgets/game_exit.dart';
import 'package:pictolearn/widgets/pictogram_image.dart';

/// Juego "¿Qué falta?" (memoria visual).
///
/// 1. [_Phase.memorize]: se muestran 3 o 4 pictogramas. El niño los mira
///    (puede tocar cada uno para escuchar su nombre) y toca "¡Ya los vi!".
/// 2. [_Phase.guess]: uno de los pictogramas desaparece (queda un "?") y
///    el niño elige, entre 3 opciones, cuál era el que faltaba.
/// 3. [_Phase.result]: se revela la respuesta, se dice en voz alta y a los
///    pocos segundos empieza la siguiente ronda.
enum _Phase { memorize, guess, result }

class QueFaltaScreen extends StatefulWidget {
  const QueFaltaScreen({super.key});

  @override
  State<QueFaltaScreen> createState() => _QueFaltaScreenState();
}

class _QueFaltaScreenState extends State<QueFaltaScreen> {
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color lightBlue = AppColors.lightBlue;

  static const int optionsCount = 3;
  static const int easyRounds = 4; // primeras rondas con 3 pictogramas
  static const Duration resultDelay = Duration(milliseconds: 1800);

  final TtsService _tts = TtsService(speechRate: 0.55);
  final Random _random = Random();

  int _roundsPlayed = 0;
  int _score = 0;

  _Phase _phase = _Phase.memorize;
  late List<Pictogram> _shown; // pictogramas de la ronda, en orden
  late int _missingIndex; // posición del que va a desaparecer
  late List<Pictogram> _options;
  Pictogram? _selected;

  Pictogram get _missing => _shown[_missingIndex];

  @override
  void initState() {
    super.initState();
    _loadRound();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// Arma una ronda nueva. No llama a setState: quien la use desde un
  /// evento debe envolverla en setState(_loadRound).
  void _loadRound() {
    final count = _roundsPlayed < easyRounds ? 3 : 4;

    final pool = List<Pictogram>.from(pictogramBank)..shuffle(_random);
    _shown = pool.take(count).toList();
    _missingIndex = _random.nextInt(count);

    // Distractores: pictogramas que NO están en la ronda.
    final distractors = pool.skip(count).take(optionsCount - 1).toList();
    _options = [_missing, ...distractors]..shuffle(_random);

    _selected = null;
    _phase = _Phase.memorize;

    // Descarga las imágenes de las opciones desde ya, para que no haya
    // spinners cuando llegue el momento de elegir.
    for (final p in _options) {
      _prefetch(p);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tts.speak('Mira bien los dibujos');
    });
  }

  Future<void> _prefetch(Pictogram p) async {
    final url = await PictogramImageService.fetchImageUrl(p.word);
    if (url != null && mounted) {
      precacheImage(NetworkImage(url), context);
    }
  }

  void _startGuess() {
    setState(() => _phase = _Phase.guess);
    _tts.speak('¿Qué dibujo falta?');
  }

  Future<void> _onOptionTap(Pictogram option) async {
    if (_phase != _Phase.guess) return; // evita doble toque

    final correct = option.word == _missing.word;
    setState(() {
      _selected = option;
      _phase = _Phase.result;
      if (correct) _score++;
    });

    _tts.speak(
      correct
          ? '¡Muy bien! ${_missing.translation}'
          : 'Casi. Faltaba: ${_missing.translation}',
    );

    await Future.delayed(resultDelay);
    if (!mounted) return;

    setState(() {
      _roundsPlayed++;
      _loadRound();
    });
  }

  Future<void> _confirmExit() => confirmExitGame(
        context,
        message: 'Acertaste $_score de $_roundsPlayed rondas hasta ahora.',
      );

  String get _instruction {
    switch (_phase) {
      case _Phase.memorize:
        return '¡Mira bien los dibujos!';
      case _Phase.guess:
        return '¿Qué dibujo falta?';
      case _Phase.result:
        return _selected?.word == _missing.word
            ? '¡Muy bien! Era ${_missing.translation}'
            : 'Faltaba: ${_missing.translation}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameExitScope(
      onExitRequested: _confirmExit,
      child: Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          title: const Text(
            '¿Qué falta? 🔍',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _confirmExit,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProgress(),
                const SizedBox(height: 16),
                _buildInstructionCard(),
                const SizedBox(height: 16),
                Expanded(child: _buildShownArea()),
                const SizedBox(height: 16),
                _buildBottomArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ronda ${_roundsPlayed + 1}',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        Text(
          '⭐ $_score',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        _instruction,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue),
      ),
    );
  }

  /// Los pictogramas de la ronda. Se adaptan al espacio disponible para
  /// que 3 o 4 tarjetas siempre quepan sin hacer scroll.
  Widget _buildShownArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final size = min(
          160.0,
          min((constraints.maxWidth - spacing) / 2,
              (constraints.maxHeight - spacing) / 2),
        );

        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var i = 0; i < _shown.length; i++)
                SizedBox(width: size, height: size, child: _buildSlot(i)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlot(int index) {
    final pictogram = _shown[index];
    final isMissingSlot = index == _missingIndex;

    // Durante la adivinanza, el espacio del que falta muestra un "?".
    if (isMissingSlot && _phase == _Phase.guess) {
      return _Tile(
        fillColor: Colors.white.withOpacity(0.6),
        borderColor: primaryBlue,
        child: const Center(
          child: Icon(Icons.question_mark_rounded, size: 64, color: primaryBlue),
        ),
      );
    }

    // Al revelar la respuesta, el que faltaba aparece con borde verde.
    final revealed = isMissingSlot && _phase == _Phase.result;

    return _Tile(
      borderColor: revealed ? Colors.green : Colors.transparent,
      // Solo se puede tocar para escuchar mientras se memoriza.
      onTap: _phase == _Phase.memorize
          ? () => _tts.speak(pictogram.translation)
          : null,
      child: _TileImage(pictogram: pictogram),
    );
  }

  Widget _buildBottomArea() {
    switch (_phase) {
      case _Phase.memorize:
        return SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _startGuess,
            child: const Text(
              '¡Ya los vi! 👀',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        );

      case _Phase.guess:
      case _Phase.result:
        return SizedBox(
          height: 120,
          child: Row(
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _buildOption(_options[i])),
              ],
            ],
          ),
        );
    }
  }

  Widget _buildOption(Pictogram option) {
    Color border = Colors.transparent;
    IconData? badge;
    Color badgeColor = Colors.green;

    if (_phase == _Phase.result) {
      if (option.word == _missing.word) {
        // La respuesta correcta siempre se marca en verde.
        border = Colors.green;
        badge = Icons.check_circle;
      } else if (option.word == _selected?.word) {
        border = Colors.red;
        badge = Icons.cancel;
        badgeColor = Colors.red;
      }
    }

    return _Tile(
      borderColor: border,
      onTap: () => _onOptionTap(option),
      child: Stack(
        children: [
          _TileImage(pictogram: option),
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(badge, color: badgeColor, size: 28),
            ),
        ],
      ),
    );
  }
}

/// Tarjeta blanca redondeada con borde de feedback (verde/rojo).
class _Tile extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color fillColor;
  final VoidCallback? onTap;

  const _Tile({
    required this.child,
    this.borderColor = Colors.transparent,
    this.fillColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: primaryBlueShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  static const Color primaryBlueShadow = Color(0x402196F3);
}

/// Imagen del pictograma que se ajusta al tamaño de su tarjeta; el ícono
/// de respaldo escala con ella.
class _TileImage extends StatelessWidget {
  final Pictogram pictogram;

  const _TileImage({required this.pictogram});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        return PictogramImage(
          pictogram: pictogram,
          fallbackIconSize: side.isFinite ? side * 0.7 : 80,
        );
      },
    );
  }
}
