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

  const AlarmHomePage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkTheme,
  });

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

    // 알람이 울릴 때 처리
    Alarm.ringStream.stream.listen((alarmSettings) async {
      print("RingRingRingRingRingRing");
      final matchingAlarm =
          _alarms.firstWhere((alarm) => alarm.settings.id == alarmSettings.id);

      // 명언 화면 표시
      final DateTime alarmStartTime = DateTime.now();
      await _showQuoteScreen(
        matchingAlarm.settings.id,
        matchingAlarm.cancelMode,
        matchingAlarm.volume,
        alarmStartTime,
      );

      // 다음 반복 알람 예약
      await _scheduleNextAlarm(matchingAlarm);
    });
  }

  // 다음 반복 요일에 대한 알람을 등록하는 함수
  Future<void> _scheduleNextAlarm(AlarmItem alarmItem) async {
    final DateTime now = DateTime.now();
    int currentWeekday = now.weekday % 7; // 현재 요일 (0: 일요일, 6: 토요일)

    // 기본적으로 다음 주 같은 요일로 설정
    int daysUntilNextAlarm = 7;

    // 현재 요일 이후 반복 요일 찾기
    for (int i = 1; i < 7; i++) {
      int nextDay = (currentWeekday + i) % 7;
      if (alarmItem.repeatDays[nextDay]) {
        daysUntilNextAlarm = i;
        break;
      }
    }

    // 오늘이 반복 요일이고, 다른 반복 요일이 없으면 +7일
    if (alarmItem.repeatDays[currentWeekday] && daysUntilNextAlarm == 7) {
      daysUntilNextAlarm = 7;
    }

    // 다음 울릴 날짜 업데이트
    DateTime nextAlarmTime =
        alarmItem.settings.dateTime.add(Duration(days: daysUntilNextAlarm));

    // 기존 ID를 1 증가시켜 새롭게 설정
    int newAlarmId = alarmItem.settings.id + 1;

    print(
        "알람 업데이트 - 기존 날짜: ${alarmItem.settings.dateTime} → 새로운 날짜: $nextAlarmTime");
    print("알람 업데이트 - 기존 ID: ${alarmItem.settings.id} → 새로운 ID: $newAlarmId");

    // 기존 알람을 유지하면서 ID와 dateTime을 변경
    alarmItem.settings = alarmItem.settings.copyWith(
      id: newAlarmId,
      dateTime: nextAlarmTime,
    );

    setState(() {
      // 기존 알람을 업데이트 (ID 변경 반영)
      _alarms = _alarms.map((a) {
        return (a.settings.id == newAlarmId - 1) ? alarmItem : a;
      }).toList();
    });

    // 업데이트된 알람을 시스템에 등록
    await Alarm.set(alarmSettings: alarmItem.settings);
    print("알람 등록 - 새로운 ID: $newAlarmId, 울릴 시간: $nextAlarmTime");

    _saveAlarms();
  }

  Future<void> _showQuoteScreen(
    int alarmId,
    AlarmCancelMode cancelMode,
    double volume,
    DateTime alarmStartTime,
  ) async {
    final quoteService = QuoteService();
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

      await Alarm.set(alarmSettings: updatedAlarmItem.settings);
      _saveAlarms();

      _showRemainingTimeToast(updatedAlarmItem.settings.dateTime);
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

    await prefs.setStringList('alarms', alarmList);
    print(alarmList);
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? alarmList = prefs.getStringList('alarms');
    print(alarmList);

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

  void _toggleAlarm(AlarmItem alarmItem) async {
    setState(() {
      alarmItem.isEnabled = !alarmItem.isEnabled;
    });

    if (alarmItem.isEnabled) {
      DateTime now = DateTime.now();

      // 현재 시간이 알람 시간보다 이전이면 바로 등록
      if (alarmItem.settings.dateTime.isBefore(now)) {
        await _scheduleNextAlarm(alarmItem);
      } else {
        await Alarm.set(alarmSettings: alarmItem.settings);
      }
    } else {
      await Alarm.stop(alarmItem.settings.id);
    }

    _saveAlarms();
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

  void _showRemainingTimeToast(DateTime updatedAlarmTime) {
    final DateTime now = DateTime.now();
    final difference = updatedAlarmTime.difference(now);
    final totalMinutes = (difference.inSeconds / 60).ceil();
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
                  _alarms[index] = AlarmItem(
                    updatedAlarmItem.settings,
                    _alarms[index].isEnabled,
                    cancelMode: updatedAlarmItem.cancelMode,
                    volume: updatedAlarmItem.volume,
                    repeatDays: updatedAlarmItem.repeatDays,
                  );
                });

                if (_alarms[index].isEnabled) {
                  await Alarm.set(alarmSettings: updatedAlarmItem.settings);
                  _showRemainingTimeToast(updatedAlarmItem.settings.dateTime);
                }

                _saveAlarms();
              }
            },
          );
        case 1:
          return const StatisticsPage();
        case 2:
          return const NewsPage();
        case 3:
          return const SettingsPage();
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
