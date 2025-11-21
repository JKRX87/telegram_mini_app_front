import 'package:flutter/material.dart';
import '../widgets/section_background.dart';
import 'games/blackjack_screen.dart';
import 'games/tictactoe_screen.dart';
import 'games/shellgame_screen.dart';

class GamesScreen extends StatelessWidget {
  final VoidCallback onWin;
  const GamesScreen({super.key, required this.onWin});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GameCard(
              title: 'Blackjack',
              description: 'Победа: +50 очков',
              icon: Icons.casino,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BlackjackScreen(onWin: onWin)),
              ),
            ),
            _GameCard(
              title: 'Крестики‑нолики',
              description: 'Победа: +50 очков',
              icon: Icons.grid_3x3,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TicTacToeScreen(onWin: onWin)),
              ),
            ),
            _GameCard(
              title: 'Напёрстки',
              description: 'Победа: +50 очков',
              icon: Icons.sports_martial_arts,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShellGameScreen(onWin: onWin)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
