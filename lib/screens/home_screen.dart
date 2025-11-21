import 'package:flutter/material.dart';
import '../widgets/section_background.dart';

class HomeScreen extends StatelessWidget {
  final int points;
  const HomeScreen({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text(
          'Твои очки: $points',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
