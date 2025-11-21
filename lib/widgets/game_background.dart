import 'package:flutter/material.dart';

enum GameType { blackjack, tictactoe, shell }

class GameBackground extends StatelessWidget {
  final Widget child;
  final GameType game;
  const GameBackground({super.key, required this.child, required this.game});

  @override
  Widget build(BuildContext context) {
    late final String assetPath;
    switch (game) {
      case GameType.blackjack:
        assetPath = 'assets/images/bg_blackjack.jpeg';
        break;
      case GameType.tictactoe:
        assetPath = 'assets/images/bg_tictactoe.jpeg';
        break;
      case GameType.shell:
        assetPath = 'assets/images/bg_shell.jpeg';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

