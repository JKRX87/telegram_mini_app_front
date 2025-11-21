import 'package:flutter/material.dart';
import '../widgets/section_background.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text(
          'Задания',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

