import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import 'package:pictolearn/models/pictogram.dart';
import 'package:pictolearn/services/pictogram_image_service.dart';

/// Rompecabezas deslizante (n-puzzle) donde las piezas son fragmentos
/// reales de un pictograma (ARASAAC). Al armar la imagen completa, se
/// revela la palabra en inglés/español y se dice en voz alta, y el
/// juego pasa automáticamente a una palabra nueva.
///
/// Incluye modo Fácil (2x2, 3 piezas) y Difícil (3x3, 8 piezas), una
/// miniatura de referencia siempre visible, y las piezas que se
/// pueden mover se resaltan con un borde dorado.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const String emptyToken = '';

  int gridSize = 2; // empieza en modo Fácil (2x2 = 3 piezas)
  int get totalCells => gridSize * gridSize;

  List<List<String>> matrix = [];
  int counter = 200;
  bool gameWon = false;
  bool _isLoadingImage = true;
  Timer? timer;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final FlutterTts _tts = FlutterTts();
  final Random _random = Random();
  late Pictogram _currentPictogram;
  Pictogram? _previousPictogram;
  String? _imageUrl;

  // Paleta de colores infantil en tonos azules
  final Color primaryBlue = Color(0xFF2196F3);
  final Color lightBlue = Color(0xFFBBDEFB);
  final Color darkBlue = Color(0xFF1976D2);
  final Color goldHighlight = Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    );

    _configureTts();
    _loadNewPuzzle();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.1);
  }

  void _setDifficulty(int newGridSize) {
    if (newGridSize == gridSize) return;
    setState(() => gridSize = newGridSize);
    startGame(); // mismo pictograma, solo re-mezcla con el nuevo tamaño
  }

  /// Elige una palabra nueva (distinta a la actual si es posible),
  /// busca su imagen real, y arma un rompecabezas nuevo con ella.
  Future<void> _loadNewPuzzle() async {
    setState(() => _isLoadingImage = true);

    final candidates = _previousPictogram == null
        ? pictogramBank
        : pictogramBank.where((p) => p.word != _previousPictogram!.word).toList();
    _currentPictogram = candidates[_random.nextInt(candidates.length)];
    _previousPictogram = _currentPictogram;

    final url = await PictogramImageService.fetchImageUrl(_currentPictogram.word);

    if (!mounted) return;
    setState(() {
      _imageUrl = url;
      _isLoadingImage = false;
    });
    startGame();
  }

  bool get _hasCurrent => true;

  void startGame() {
    setState(() {
      matrix = shuffleMatrix();
      counter = 200;
      gameWon = false;
    });
    startCounter();
  }

  /// Genera la posición ganadora: '0','1','2'...'' en orden, de
  /// tamaño gridSize x gridSize.
  List<List<String>> _solvedMatrix() {
    return List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        final index = row * gridSize + col;
        return index == totalCells - 1 ? emptyToken : index.toString();
      });
    });
  }

  /// Mezcla el tablero haciendo movimientos válidos al azar desde la
  /// posición resuelta. A diferencia de barajar los tokens al azar
  /// (que puede generar combinaciones IMPOSIBLES de resolver la mitad
  /// de las veces), esto garantiza que el rompecabezas siempre tenga
  /// solución, y controla la dificultad con la cantidad de movimientos.
  List<List<String>> shuffleMatrix() {
    final result = _solvedMatrix();
    // Menos movimientos = más fácil (queda "casi armado").
    final shuffleMoves = gridSize <= 2 ? 12 : 35;

    var emptyPos = [gridSize - 1, gridSize - 1];
    List<int>? lastMoved;

    for (int i = 0; i < shuffleMoves; i++) {
      final neighbors = <List<int>>[];
      final r = emptyPos[0], c = emptyPos[1];
      if (r > 0) neighbors.add([r - 1, c]);
      if (r < gridSize - 1) neighbors.add([r + 1, c]);
      if (c > 0) neighbors.add([r, c - 1]);
      if (c < gridSize - 1) neighbors.add([r, c + 1]);

      // Evita deshacer el movimiento anterior, para que la mezcla
      // avance de verdad en vez de ir y venir en el mismo lugar.
      neighbors.removeWhere((n) => lastMoved != null && n[0] == lastMoved![0] && n[1] == lastMoved![1]);
      if (neighbors.isEmpty) continue;

      final chosen = neighbors[_random.nextInt(neighbors.length)];
      result[emptyPos[0]][emptyPos[1]] = result[chosen[0]][chosen[1]];
      result[chosen[0]][chosen[1]] = emptyToken;
      lastMoved = emptyPos;
      emptyPos = chosen;
    }

    return result;
  }

  void startCounter() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0 && !gameWon) {
          counter--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: Text(
          "¡Rompecabezas Mágico!",
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'IntensaFuente',
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle, color: Colors.white),
            tooltip: 'Nueva palabra',
            onPressed: _isLoadingImage ? null : _loadNewPuzzle,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fondoNubes.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 8),
                _buildDifficultyToggle(),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTimerWidget(),
                    SizedBox(width: 12),
                    _buildReferenceThumbnail(),
                  ],
                ),
                SizedBox(height: 12),
                _buildGameStatus(),
                SizedBox(height: 12),
                _isLoadingImage ? _buildLoadingBoard() : buildBoard(),
                SizedBox(height: 24),
                _buildButtons(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyToggle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDifficultyChip('Fácil 🐣', 2),
          _buildDifficultyChip('Difícil 🚀', 3),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String label, int size) {
    final selected = gridSize == size;
    return GestureDetector(
      onTap: _isLoadingImage ? null : () => _setDifficulty(size),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : darkBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: primaryBlue, size: 26),
          SizedBox(width: 10),
          Text(
            counter > 0 ? '$counter s' : '¡Tiempo!',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'IntensaFuente',
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Pequeña vista previa de la imagen completa, siempre visible,
  /// para que el niño sepa qué está armando (mucho más fácil que
  /// adivinar a ciegas).
  Widget _buildReferenceThumbnail() {
    if (_imageUrl == null) return SizedBox.shrink();
    return Container(
      width: 70,
      height: 70,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildGameStatus() {
    if (!gameWon && counter > 0) return SizedBox.shrink();

    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: gameWon ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          gameWon ? '¡Felicitaciones! ¡Ganaste! 🎉' : '¡Inténtalo de nuevo! 😊',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'IntensaFuente',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBoard() {
    final boardSize = gridSize * _tileSize + 40;
    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(color: primaryBlue),
      ),
    );
  }

  Widget buildBoard() {
    final emptyPos = findPosition(emptyToken);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(matrix.length, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(matrix[row].length, (col) {
              final tile = matrix[row][col];
              final isMovable = emptyPos != null &&
                  tile != emptyToken &&
                  (row - emptyPos[0]).abs() + (col - emptyPos[1]).abs() == 1;
              return _buildTile(tile, isMovable);
            }),
          );
        }),
      ),
    );
  }

  double get _tileSize => gridSize <= 2 ? 110 : 80;

  Widget _buildTile(String tile, bool isMovable) {
    return GestureDetector(
      onTap: () => moveTile(tile),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: _tileSize,
        height: _tileSize,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: tile == emptyToken ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isMovable ? Border.all(color: goldHighlight, width: 4) : null,
          boxShadow: tile == emptyToken ? [] : [
            BoxShadow(
              color: darkBlue.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: tile == emptyToken
            ? null
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildPieceImage(tile),
              ),
      ),
    );
  }

  /// Muestra el fragmento correspondiente de la imagen completa para
  /// la pieza [tile] (su posición original en la cuadrícula), usando
  /// OverflowBox para "recortar" la parte que le toca de la imagen.
  Widget _buildPieceImage(String tile) {
    final pieceIndex = int.parse(tile);
    final pieceRow = pieceIndex ~/ gridSize;
    final pieceCol = pieceIndex % gridSize;
    final puzzlePixelSize = _tileSize * gridSize;

    if (_imageUrl == null) {
      // Sin conexión / no se encontró imagen: respaldo con el número
      // de pieza, para que el juego siga funcionando.
      return Container(
        color: primaryBlue.withOpacity(0.15),
        child: Center(
          child: Text(
            '${pieceIndex + 1}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
      );
    }

    return OverflowBox(
      maxWidth: puzzlePixelSize,
      maxHeight: puzzlePixelSize,
      alignment: Alignment(
        gridSize == 1 ? 0 : -1 + 2 * pieceCol / (gridSize - 1),
        gridSize == 1 ? 0 : -1 + 2 * pieceRow / (gridSize - 1),
      ),
      child: SizedBox(
        width: puzzlePixelSize,
        height: puzzlePixelSize,
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: primaryBlue.withOpacity(0.15),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          onPressed: _isLoadingImage ? null : startGame,
          icon: Icons.refresh,
          label: "Reiniciar",
        ),
        SizedBox(width: 20),
        _buildButton(
          onPressed: () => context.go('/home'),
          icon: Icons.home,
          label: "Inicio",
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'IntensaFuente',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void moveTile(String tile) {
    if (tile == emptyToken || gameWon) return;
    var emptyPos = findPosition(emptyToken);
    var tilePos = findPosition(tile);

    if (tilePos != null && emptyPos != null) {
      if ((tilePos[0] - emptyPos[0]).abs() + (tilePos[1] - emptyPos[1]).abs() == 1) {
        setState(() {
          matrix[emptyPos[0]][emptyPos[1]] = tile;
          matrix[tilePos[0]][tilePos[1]] = emptyToken;
        });
        checkWinCondition();
      }
    }
  }

  List<int>? findPosition(String value) {
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        if (matrix[i][j] == value) return [i, j];
      }
    }
    return null;
  }

  void checkWinCondition() {
    final winningMatrix = _solvedMatrix();

    final won = matrix.toString() == winningMatrix.toString();
    if (won) {
      setState(() => gameWon = true);
      timer?.cancel();
      _revealWord();
    }
  }

  Future<void> _revealWord() async {
    await _tts.stop();
    await _tts.speak(_currentPictogram.translation);
    if (!mounted) return;
    _showWordDialog();
  }

  void _showWordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¡Lo lograste! 🎉',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'IntensaFuente',
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (_imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _imageUrl!,
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  _currentPictogram.translation,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                Text(
                  _currentPictogram.word,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _tts.speak(_currentPictogram.translation),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                    child: Icon(Icons.volume_up, color: Colors.white, size: 24),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text('Inicio'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _loadNewPuzzle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Palabra nueva',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'IntensaFuente',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}