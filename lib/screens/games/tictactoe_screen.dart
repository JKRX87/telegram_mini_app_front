import 'package:flutter/material.dart';
import '../../widgets/game_background.dart';

class TicTacToeScreen extends StatefulWidget {
  final VoidCallback onWin;
  const TicTacToeScreen({super.key, required this.onWin});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  bool playerTurn = true;
  bool finished = false;

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      game: GameType.tictactoe,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Крестики‑нолики'),
          backgroundColor: Colors.black26,
        ),
        body: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1, // квадратная сетка
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // убираем скролл
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1, // клетки квадратные
                  ),
                  itemCount: 9,
                  itemBuilder: (context, i) {
                    return Card(
                      child: InkWell(
                        onTap: () => _tap(i),
                        child: Center(
                          child: Text(
                            board[i],
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _reset,
              child: const Text('Сброс'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _tap(int i) {
    if (!playerTurn || finished || board[i].isNotEmpty) return;
    setState(() {
      board[i] = 'X';
      playerTurn = false;
    });
    _checkEnd();
    if (!finished) _aiMove();
  }

  void _aiMove() {
    final idx = board.indexOf('');
    if (idx != -1) {
      setState(() {
        board[idx] = 'O';
        playerTurn = true;
      });
      _checkEnd();
    }
  }

  void _checkEnd() {
    final wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final w in wins) {
      final a = board[w[0]], b = board[w[1]], c = board[w[2]];
      if (a.isNotEmpty && a == b && b == c) {
        finished = true;
        if (a == 'X') {
          widget.onWin(); // начисляем 50 очков
          _snack('Ты победил! +50 очков');
        } else {
          _snack('ИИ победил');
        }
        return;
      }
    }
    if (!board.contains('')) {
      finished = true;
      _snack('Ничья');
    }
  }

  void _reset() {
    setState(() {
      board = List.filled(9, '');
      playerTurn = true;
      finished = false;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
