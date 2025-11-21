import 'package:flutter/material.dart';
import '../../widgets/game_background.dart';

class BlackjackScreen extends StatelessWidget {
  const BlackjackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      game: GameType.blackjack,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Blackjack'), backgroundColor: Colors.black26),
        body: const Center(child: Text('Здесь будет логика Blackjack', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}

