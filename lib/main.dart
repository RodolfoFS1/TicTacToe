import 'package:flutter/material.dart';
import 'TicTacToeGame.dart';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TicTacToeGame(),
    );
  }
}
