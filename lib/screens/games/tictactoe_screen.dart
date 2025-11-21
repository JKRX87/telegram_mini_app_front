import 'package:flutter/material.dart';
import '../../widgets/game_background.dart';

class TicTacToeScreen extends StatelessWidget {
  const TicTacToeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      game: GameType.tictactoe,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Крестики‑нолики'), backgroundColor: Colors.black26),
        body: const Center(child: Text('Здесь будет логика крестиков‑ноликов', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}

