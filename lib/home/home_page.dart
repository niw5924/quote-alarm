import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_edit_page.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_list_page.dart';
import 'package:flutter_alarm_app_2/alarm/quote_screen.dart';
import 'package:flutter_alarm_app_2/news/news_page.dart';
import 'package:flutter_alarm_app_2/services/quote_service.dart';
import 'package:flutter_alarm_app_2/settings/settings_page.dart';
import 'package:flutter_alarm_app_2/statistics/statistics_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum AlarmCancelMode {
  slider,
  mathProblem,
  puzzle,
  voiceRecognition,
}

class AlarmItem {
  AlarmSettings settings;
  bool isEnabled;
  AlarmCancelMode cancelMode;
  double volume;
  List<bool> repeatDays;

  AlarmItem(
    this.settings,
    this.isEnabled, {
    this.cancelMode = AlarmCancelMode.slider,
    this.volume = 1.0,
    this.repeatDays = const [false, false, false, false, false, false, false],
  });
}

class AlarmHomePage extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkTheme;

  const AlarmHomePage(
      {super.key, required this.onThemeToggle, required this.isDarkTheme});

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  final Uuid _uuid = const Uuid();
  List<AlarmItem> _alarms = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAlarms();

    // 알람이 울릴 때 QuoteScreen으로 이동
    Alarm.ringStream.stream.listen((alarmSettings) async {
      final matchingAlarm = _alarms.firstWhere(
        (alarm) => alarm.settings.id == alarmSettings.id,
        orElse: () => AlarmItem(
          alarmSettings,
          false,
          cancelMode: AlarmCancelMode.slider,
          volume: 1.0,
          repeatDays: List.filled(7, false),
        ),
      );

      if (matchingAlarm.isEnabled) {
        final DateTime alarmStartTime = DateTime.now();

        // 명언 가져오는 서비스
        await _showQuoteScreen(matchingAlarm.settings.id,
            matchingAlarm.cancelMode, matchingAlarm.volume, alarmStartTime);
      } else {
        await Alarm.stop(alarmSettings.id); // 알람 중지
      }
    });
  }

  Future<void> _showQuoteScreen(int alarmId, AlarmCancelMode cancelMode,
      double volume, DateTime alarmStartTime) async {
    final quoteService = QuoteService();
    try {
      final quote = await quoteService.fetchRandomQuote();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuoteScreen(
              quote: quote,
              alarmId: alarmId,
              cancelMode: cancelMode,
              volume: volume,
              alarmStartTime: alarmStartTime,
            ),
          ),
        );
      }
    } catch (e) {
      print('명언을 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> _addAlarm() async {
    final String newAlarmId = _uuid.v4(); // 고유한 ID 생성

    final AlarmSettings newAlarmSettings = AlarmSettings(
      id: newAlarmId.hashCode,
      dateTime: DateTime.now(),
      assetAudioPath: 'assets/sound/alarm_sound.mp3',
      loopAudio: true,
      vibrate: true,
      notificationTitle: '울림소리',
      notificationBody: '',
      enableNotificationOnKill: true,
    );

    final updatedAlarmItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditPage(
          alarmSettings: newAlarmSettings,
          cancelMode: AlarmCancelMode.slider,
          volume: 1.0,
          repeatDays: List.filled(7, false),
        ),
      ),
    );

    if (updatedAlarmItem != null) {
      setState(() {
        _alarms.add(updatedAlarmItem);
      });
      _saveAlarms();

      // 알람이 울리기까지 남은 시간 계산
      final now = DateTime.now();
      final alarmTime = updatedAlarmItem.settings.dateTime;

      final difference = alarmTime.difference(now);
      final totalMinutes =
          (difference.inSeconds / 60).ceil(); // 초 단위까지 올림 후 분 계산
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;

      Fluttertoast.showToast(
        msg: hours > 0
            ? '알람이 약 $hours시간 $minutes분 후에 울립니다.'
            : '알람이 약 $minutes분 후에 울립니다.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
      );
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> alarmList = _alarms.map((alarm) {
      return [
        alarm.settings.id,
        alarm.settings.dateTime.toIso8601String(),
        alarm.isEnabled,
        alarm.cancelMode.index,
        alarm.volume,
        alarm.settings.assetAudioPath,
        alarm.settings.notificationBody,
        alarm.repeatDays.join(","),
      ].join("|");
    }).toList();

    print(alarmList);
    await prefs.setStringList('alarms', alarmList);
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? alarmList = prefs.getStringList('alarms');
    if (alarmList != null) {
      setState(() {
        _alarms = alarmList.map((alarmString) {
          final parts = alarmString.split('|');
          final alarmSettings = AlarmSettings(
            id: int.parse(parts[0]),
            dateTime: DateTime.parse(parts[1]),
            assetAudioPath: parts[5],
            loopAudio: true,
            vibrate: true,
            notificationTitle: '알람',
            notificationBody: parts[6],
            enableNotificationOnKill: true,
          );
          final isEnabled = parts[2] == 'true';
          final cancelMode = AlarmCancelMode.values[int.parse(parts[3])];
          final volume = double.parse(parts[4]);
          final repeatDays =
              parts[7].split(',').map((e) => e == 'true').toList();

          return AlarmItem(
            alarmSettings,
            isEnabled,
            cancelMode: cancelMode,
            volume: volume,
            repeatDays: repeatDays,
          );
        }).toList();
      });
    }
  }

  void _toggleAlarm(AlarmItem alarmItem) {
    setState(() {
      alarmItem.isEnabled = !alarmItem.isEnabled;
      _saveAlarms();
    });
  }

  void deleteAlarm(int index, AlarmItem alarmItem) async {
    await Alarm.stop(alarmItem.settings.id);
    setState(() {
      _alarms.removeAt(index);
    });
    _saveAlarms();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getBody() {
      switch (_selectedIndex) {
        case 0:
          return AlarmListPage(
            alarms: _alarms,
            isDarkTheme: widget.isDarkTheme,
            onToggleAlarm: _toggleAlarm,
            onDeleteAlarm: deleteAlarm,
            onTapAlarm: (index) async {
              final updatedAlarmItem = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmEditPage(
                    alarmSettings: _alarms[index].settings,
                    cancelMode: _alarms[index].cancelMode,
                    volume: _alarms[index].volume,
                    repeatDays: _alarms[index].repeatDays,
                  ),
                ),
              );

              if (updatedAlarmItem != null) {
                setState(() {
                  _alarms[index] = updatedAlarmItem;
                  _saveAlarms();
                });
              }
            },
          );
        case 1:
          return const StatisticsPage();
        case 2:
          return const NewsPage();
        case 3:
          return SettingsPage(isDarkTheme: widget.isDarkTheme);
        default:
          return const Center(child: Text('페이지를 찾을 수 없습니다.'));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('울림소리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              widget.onThemeToggle(!widget.isDarkTheme);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAlarm,
          ),
        ],
      ),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '알람',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '뉴스',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
