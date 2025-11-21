import 'package:flutter/material.dart';

class SectionBackground extends StatelessWidget {
  final Widget child;
  const SectionBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main_bg.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

