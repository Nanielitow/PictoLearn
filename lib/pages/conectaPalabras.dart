import 'dart:math';
import 'package:flutter/material.dart';

import 'package:pictolearn/models/pictogram.dart';
import 'package:pictolearn/services/tts_service.dart';
import 'package:pictolearn/theme/app_colors.dart';
import 'package:pictolearn/widgets/game_exit.dart';
import 'package:pictolearn/widgets/game_tile.dart';

/// Juego "¡Conecta palabras!".
///
/// A la izquierda hay 4 pictogramas y a la derecha las 4 palabras en otro
/// orden. El niño arrastra cada palabra hasta su dibujo. Al tocar una
/// palabra (sin arrastrar) se dice en voz alta, para quienes aún no leen.
///
/// - Acierto: la palabra se "pega" en el dibujo y se dice en voz alta.
/// - Error: el dibujo parpadea en rojo y la palabra vuelve a su lugar.
/// - Al conectar las 4 se pasa solo a otra ronda. Una ronda sin errores
///   da una estrella.
class ConectaPalabrasScreen extends StatefulWidget {
  const ConectaPalabrasScreen({super.key});

  @override
  State<ConectaPalabrasScreen> createState() => _ConectaPalabrasScreenState();
}

class _ConectaPalabrasScreenState extends State<ConectaPalabrasScreen> {
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color lightBlue = AppColors.lightBlue;

  static const int pairsPerRound = 4;
  static const double gap = 12;
  static const Duration wrongFlash = Duration(milliseconds: 600);
  static const Duration nextRoundDelay = Duration(milliseconds: 2000);

  final TtsService _tts = TtsService(speechRate: 0.55);
  final Random _random = Random();

  int _roundsDone = 0;
  int _stars = 0; // rondas perfectas (sin errores)
  int _mistakes = 0; // errores de la ronda actual

  late List<Pictogram> _pictures; // columna izquierda
  late List<Pictogram> _words; // columna derecha (otro orden)
  final Set<String> _matched = {}; // claves `word` ya conectadas
  String? _wrongWord; // dibujo que parpadea en rojo
  bool _roundComplete = false;

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

  /// Arma una ronda nueva. No llama a setState: desde un evento debe
  /// envolverse en setState(_loadRound).
  void _loadRound() {
    final pool = List<Pictogram>.from(pictogramBank)..shuffle(_random);
    _pictures = pool.take(pairsPerRound).toList();

    // Las palabras salen en un orden distinto al de los dibujos.
    _words = List<Pictogram>.from(_pictures);
    do {
      _words.shuffle(_random);
    } while (_sameOrder(_pictures, _words));

    _matched.clear();
    _wrongWord = null;
    _mistakes = 0;
    _roundComplete = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tts.speak('Arrastra cada palabra a su dibujo');
    });
  }

  bool _sameOrder(List<Pictogram> a, List<Pictogram> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].word != b[i].word) return false;
    }
    return true;
  }

  void _onDrop(Pictogram target, Pictogram dragged) {
    if (_roundComplete || _matched.contains(target.word)) return;

    if (dragged.word == target.word) {
      setState(() => _matched.add(target.word));
      if (_matched.length == _pictures.length) {
        _finishRound(target);
      } else {
        _tts.speak(target.translation);
      }
    } else {
      setState(() {
        _mistakes++;
        _wrongWord = target.word;
      });
      _tts.speak('Inténtalo de nuevo');
      Future.delayed(wrongFlash, () {
        if (mounted && _wrongWord == target.word) {
          setState(() => _wrongWord = null);
        }
      });
    }
  }

  Future<void> _finishRound(Pictogram lastMatched) async {
    setState(() {
      _roundComplete = true;
      if (_mistakes == 0) _stars++;
    });
    _tts.speak('${lastMatched.translation}. ¡Muy bien!');

    await Future.delayed(nextRoundDelay);
    if (!mounted) return;

    setState(() {
      _roundsDone++;
      _loadRound();
    });
  }

  Future<void> _confirmExit() => confirmExitGame(
        context,
        message: 'Conseguiste $_stars ⭐ en $_roundsDone rondas hasta ahora.',
      );

  @override
  Widget build(BuildContext context) {
    return GameExitScope(
      onExitRequested: _confirmExit,
      child: Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          title: const Text(
            '¡Conecta palabras! 🔗',
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
                const SizedBox(height: 12),
                _buildInstructionCard(),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildPicturesColumn()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildWordsColumn()),
                    ],
                  ),
                ),
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
          'Ronda ${_roundsDone + 1}',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        Text(
          '⭐ $_stars',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
        _roundComplete
            ? '¡Muy bien! 🎉'
            : 'Arrastra cada palabra a su dibujo 👉',
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
      ),
    );
  }

  // ---------------------------------------------------------------- dibujos

  Widget _buildPicturesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _pictures.length; i++) ...[
          if (i > 0) const SizedBox(height: gap),
          Expanded(child: _buildPictureTarget(_pictures[i])),
        ],
      ],
    );
  }

  Widget _buildPictureTarget(Pictogram p) {
    final matched = _matched.contains(p.word);
    final wrong = _wrongWord == p.word;

    return DragTarget<Pictogram>(
      onWillAcceptWithDetails: (_) => !matched && !_roundComplete,
      onAcceptWithDetails: (details) => _onDrop(p, details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;

        Color border = Colors.transparent;
        if (matched) {
          border = Colors.green;
        } else if (wrong) {
          border = Colors.red;
        } else if (hovering) {
          border = primaryBlue;
        }

        return GameTile(
          borderColor: border,
          fillColor: hovering ? const Color(0xFFE3F2FD) : Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Expanded(child: GameTileImage(pictogram: p)),
                  // Una vez conectada, la palabra queda escrita bajo el dibujo.
                  if (matched)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        p.translation,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              if (matched)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.check_circle, color: Colors.green, size: 26),
                ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------- palabras

  Widget _buildWordsColumn() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tamaño de cada ficha: lo necesita el "feedback" del arrastre,
        // que flota fuera del árbol y no hereda restricciones.
        final chipHeight =
            (constraints.maxHeight - gap * (_words.length - 1)) / _words.length;
        final chipWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _words.length; i++) ...[
              if (i > 0) const SizedBox(height: gap),
              Expanded(
                child: _buildWordSlot(_words[i], chipWidth, chipHeight),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildWordSlot(Pictogram p, double width, double height) {
    // Ya conectada: su ficha se fue al dibujo, queda el hueco vacío
    // para que las demás no se muevan de lugar.
    if (_matched.contains(p.word)) return const SizedBox.shrink();

    return Draggable<Pictogram>(
      data: p,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.08,
          child: SizedBox(width: width, height: height, child: _chip(p)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: _chip(p)),
      child: GestureDetector(
        onTap: () => _tts.speak(p.translation),
        child: _chip(p),
      ),
    );
  }

  Widget _chip(Pictogram p) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: p.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          p.translation,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}