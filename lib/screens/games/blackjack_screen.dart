import 'package:flutter/material.dart';
import '../../widgets/game_background.dart';

class BlackjackScreen extends StatefulWidget {
  final VoidCallback onWin;
  const BlackjackScreen({super.key, required this.onWin});

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  int player = 0;
  int ai = 0;
  bool finished = false;

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      game: GameType.blackjack,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Blackjack'), backgroundColor: Colors.black26),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _score('Ты', player),
              _score('ИИ', ai),
              const SizedBox(height: 16),
              Wrap(spacing: 12, children: [
                FilledButton(onPressed: finished ? null : _hit, child: const Text('Взять карту')),
                FilledButton.tonal(onPressed: finished ? null : _stand, child: const Text('Хватит')),
                FilledButton(onPressed: _reset, child: const Text('Сброс')),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _score(String who, int score) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('$who: $score', style: const TextStyle(fontSize: 20)),
        ),
      );

  void _hit() {
    setState(() {
      player += _draw();
      if (player > 21) {
        finished = true;
        _snack('Перебор: ты проиграл');
      }
    });
  }

  void _stand() {
    setState(() {
      while (ai < 17) {
        ai += _draw();
      }
      finished = true;
      _finishResult();
    });
  }

  int _draw() => [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 11][DateTime.now().microsecond % 12];

  void _finishResult() {
    if (ai > 21 || player > ai) {
      widget.onWin(); // начисляем 50 очков
      _snack('Ты победил!');
    } else if (player == ai) {
      _snack('Ничья');
    } else {
      _snack('ИИ победил');
    }
  }

  void _reset() {
    setState(() {
      player = 0;
      ai = 0;
      finished = false;
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
