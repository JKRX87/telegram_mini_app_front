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
          _restore();
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
                    final color = symbol == 'X'
                        ? Colors.red.shade900
                        : symbol == 'O'
                            ? Colors.blue.shade900
                            : Colors.transparent;

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
                              shadows: symbol.isNotEmpty
                                  ? [
                                      Shadow(
                                        blurRadius: 16,
                                        color: color.withOpacity(0.8),
                                        offset: const Offset(0, 0),
                                      ),
                                    ]
                                  : [],
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
    await Future.delayed(const Duration(milliseconds: 300));

    final ai = _aiPlayer();
    int move;

    // 20% шанс ошибки
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
  }

  // ---------- Диалоги ----------

  Future<Player?> _askRole() async {
    return showDialog<Player>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Выбери роль'),
        content: const Text('Кем будешь играть: X или O?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, Player.x),
            child: const Text('X'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, Player.o),
            child: const Text('O'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _askContinue() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Незавершённая партия'),
        content: const Text('Продолжить или начать заново?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Продолжить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Начать заново'),
          ),
        ],
      ),
    );
  }

  // ---------- Сохранение/восстановление ----------

  void _restore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      board = prefs.getStringList('ttt_board') ?? List.filled(9, '');
      finished = prefs.getBool('ttt_finished') ?? false;
      final humanStr = prefs.getString('ttt_human');
      if (humanStr != null) {
        human = humanStr == 'X' ? Player.x : Player.o;
      }
      final turnStr = prefs.getString('ttt_turn');
      if (turnStr != null) {
        currentTurn = turnStr == 'X' ? Player.x : Player.o;
      }
    });
  }

  void _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ttt_board', board);
    await prefs.setBool('ttt_finished', finished);
    if (human != null) {
      await prefs.setString('ttt_human', _symbolFor(human!));
    } else {
      await prefs.remove('ttt_human');
    }
    await prefs.setString('ttt_turn', _symbolFor(currentTurn));
  }

  // ---------- Утилиты ----------

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  bool _isHumanTurn() => human != null && currentTurn == human;

  void _toggleTurn() {
    currentTurn = currentTurn == Player.x ? Player.o : Player.x;
  }

  String _symbolFor(Player p) => p == Player.x ? 'X' : 'O';

  Player _aiPlayer() => human == Player.x ? Player.o : Player.x;

  List<int> _emptyIndices([List<String>? b]) {
    final brd = b ?? board;
    final res = <int>[];
    for (int i = 0; i < 9; i++) {
      if (brd[i].isEmpty) res.add(i);
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
    for (var combo in wins) {
      final a = b[combo[0]];
      if (a.isNotEmpty &&
          a == b[combo[1]] &&
          a == b[combo[2]]) {
        return a;
      }
    }
    return null;
  }

  bool _isTerminal(List<String> b) {
    return _winnerSymbol(b) != null || !b.contains('');
  }

  int _score(List<String> b, Player ai, int depthLeft) {
    final w = _winnerSymbol(b);
    if (w == null) return 0;
    final aiSym = _symbolFor(ai);
    // Чем ближе победа — тем выше оценка; поражение — ниже.
    // Лёгкая глубинная корректировка, чтобы ИИ предпочитал быстрые победы.
    final base = w == aiSym ? 10 : -10;
    return base + depthLeft; // победа раньше = чуть больше, поражение позже = чуть меньше по модулю
  }

  // ---------- Minimax (ограничение глубины = 3) ----------

  int _bestMove(Player ai, {int depth = 3}) {
    final aiSym = _symbolFor(ai);
    int bestScore = -10000;
    int bestIdx = _emptyIndices().isNotEmpty ? _emptyIndices().first : 0;

    for (final i in _emptyIndices()) {
      final sim = List<String>.from(board);
      sim[i] = aiSym;
      final score = _minimax(sim, depth - 1, false, ai);
      if (score > bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  int _minimax(List<String> b, int depthLeft, bool isMax, Player ai) {
    if (_isTerminal(b) || depthLeft == 0) {
      if (_isTerminal(b)) {
        return _score(b, ai, depthLeft);
      }
      // Если предельная глубина — используем эвристику.
      return _heuristic(b, ai);
    }

    final aiSym = _symbolFor(ai);
    final humanSym = _symbolFor(human ?? Player.x);

    if (isMax) {
      int best = -10000;
      for (final i in _emptyIndices(b)) {
        final sim = List<String>.from(b);
        sim[i] = aiSym;
        final score = _minimax(sim, depthLeft - 1, false, ai);
        if (score > best) best = score;
      }
      return best;
    } else {
      int best = 10000;
      for (final i in _emptyIndices(b)) {
        final sim = List<String>.from(b);
        sim[i] = humanSym;
        final score = _minimax(sim, depthLeft - 1, true, ai);
        if (score < best) best = score;
      }
      return best;
    }
  }

  int _heuristic(List<String> b, Player ai) {
    // Простая позиционная оценка: линии, где ИИ ближе к победе — плюс,
    // где человек ближе — минус.
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
    final aiSym = _symbolFor(ai);
    final humanSym = _symbolFor(human ?? Player.x);
    int score = 0;

    for (final line in wins) {
      final cells = [b[line[0]], b[line[1]], b[line[2]]];
      final aiCount = cells.where((c) => c == aiSym).length;
      final humanCount = cells.where((c) => c == humanSym).length;
      final emptyCount = cells.where((c) => c.isEmpty).length;

      if (humanCount == 0) {
        // Линия только ИИ/пустые — хорошо
        if (aiCount == 2 && emptyCount == 1) score += 3; // угроза победы
        else if (aiCount == 1 && emptyCount == 2) score += 1;
      }
      if (aiCount == 0) {
        // Линия только человека/пустые — плохо
        if (humanCount == 2 && emptyCount == 1) score -= 3; // угрозу надо блокировать
        else if (humanCount == 1 && emptyCount == 2) score -= 1;
      }
    }
    // Центр чуть ценнее
    if (b[4] == aiSym) score += 1;
    if (b[4] == humanSym) score -= 1;

    return score;
  }
}
