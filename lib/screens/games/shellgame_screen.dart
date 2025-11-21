import 'package:flutter/material.dart';
import '../../widgets/game_background.dart';

class ShellGameScreen extends StatefulWidget {
  const ShellGameScreen({super.key});

  @override
  State<ShellGameScreen> createState() => _ShellGameScreenState();
}

class _ShellGameScreenState extends State<ShellGameScreen> {
  int ballPos = 0;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    // случайная позиция шарика при старте
    ballPos = DateTime.now().microsecond % 3;
  }

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      game: GameType.shell,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Напёрстки'),
          backgroundColor: Colors.black26,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Найди шарик под одним из трёх напёрстков',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: List.generate(3, (i) {
                return FilledButton.tonal(
                  onPressed: finished ? null : () => _choose(i),
                  child: Text('Напёрсток ${i + 1}'),
                );
              }),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _shuffle,
              child: const Text('Перемешать'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _reset,
              child: const Text('Сброс'),
            ),
          ],
        ),
      ),
    );
  }

  void _choose(int i) {
    setState(() => finished = true);
    if (i == ballPos) {
      _snack('Верно! Ты получаешь очки');
    } else {
      _snack('Мимо! Попробуй снова');
    }
  }

  void _shuffle() {
    if (finished) return;
    setState(() {
      ballPos = (ballPos + 1 + DateTime.now().millisecond % 2) % 3;
    });
    _snack('Перемешали!');
  }

  void _reset() {
    setState(() {
      ballPos = DateTime.now().microsecond % 3;
      finished = false;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
