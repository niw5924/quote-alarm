import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_alarm_app_2/home/home_screen.dart';
import 'package:flutter_alarm_app_2/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(); // .env 파일 로드
  await Firebase.initializeApp();

  await Alarm.init();

  await Alarm.setWarningNotificationOnKill(
      '🥺 울림소리 앱을 다시 켜주세요', '앱이 종료되면 알람이 정상적으로 작동하지 않을 수 있습니다.');

  final prefs = await SharedPreferences.getInstance();
  final isDarkTheme = prefs.getBool('isDarkTheme') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: QuoteAlarmApp(isDarkTheme: isDarkTheme),
    ),
  );
}

class QuoteAlarmApp extends StatefulWidget {
  final bool isDarkTheme;

  const QuoteAlarmApp({super.key, required this.isDarkTheme});

  @override
  QuoteAlarmAppState createState() => QuoteAlarmAppState();
}

class QuoteAlarmAppState extends State<QuoteAlarmApp> {
  bool _isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
  }

  Future<void> _toggleTheme(bool isDark) async {
    setState(() {
      _isDarkTheme = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkTheme
          ? ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF101317),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF151922),
                foregroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color(0xFF151922),
                selectedItemColor: const Color(0xFFDDDDDD),
                unselectedItemColor: Colors.grey[700],
              ),
            )
          : ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFFFFBEA),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF8EDD8),
                foregroundColor: Colors.black,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color(0xFFF8EDD8),
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey[700],
              ),
            ),
      home:
          HomeScreen(onThemeToggle: _toggleTheme, isDarkTheme: _isDarkTheme),
    );
  }
}
