import 'dart:convert';
import 'package:flutter/material.dart';
import 'telegram_webapp.dart';

void main() {
  runApp(const MiniApp());
}

class MiniApp extends StatefulWidget {
  const MiniApp({super.key});
  @override
  State<MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<MiniApp> {
  bool isTelegram = false;
  String platform = 'browser';
  String colorScheme = 'light';
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _initWebApp();
  }

  void _initWebApp() {
    isTelegram = TelegramWebApp.isAvailable;
    platform = TelegramWebApp.platform;
    colorScheme = TelegramWebApp.colorScheme;

    if (isTelegram) {
      TelegramWebApp.ready();
      TelegramWebApp.expand();
      TelegramWebApp.mainButtonSetText('Отправить');
      TelegramWebApp.mainButtonShow();
      TelegramWebApp.mainButtonOnClick(() {
        final payload = jsonEncode({
          'action': 'submit',
          'timestamp': DateTime.now().toIso8601String(),
          'user': user,
        });
        TelegramWebApp.sendData(payload);
        TelegramWebApp.close();
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = colorScheme == 'dark';
    return MaterialApp(
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Telegram Mini App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isTelegram
                  ? 'Запущено внутри Telegram ($platform)'
                  : 'Открыто в браузере'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  TelegramWebApp.openLink('https://flutter.dev');
                },
                child: const Text('Открыть Flutter.dev'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

