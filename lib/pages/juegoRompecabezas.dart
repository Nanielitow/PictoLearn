import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<List<String>> matrix = [];
  int counter = 200;
  bool gameWon = false;
  Timer? timer;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Paleta de colores infantil en tonos azules
  final Color primaryBlue = Color(0xFF2196F3);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color lightBlue = Color(0xFFBBDEFB);
  final Color darkBlue = Color(0xFF1976D2);

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

    startGame();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      matrix = shuffleMatrix();
      counter = 200;
      gameWon = false;
    });
    startCounter();
  }

  List<List<String>> shuffleMatrix() {
    List<String> tokens = ['1', '2', '3', '4', '5', '6', '7', '8', ''];
    tokens.shuffle(Random());
    return [
      tokens.sublist(0, 3),
      tokens.sublist(3, 6),
      tokens.sublist(6, 9),
    ];
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
            fontSize: 24,
            fontFamily: 'IntensaFuente',
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fondoNubes.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerWidget(),
              SizedBox(height: 20),
              _buildGameStatus(),
              SizedBox(height: 20),
              buildBoard(),
              SizedBox(height: 30),
              _buildButtons(),
            ],
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
          Icon(Icons.timer, color: primaryBlue, size: 30),
          SizedBox(width: 10),
          Text(
            counter > 0 ? '$counter segundos' : '¡Se acabó el tiempo!',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'IntensaFuente',
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  Widget buildBoard() {
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
        children: matrix.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((tile) {
              return _buildTile(tile);
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTile(String tile) {
    return GestureDetector(
      onTap: () => moveTile(tile),
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: tile == '' ? Colors.grey[300] : primaryBlue,
          borderRadius: BorderRadius.circular(15),
          boxShadow: tile == '' ? [] : [
            BoxShadow(
              color: darkBlue.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          gradient: tile == '' ? null : LinearGradient(
            colors: [primaryBlue, secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            tile,
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontFamily: 'IntensaFuente',
              fontWeight: FontWeight.bold,
            ),
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
          onPressed: startGame,
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
    required VoidCallback onPressed,
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
    if (tile == '') return;
    var emptyPos = findPosition('');
    var tilePos = findPosition(tile);

    if (tilePos != null && emptyPos != null) {
      if ((tilePos[0] - emptyPos[0]).abs() + (tilePos[1] - emptyPos[1]).abs() == 1) {
        setState(() {
          matrix[emptyPos[0]][emptyPos[1]] = tile;
          matrix[tilePos[0]][tilePos[1]] = '';
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
    const winningMatrix = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '']
    ];

    setState(() {
      gameWon = matrix.toString() == winningMatrix.toString();
    });

    if (gameWon) {
      timer?.cancel();
      _showConfetti();
    }
  }

  void _showConfetti() {
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
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  '¡Felicitaciones!',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'IntensaFuente',
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '¡Has completado el rompecabezas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,  // error
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Jugar de nuevo',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'IntensaFuente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}