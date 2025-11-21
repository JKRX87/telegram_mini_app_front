import 'package:flutter/material.dart';
import '../widgets/section_background.dart';
import 'games/blackjack_screen.dart';
import 'games/tictactoe_screen.dart';
import 'games/shellgame_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GameCard(
              title: 'Blackjack',
              description: 'Играй против ИИ',
              icon: Icons.casino,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlackjackScreen()),
              ),
            ),
            _GameCard(
              title: 'Крестики‑нолики',
              description: 'Против ИИ',
              icon: Icons.grid_3x3,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TicTacToeScreen()),
              ),
            ),
            _GameCard(
              title: 'Напёрстки',
              description: 'Найди шарик',
              icon: Icons.sports_martial_arts,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShellGameScreen()),
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

