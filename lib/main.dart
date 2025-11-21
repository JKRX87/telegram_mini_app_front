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
  String colorScheme = 'light';
  Map<String, dynamic> user = {};

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
      TelegramWebApp.mainButtonShow();
      TelegramWebApp.mainButtonOnClick(() {
        final payload = jsonEncode({
          'action': 'submit',
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
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/main_bg.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTelegram ? 'Запущено в Telegram' : 'Открыто в браузере',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
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
      ),
    );
  }
}
