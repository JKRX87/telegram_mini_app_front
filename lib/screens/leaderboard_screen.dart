import 'package:flutter/material.dart';
import '../widgets/section_background.dart';

class LeaderboardScreen extends StatelessWidget {
  final int points;
  const LeaderboardScreen({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ты'),
              subtitle: Text('Очки: $points'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.emoji_events),
                  title: Text('Alice'),
                  trailing: Text('120'),
                ),
                ListTile(
                  leading: Icon(Icons.emoji_events),
                  title: Text('Bob'),
                  trailing: Text('95'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
