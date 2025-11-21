import 'package:flutter/material.dart';
import '../widgets/section_background.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text(
          'Друзья',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

