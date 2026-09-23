import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import 'package:pictolearn/models/pictogram.dart';
import 'package:pictolearn/services/pictogram_image_service.dart';

/// Juego de "Empareja el pictograma con la palabra".
/// Se muestra (y se dice en voz alta, en inglés) una palabra, y el
/// niño debe tocar el pictograma correcto entre varias opciones.
/// Refuerza la asociación imagen-palabra-sonido (dual coding).
class MatchGameScreen extends StatefulWidget {
  const MatchGameScreen({super.key});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const int optionsPerRound = 4;

  final FlutterTts _tts = FlutterTts();
  final Random _random = Random();

  late List<Pictogram> _queue; // cola de palabras pendientes en esta "vuelta"
  int _roundsPlayed = 0;
  int _score = 0;
  late Pictogram _target;
  late List<Pictogram> _options;

  // Para dar feedback visual sin bloquear el toque de otras tarjetas.
  Pictogram? _selected;
  bool? _wasCorrect;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _configureTts();
    _startGame();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.55); // un poco más rápido
    await _tts.setPitch(1.1);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _startGame() {
    _roundsPlayed = 0;
    _score = 0;
    _queue = [];
    _loadRound();
  }

  void _refillQueue() {
    final shuffled = List<Pictogram>.from(pictogramBank)..shuffle(_random);
    _queue.addAll(shuffled);
  }

  void _loadRound() {
    if (_queue.isEmpty) _refillQueue();
    _target = _queue.removeAt(0);

    // Arma las opciones: la correcta + distractores aleatorios del banco.
    final distractors = pictogramBank
        .where((p) => p.word != _target.word)
        .toList()
      ..shuffle(_random);

    _options = [_target, ...distractors.take(optionsPerRound - 1)]
      ..shuffle(_random);

    _selected = null;
    _wasCorrect = null;
    _isAnswering = false;

    setState(() {});

    // Dice la palabra en voz alta automáticamente al iniciar la ronda.
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakTarget());
  }

  Future<void> _speakTarget() async {
    await _tts.stop();
    await _tts.speak(_target.translation);
  }

  Future<void> _onOptionTap(Pictogram option) async {
    if (_isAnswering) return; // evita doble-toque mientras procesa

    final correct = option.word == _target.word;
    setState(() {
      _isAnswering = true;
      _selected = option;
      _wasCorrect = correct;
      if (correct) _score++;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    _roundsPlayed++;
    _loadRound();
  }

  Future<void> _confirmExit() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Salir del juego? 👋'),
        content: Text('Acertaste $_score de $_roundsPlayed palabras hasta ahora.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir jugando'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (exit == true && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text(
          'Empareja y aprende 🧩',
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
              const SizedBox(height: 20),
              _buildTargetCard(),
              const SizedBox(height: 28),
              Expanded(child: _buildOptionsGrid()),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        Text(
          '⭐ $_score',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
      ],
    );
  }

  Widget _buildTargetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: primaryBlue.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Text(
            _target.translation,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _speakTarget,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.volume_up, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      itemCount: _options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final option = _options[index];
        return _PictogramCard(
          pictogram: option,
          isSelected: _selected?.word == option.word,
          isCorrect: _selected?.word == option.word ? _wasCorrect : null,
          onTap: () => _onOptionTap(option),
        );
      },
    );
  }
}

class _PictogramCard extends StatelessWidget {
  final Pictogram pictogram;
  final bool isSelected;
  final bool? isCorrect; // null = sin responder todavía
  final VoidCallback onTap;

  const _PictogramCard({
    required this.pictogram,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    if (isSelected && isCorrect == true) borderColor = Colors.green;
    if (isSelected && isCorrect == false) borderColor = Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: pictogram.color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen real del pictograma (ARASAAC). Mientras carga o si
            // falla la conexión, muestra el ícono de respaldo.
            SizedBox(
              height: 150,
              width: 150,
              child: PictogramImage(pictogram: pictogram),
            ),
            const SizedBox(height: 8),
            if (isSelected && isCorrect != null)
              Icon(
                isCorrect! ? Icons.check_circle : Icons.cancel,
                color: isCorrect! ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}

/// Muestra el pictograma real de ARASAAC para [pictogram.word].
/// Mientras se busca/descarga la imagen, o si la búsqueda falla
/// (sin internet, palabra no encontrada), muestra el ícono de
/// respaldo definido en el modelo, para que el juego nunca se
/// quede con un espacio vacío.
class PictogramImage extends StatefulWidget {
  final Pictogram pictogram;

  const PictogramImage({super.key, required this.pictogram});

  @override
  State<PictogramImage> createState() => _PictogramImageState();
}

class _PictogramImageState extends State<PictogramImage> {
  late Future<String?> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = PictogramImageService.fetchImageUrl(widget.pictogram.word);
  }

  @override
  void didUpdateWidget(covariant PictogramImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pictogram.word != widget.pictogram.word) {
      _imageUrlFuture = PictogramImageService.fetchImageUrl(widget.pictogram.word);
    }
  }

  Widget _fallbackIcon() {
    return Icon(widget.pictogram.icon, size: 120, color: widget.pictogram.color);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: widget.pictogram.color,
              ),
            ),
          );
        }

        final url = snapshot.data;
        if (url == null) return _fallbackIcon();

        return Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                  color: widget.pictogram.color,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
        );
      },
    );
  }
}