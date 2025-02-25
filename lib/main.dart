import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_alarm_app_2/home/home_page.dart';
import 'package:flutter_alarm_app_2/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // .env 파일 로드
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init();

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
  _QuoteAlarmAppState createState() => _QuoteAlarmAppState();
}

class _QuoteAlarmAppState extends State<QuoteAlarmApp> {
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
              primaryColor: const Color(0xFF101317),
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
              primaryColor: const Color(0xFFFFFBEA),
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
          AlarmHomePage(onThemeToggle: _toggleTheme, isDarkTheme: _isDarkTheme),
    );
  }
}
