import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/game_background.dart';

enum Player { x, o }

class TicTacToeScreen extends StatefulWidget {
  final VoidCallback onWin;
  const TicTacToeScreen({super.key, required this.onWin});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  bool finished = false;
  Player? human;
  Player currentTurn = Player.x;

  @override
  void initState() {
    super.initState();
    _restore().then((_) async {
      if (human == null) {
        final selected = await _askRole();
        if (selected != null) {
          setState(() {
            human = selected;
            currentTurn = Player.x;
          });
          if (human == Player.o) {
            _aiMove();
          }
        }
      }
    });
  }

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
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, i) {
                    final symbol = board[i];
                    final color = symbol == 'X'
                        ? Colors.deepOrange
                        : symbol == 'O'
                            ? Colors.indigo
                            : Colors.transparent;

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: InkWell(
                        onTap: () => _onCellTap(i),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: color,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: color.withOpacity(0.7),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (finished)
              FilledButton(
                onPressed: _playAgain,
                child: const Text('Сыграть ещё раз'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _onCellTap(int i) async {
    if (finished || board[i].isNotEmpty) return;

    if (_isHumanTurn()) {
      setState(() {
        board[i] = _symbolFor(currentTurn);
        _toggleTurn();
      });
      _checkEnd();
      if (!finished) {
        await _aiMove();
      }
    }
  }

  Future<void> _aiMove() async {
    if (finished) return;
    await Future.delayed(const Duration(milliseconds: 300));

    final ai = _aiPlayer();
    int move = _bestMove(ai);

    // 15% шанс ошибиться
    if ((DateTime.now().millisecond % 100) < 15) {
      final empty = _emptyIndices();
      if (empty.isNotEmpty) move = empty.first;
    }

    setState(() {
      board[move] = _symbolFor(ai);
      _toggleTurn();
    });
    _checkEnd();
  }

  void _checkEnd() {
    final winnerSymbol = _winnerSymbol(board);
    if (winnerSymbol != null) {
      finished = true;
      final winnerPlayer = winnerSymbol == 'X' ? Player.x : Player.o;
      if (human != null && winnerPlayer == human) {
        widget.onWin();
        _snack('Ты победил! +50 очков');
      } else {
        _snack('ИИ победил');
      }
    } else if (!board.contains('')) {
      finished = true;
      _snack('Ничья');
    }
  }

  Future<void> _playAgain() async {
    setState(() {
      board = List.filled(9, '');
      finished = false;
      currentTurn = Player.x;
      human = null;
    });

    final selected = await _askRole();
    if (selected != null) {
      setState(() {
        human = selected;
        currentTurn = Player.x;
      });
      if (human == Player.o) {
        _aiMove();
      }
    }
  }

  bool _isHumanTurn() => human != null && human == currentTurn;
  void _toggleTurn() {
    currentTurn = currentTurn == Player.x ? Player.o : Player.x;
  }

  String _symbolFor(Player p) => p == Player.x ? 'X' : 'O';
  Player _aiPlayer() => human == Player.x ? Player.o : Player.x;

  Future<Player?> _askRole() async {
    return showDialog<Player>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Выбери, за кого играть'),
        content: const Text('Кто ты хочешь быть в этой партии?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(Player.x),
            child: const Text('За крестики (X)'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(Player.o),
            child: const Text('За нолики (O)'),
          ),
        ],
      ),
    );
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBoard = prefs.getStringList('ttt_board');
    final savedFinished = prefs.getBool('ttt_finished');
    final savedHuman = prefs.getString('ttt_human');
    final savedTurn = prefs.getString('ttt_turn');

    if (savedBoard != null &&
        savedFinished != null &&
        savedHuman != null &&
        savedTurn != null) {
      setState(() {
        board = savedBoard;
        finished = savedFinished;
        human = savedHuman == 'x' ? Player.x : Player.o;
        currentTurn = savedTurn == 'x' ? Player.x : Player.o;
      });
    }
  }

  int _bestMove(Player ai) {
    int bestScore = -1000;
    int move = _emptyIndices().first;
    for (final i in _emptyIndices()) {
      board[i] = _symbolFor(ai);
      final score = _evaluateBoard(ai);
      board[i] = '';
      if (score > bestScore) {
        bestScore = score;
        move = i;
      }
    }
    return move;
  }

  int _evaluateBoard(Player ai) {
    final winner = _winnerSymbol(board);
    if (winner == _symbolFor(ai)) return 10;
    if (winner != null) return -10;
    return 0;
  }

  List<int> _emptyIndices() {
    final res = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i].isEmpty) res.add(i);
    }
    return res;
  }

  String? _winnerSymbol(List<String> b) {
    const wins = [
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
      final a = b[w[0]], c = b[w[1]], d = b[w[2]];
      if (a.isNotEmpty && a == c && c == d) return a;
    }
    return null;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
