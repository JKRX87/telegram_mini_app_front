import 'dart:convert';
import 'package:flutter/material.dart';
import 'telegram_webapp.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // Telegram / User
  bool isTelegram = false;
  String colorScheme = 'light';
  Map<String, dynamic> user = {};

  // App state
  int bottomIndex = 0;
  int points = 0; // общие очки
  List<String> referrals = []; // заглушка
  List<TaskItem> tasks = TaskItem.sample(); // задания-заглушки
  List<LeaderboardEntry> leaderboard = LeaderboardEntry.sample(); // рейтинг-заглушка

  @override
  void initState() {
    super.initState();
    _initTelegram();
  }

  void _initTelegram() {
    isTelegram = TelegramWebApp.isAvailable;
    colorScheme = TelegramWebApp.colorScheme;

    final unsafe = TelegramWebApp.initDataUnsafe;
    if (unsafe != null && unsafe['user'] != null) {
      user = Map<String, dynamic>.from(unsafe['user']);
    }

    if (isTelegram) {
      TelegramWebApp.ready();
      TelegramWebApp.expand();
      TelegramWebApp.mainButtonSetText('Отправить');
      TelegramWebApp.mainButtonHide();
      TelegramWebApp.mainButtonOnClick(() {
        final payload = jsonEncode({
          'action': 'submit',
          'user': user,
          'points': points,
        });
        TelegramWebApp.sendData(payload);
      });
    }
    setState(() {});
  }

  void addPoints(int delta, {String reason = 'game_win'}) {
    setState(() {
      points += delta;
    });
    // В будущем: отправить событие на бек через sendData/initData подпись
  }

  void completeTask(TaskItem task) {
    if (task.completed) return;
    setState(() {
      task.completed = true;
      points += task.reward;
    });
  }

  ThemeData _theme() {
    final isDark = colorScheme == 'dark';
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _theme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: bottomIndex,
          children: [
            HomeScreen(
              isTelegram: isTelegram,
              user: user,
              points: points,
            ),
            GamesScreen(
              onOpenGame: (game) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      switch (game) {
                        case GameType.blackjack:
                          return BlackjackScreen(
                            onWin: () => addPoints(10, reason: 'blackjack_win'),
                            onLose: () {},
                          );
                        case GameType.tictactoe:
                          return TicTacToeScreen(
                            onWin: () => addPoints(8, reason: 'tictactoe_win'),
                            onDraw: () => addPoints(3, reason: 'tictactoe_draw'),
                            onLose: () {},
                          );
                        case GameType.shellgame:
                          return ShellGameScreen(
                            onWin: () => addPoints(5, reason: 'shell_win'),
                            onLose: () {},
                          );
                      }
                    },
                  ),
                );
              },
            ),
            LeaderboardScreen(
              points: points,
              leaderboard: leaderboard,
            ),
            FriendsScreen(
              referrals: referrals,
              onInvite: (handle) {
                setState(() {
                  referrals.add(handle);
                  points += 2; // базовые очки за приглашение
                });
              },
            ),
            TasksScreen(
              tasks: tasks,
              onComplete: (task) => completeTask(task),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: bottomIndex,
          onDestinationSelected: (i) => setState(() => bottomIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Главная'),
            NavigationDestination(icon: Icon(Icons.games), label: 'Игры'),
            NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Рейтинг'),
            NavigationDestination(icon: Icon(Icons.group), label: 'Друзья'),
            NavigationDestination(icon: Icon(Icons.checklist), label: 'Задания'),
          ],
        ),
      ),
    );
  }
}

// ---------- Models & sample data ----------

enum GameType { blackjack, tictactoe, shellgame }

class TaskItem {
  final String id;
  final String title;
  final String type; // daily, one-time, ingame, external
  final int reward;
  bool completed;

  TaskItem({
    required this.id,
    required this.title,
    required this.type,
    required this.reward,
    this.completed = false,
  });

  static List<TaskItem> sample() => [
        TaskItem(id: 'd1', title: 'Ежедневная: сыграть 1 игру', type: 'daily', reward: 3),
        TaskItem(id: 'o1', title: 'Разовая: заполнить профиль', type: 'one-time', reward: 5),
        TaskItem(id: 'g1', title: 'Внутриигровая: сыграть 5 игр', type: 'ingame', reward: 10),
        TaskItem(id: 'e1', title: 'Внешняя: подписка на канал', type: 'external', reward: 7),
      ];
}

class LeaderboardEntry {
  final String name;
  final int points;

  LeaderboardEntry(this.name, this.points);

  static List<LeaderboardEntry> sample() => [
        LeaderboardEntry('Alice', 120),
        LeaderboardEntry('Bob', 95),
        LeaderboardEntry('Carol', 80),
      ];
}

// ---------- Screens ----------

class SectionBackground extends StatelessWidget {
  final Widget child;
  const SectionBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main_bg.lpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

class GameBackground extends StatelessWidget {
  final Widget child;
  final GameType game;
  const GameBackground({super.key, required this.child, required this.game});

  @override
  Widget build(BuildContext context) {
    // Индивидуальные фоны игр
    LinearGradient grad;
    switch (game) {
      case GameType.blackjack:
        grad = const LinearGradient(
          colors: [Color(0xFF0C1B0C), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case GameType.tictactoe:
        grad = const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case GameType.shellgame:
        grad = const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF8D6E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
    }
    return Container(
      decoration: BoxDecoration(gradient: grad),
      child: child,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isTelegram;
  final Map<String, dynamic> user;
  final int points;
  const HomeScreen({super.key, required this.isTelegram, required this.user, required this.points});

  @override
  Widget build(BuildContext context) {
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final username = user['username'] ?? '—';
    return SectionBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                'Привет, ${name.isEmpty ? 'игрок' : name} (@$username)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                isTelegram ? 'Запущено внутри Telegram' : 'Открыто в браузере',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Твои очки'),
                  subtitle: Text('$points'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('TON-кошелёк'),
                  subtitle: const Text('Привязка и донат — скоро'),
                  trailing: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Интеграция TON будет добавлена позже')),
                      );
                    },
                    child: const Text('Привязать'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamesScreen extends StatelessWidget {
  final void Function(GameType) onOpenGame;
  const GamesScreen({super.key, required this.onOpenGame});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _GameCard(
                title: 'Blackjack',
                description: 'Играй против ИИ. Победа: +10 очков',
                icon: Icons.casino,
                onTap: () => onOpenGame(GameType.blackjack),
              ),
              _GameCard(
                title: 'Крестики‑нолики',
                description: 'Против ИИ. Победа: +8, Ничья: +3',
                icon: Icons.grid_3x3,
                onTap: () => onOpenGame(GameType.tictactoe),
              ),
              _GameCard(
                title: 'Напёрстки',
                description: 'Найди шарик. Победа: +5',
                icon: Icons.sports_martial_arts,
                onTap: () => onOpenGame(GameType.shellgame),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  final int points;
  final List<LeaderboardEntry> leaderboard;
  const LeaderboardScreen({super.key, required this.points, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Твои очки'),
                subtitle: Text('$points'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: leaderboard
                    .map((e) => ListTile(
                          leading: const Icon(Icons.emoji_events),
                          title: Text(e.name),
                          trailing: Text('${e.points}'),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendsScreen extends StatefulWidget {
  final List<String> referrals;
  final void Function(String) onInvite;
  const FriendsScreen({super.key, required this.referrals, required this.onInvite});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text('Пригласи друга и получи очки'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          prefixText: '@',
                          labelText: 'Юзернейм друга',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {
                          final handle = controller.text.trim();
                          if (handle.isEmpty) return;
                          widget.onInvite(handle);
                          controller.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Приглашение отправлено @$handle')),
                          );
                        },
                        child: const Text('Отправить приглашение'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: widget.referrals
                      .map((r) => ListTile(
                            leading: const Icon(Icons.person_add),
                            title: Text('@$r'),
                            subtitle: const Text('Ожидается подтверждение'),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final List<TaskItem> tasks;
  final void Function(TaskItem) onComplete;
  const TasksScreen({super.key, required this.tasks, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: tasks
              .map((t) => Card(
                    child: ListTile(
                      leading: Icon(_taskIcon(t.type)),
                      title: Text(t.title),
                      subtitle: Text('Награда: +${t.reward} • Тип: ${t.type}'),
                      trailing: t.completed
                          ? const Icon(Icons.check, color: Colors.green)
                          : FilledButton(
                              onPressed: () => onComplete(t),
                              child: const Text('Выполнить'),
                            ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  IconData _taskIcon(String type) {
    switch (type) {
      case 'daily':
        return Icons.calendar_today;
      case 'one-time':
        return Icons.task_alt;
      case 'ingame':
        return Icons.sports_esports;
      case 'external':
        return Icons.link;
    }
    return Icons.help_outline;
  }
}

// ---------- Games (stubs) ----------

class BlackjackScreen extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;
  const BlackjackScreen({super.key, required this.onWin, required this.onLose});

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
                FilledButton(
                  onPressed: finished ? null : _hit,
                  child: const Text('Взять карту'),
                ),
                FilledButton.tonal(
                  onPressed: finished ? null : _stand,
                  child: const Text('Хватит'),
                ),
                FilledButton(
                  onPressed: _reset,
                  child: const Text('Сброс'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _score(String who, int score) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('$who: $score', style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  void _hit() {
    setState(() {
      player += _draw();
      if (player > 21) {
        finished = true;
        widget.onLose();
        _snack('Перебор: ты проиграл');
      }
    });
  }

  void _stand() {
    setState(() {
      // Простой ИИ: добирает до 17+
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
      widget.onWin();
      _snack('Ты победил!');
    } else if (player == ai) {
      _snack('Ничья');
    } else {
      widget.onLose();
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

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class TicTacToeScreen extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onDraw;
  final VoidCallback onLose;
  const TicTacToeScreen({super.key, required this.onWin, required this.onDraw, required this.onLose});

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
        appBar: AppBar(title: const Text('Крестики‑нолики'), backgroundColor: Colors.black26),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: 9,
                  itemBuilder: (context, i) {
                    return Card(
                      child: InkWell(
                        onTap: () => _tap(i),
                        child: Center(
                          child: Text(
                            board[i],
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              FilledButton(onPressed: _reset, child: const Text('Сброс')),
            ],
          ),
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
    // Простой ИИ: ставит 'O' в первое доступное поле
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
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6],
    ];
    for (final w in wins) {
      final a = board[w[0]], b = board[w[1]], c = board[w[2]];
      if (a.isNotEmpty && a == b && b == c) {
        finished = true;
        if (a == 'X') {
          widget.onWin();
          _snack('Ты победил!');
        } else {
          widget.onLose();
          _snack('ИИ победил');
        }
        return;
      }
    }
    if (!board.contains('')) {
      finished = true;
      widget.onDraw();
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

class ShellGameScreen extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;
  const ShellGameScreen({super.key, required this.onWin, required this.onLose});

  @override
  State<ShellGameScreen> createState() => _ShellGameScreenState();
}

class _ShellGameScreenState extends State<ShellGameScreen> {
  int ballPos = 0;
  bool shuffled = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    ballPos = DateTime.now().microsecond % 3;
  }

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      game: GameType.shellgame,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Напёрстки'), backgroundColor: Colors.black26),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Найди шарик под одним из трёх напёрстков', style: TextStyle(color: Colors.white)),
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
            FilledButton(onPressed: _shuffle, child: const Text('Перемешать')),
            const SizedBox(height: 8),
            FilledButton(onPressed: _reset, child: const Text('Сброс')),
          ],
        ),
      ),
    );
  }

  void _choose(int i) {
    setState(() {
      finished = true;
    });
    if (i == ballPos) {
      widget.onWin();
      _snack('Верно! Ты получаешь очки');
    } else {
      widget.onLose();
      _snack('Мимо! Попробуй снова');
    }
  }

  void _shuffle() {
    if (finished) return;
    setState(() {
      shuffled = true;
      ballPos = (ballPos + 1 + DateTime.now().millisecond % 2) % 3;
    });
    _snack('Перемешали!');
  }

  void _reset() {
    setState(() {
      ballPos = DateTime.now().microsecond % 3;
      shuffled = false;
      finished = false;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
