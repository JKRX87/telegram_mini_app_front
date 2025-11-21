import 'package:flutter/material.dart';
import '../widgets/section_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text(
          'Главная',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

