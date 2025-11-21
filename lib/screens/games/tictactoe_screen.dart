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

  static const _kBoard = 'ttt_board';
  static const _kFinished = 'ttt_finished';
  static const _kHuman = 'ttt_human';
  static const _kTurn = 'ttt_turn';

  @override
  void initState() {
    super.initState();
    _restore();
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
              child: Center(
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
                          ? Colors.redAccent
                          : symbol == 'O'
                              ? Colors.lightBlueAccent
                              : Colors.transparent;

                      return Card(
                        color: Colors.white.withOpacity(0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _onCellTap(i),
                          child: Center(
                            child: Text(
                              symbol,
                              style: TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.w800,
                                color: color,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black.withOpacity(0.35),
                                    offset: const Offset(0, 2),
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
            ),
            const SizedBox(height: 12),
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
    if (human == null) {
      final selected = await _askRole();
      if (selected == null) return;
      setState(() {
        human = selected;
        currentTurn = Player.x;
      });
      await _persist();
      if (human == Player.o && !finished) {
        await _aiMove();
      }
    }

    if (finished || board[i].isNotEmpty) return;

    if (_isHumanTurn()) {
      setState(() {
        board[i] = _symbolFor(currentTurn);
        _toggleTurn();
      });
      await _persist();
      _checkEnd();
      if (!finished) {
        await _aiMove();
      }
    }
  }

  Future<void> _aiMove() async {
    if (finished) return;
    await Future.delayed(const Duration(milliseconds: 250));
    final ai = _aiPlayer();
    final best = _bestMove(ai);
    setState(() {
      board[best] = _symbolFor(ai);
      _toggleTurn();
    });
    await _persist();
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
    _persist();
  }

  Future<void> _playAgain() async {
    setState(() {
      board = List.filled(9, '');
      finished = false;
      currentTurn = Player.x;
      human = null; // сбрасываем роль
    });
    await _persist();

    final selected = await _askRole();
    if (selected == null) return;
    setState(() {
      human = selected;
      currentTurn = Player.x;
    });
    await _persist();

    if (human == Player.o) {
      await _aiMove();
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
    final savedBoard = prefs.getStringList(_kBoard);
    final savedFinished = prefs.getBool(_kFinished);
    final savedHuman = prefs.getString(_kHuman);
    final savedTurn = prefs.getString(_kTurn);

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
      if (!finished && !_isHumanTurn()) {
        await _aiMove();
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kBoard, board);
    await prefs.setBool(_kFinished, finished);
    await prefs.setString(_kHuman, human == null ? 'none' : (human == Player.x ? 'x' : 'o'));
    await prefs.setString(_kTurn, currentTurn == Player.x ? 'x' : 'o');
  }

  int _bestMove(Player ai) {
    for (final i in _emptyIndices()) {
      board[i] = _symbolFor(ai);
      final winner = _winnerSymbol(board);
      board[i] = '';
      if (winner == _symbolFor(ai)) return i;
    }
    return _emptyIndices().isNotEmpty ? _emptyIndices().first : 0;
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
