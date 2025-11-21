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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final savedBoard = prefs.getStringList('ttt_board');
      final savedFinished = prefs.getBool('ttt_finished') ?? true;

      if (savedBoard == null) {
        final selected = await _askRole();
        if (selected != null) _startNewGame(selected);
      } else if (!savedFinished) {
        final continueGame = await _askContinue();
        if (continueGame == true) {
          await _restore();
        } else {
          final selected = await _askRole();
          if (selected != null) _startNewGame(selected);
        }
      } else {
        final selected = await _askRole();
        if (selected != null) _startNewGame(selected);
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
                    Color color = Colors.transparent;
                    List<Shadow> shadows = [];

                    if (symbol == 'X') {
                      color = Colors.red.shade900;
                      shadows = const [
                        Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
                        Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 0)),
                      ];
                    } else if (symbol == 'O') {
                      color = Colors.black;
                      shadows = const [
                        Shadow(blurRadius: 4, color: Colors.white, offset: Offset(1, 1)),
                        Shadow(blurRadius: 8, color: Colors.white70, offset: Offset(0, 0)),
                      ];
                    }

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: InkWell(
                        onTap: () => _onCellTap(i),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: color,
                              shadows: shadows,
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
      if (!finished) await _aiMove();
    }
  }

  Future<void> _aiMove() async {
    if (finished) return;
    await Future.delayed(const Duration(milliseconds: 250));

    final ai = _aiPlayer();
    int move;

    // 20% шанс «ошибки» для естественности
    if ((DateTime.now().millisecond % 100) < 20) {
      final empty = _emptyIndices();
      move = empty.isNotEmpty ? empty.first : 0;
    } else {
      move = _bestMove(ai, depth: 3);
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
    _persist();
  }

  Future<void> _playAgain() async {
    final selected = await _askRole();
    if (selected != null) _startNewGame(selected);
  }

  void _startNewGame(Player selected) {
    setState(() {
      human = selected;
      board = List.filled(9, '');
      finished = false;
      currentTurn = Player.x;
    });
    _persist();
    // Если игрок выбрал нолики, ИИ начинает первым за крестики
    if (human == Player.o) {
      _aiMove();
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

  Future<bool?> _askContinue() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Продолжить игру?'),
        content: const Text('У вас есть незавершённая партия. Хотите продолжить её?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Начать заново'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Продолжить'),
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
        human = savedHuman == 'x'
            ? Player.x
            : (savedHuman == 'o' ? Player.o : null);
        currentTurn = savedTurn == 'x' ? Player.x : Player.o;
      });
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ttt_board', board);
    await prefs.setBool('ttt_finished', finished);
    await prefs.setString('ttt_human', human == null ? 'none' : (human == Player.x ? 'x' : 'o'));
    await prefs.setString('ttt_turn', currentTurn == Player.x ? 'x' : 'o');
  }

  // Минимакс с ограничением глубины и простой эвристикой
  int _bestMove(Player ai, {int depth = 3}) {
    int bestScore = -100000;
    int bestMove = _emptyIndices().isNotEmpty ? _emptyIndices().first : 0;
    final aiSymbol = _symbolFor(ai);
    final huSymbol = _symbolFor(human ?? Player.x);

    for (final i in _emptyIndices()) {
      board[i] = aiSymbol;
      final score = _minimax(depth - 1, false, aiSymbol, huSymbol);
      board[i] = '';
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  int _minimax(int depth, bool isMax, String aiSymbol, String huSymbol) {
    final winner = _winnerSymbol(board);
    if (winner == aiSymbol) return 100 + depth; // быстрее выиграть — лучше
    if (winner == huSymbol) return -100 - depth; // избегать поражения
    if (depth == 0 || !_boardHasEmpty(board)) {
      return _heuristic(aiSymbol, huSymbol);
    }

    if (isMax) {
      int best = -100000;
      for (final i in _emptyIndices()) {
        board[i] = aiSymbol;
        final score = _minimax(depth - 1, false, aiSymbol, huSymbol);
        board[i] = '';
        if (score > best) best = score;
      }
      return best;
    } else {
      int best = 100000;
      for (final i in _emptyIndices()) {
        board[i] = huSymbol;
        final score = _minimax(depth - 1, true, aiSymbol, huSymbol);
        board[i] = '';
        if (score < best) best = score;
      }
      return best;
    }
  }

  bool _boardHasEmpty(List<String> b) => b.contains('');

  int _heuristic(String ai, String hu) {
    // Простая оценка: количество почти-собранных линий
    const wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    int score = 0;
    for (final w in wins) {
      final a = board[w[0]], b = board[w[1]], c = board[w[2]];
      final line = [a, b, c];
      final aiCount = line.where((s) => s == ai).length;
      final huCount = line.where((s) => s == hu).length;
      final emptyCount = line.where((s) => s.isEmpty).length;

      if (aiCount == 2 && emptyCount == 1) score += 10;  // шанс победы
      if (huCount == 2 && emptyCount == 1) score -= 12;  // срочная блокировка
      if (aiCount == 1 && emptyCount == 2) score += 2;
      if (huCount == 1 && emptyCount == 2) score -= 3;
    }
    return score;
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
