import 'package:flutter/material.dart';
import '../../widgets/game_background.dart';

class TicTacToeScreen extends StatefulWidget {
  final VoidCallback onWin;
  const TicTacToeScreen({super.key, required this.onWin});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  bool playerTurn = true;
  bool finished = false;

  @override
  Widget build(BuildContext
