import 'package:flutter/material.dart';
import '../widgets/section_background.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text(
          'Рейтинг',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

