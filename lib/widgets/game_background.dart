import 'package:flutter/material.dart';

enum GameType { blackjack, tictactoe, shell }

class GameBackground extends StatelessWidget {
  final GameType game;
  final Widget child;
  const GameBackground({super.key, required this.game, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_backgroundForGame(game)),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }

  String _backgroundForGame(GameType game) {
    switch (game) {
      case GameType.blackjack:
        return 'assets/images/bg_blackjack.jpeg';
      case GameType.tictactoe:
        return 'assets/images/bg_tictactoe.jpeg';
      case GameType.shell:
        return 'assets/images/bg_shell.jpeg';
    }
  }
}
