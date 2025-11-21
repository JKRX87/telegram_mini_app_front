import 'dart:convert';
import 'package:flutter/material.dart';
import 'telegram_webapp.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool isTelegram = false;
  String colorScheme = 'light';
  Map<String, dynamic> user = {};
  int bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _initWebApp();
  }

  void _initWebApp() {
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
        });
        TelegramWebApp.sendData(payload);
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: bottomIndex,
          children: [
            HomeScreen(user: user, isTelegram: isTelegram),
            GamesScreen(),
            LeaderboardScreen(),
            FriendsScreen(),
            TasksScreen(),
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

// ---------- Screens ----------

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isTelegram;
  const HomeScreen({super.key, required this.user, required this.isTelegram});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text(
          isTelegram ? 'Запущено в Telegram' : 'Открыто в браузере',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text('Игры', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text('Рейтинг', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text('Друзья', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: Center(
        child: Text('Задания', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
