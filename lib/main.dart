import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/games_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/tasks_screen.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: bottomIndex,
          children: const [
            HomeScreen(),
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
