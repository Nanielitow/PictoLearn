import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

     class GameScreen extends StatefulWidget {
       @override
       _GameScreenState createState() => _GameScreenState();
     }

     class _GameScreenState extends State<GameScreen> {
       List<List<String>> matrix = [];
       int counter = 200;
       bool gameWon = false;
       Timer? timer;

       @override
       void initState() {
         super.initState();
         startGame();
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
       void dispose() {
         timer?.cancel();
         super.dispose();
       }

       @override
       Widget build(BuildContext context) {
         return Scaffold(
           appBar: AppBar(
             title: Text("Rompecabezas"),
           ),
           body: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text(
                 counter > 0 ? 'Tiempo restante: $counter' : '¡Se acabó el tiempo!',
                 style: TextStyle(fontSize: 24),
               ),
               SizedBox(height: 20),
               buildBoard(),
               SizedBox(height: 20),
               ElevatedButton(
                 onPressed: startGame,
                 child: Text(gameWon ? "Jugar de nuevo" : "Reiniciar"),
               ),
             ],
           ),
         );
       }

       Widget buildBoard() {
         return Column(
           children: matrix.map((row) {
             return Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: row.map((tile) {
                 return GestureDetector(
                   onTap: () => moveTile(tile),
                   child: Container(
                     width: 100,
                     height: 100,
                     margin: EdgeInsets.all(4),
                     decoration: BoxDecoration(
                       color: tile == '' ? Colors.grey[300] : Colors.blue,
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Center(
                       child: Text(
                         tile,
                         style: TextStyle(fontSize: 36, color: Colors.white),
                       ),
                     ),
                   ),
                 );
               }).toList(),
             );
           }).toList(),
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
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('¡Ganaste!')),
           );
         }
       }
     }
     