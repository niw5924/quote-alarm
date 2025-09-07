import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_edit_screen.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_list_screen.dart';
import 'package:flutter_alarm_app_2/alarm/quote_screen.dart';
import 'package:flutter_alarm_app_2/news/news_screen.dart';
import 'package:flutter_alarm_app_2/services/quote_service.dart';
import 'package:flutter_alarm_app_2/settings/settings_screen.dart';
import 'package:flutter_alarm_app_2/statistics/statistics_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/alarm_cancel_mode.dart';
import '../models/alarm_item.dart';
import '../utils/time_util.dart';
import '../utils/toast_util.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkTheme;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkTheme,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Uuid _uuid = const Uuid();
  List<AlarmItem> _alarms = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAlarms();

    // 알람이 울릴 때 처리
    Alarm.ringStream.stream.listen((alarmSettings) async {
      debugPrint("RingRingRingRingRingRing");

      final matchingAlarm =
          _alarms.firstWhere((alarm) => alarm.settings.id == alarmSettings.id);

      final DateTime alarmStartTime = DateTime.now();
      final quoteService = QuoteService();
      final quote = await quoteService.fetchRandomQuote();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuoteScreen(
            quote: quote,
            alarmId: matchingAlarm.settings.id,
            cancelMode: matchingAlarm.cancelMode,
            quoteVolume: matchingAlarm.quoteVolume,
            alarmStartTime: alarmStartTime,
          ),
        ),
      );

      // 다음 반복 알람 예약
      await _scheduleNextAlarm(matchingAlarm);
    });
  }

  // 다음 반복 요일에 대한 알람을 등록하는 함수
  Future<void> _scheduleNextAlarm(AlarmItem alarmItem) async {
    final DateTime now = DateTime.now();
    final TimeOfDay alarmTimeOfDay =
        TimeOfDay.fromDateTime(alarmItem.settings.dateTime);

    DateTime? nextAlarmTime;
    int currentWeekday = now.weekday % 7; // 0: 일요일, 6: 토요일

    debugPrint("현재 시간: $now");
    debugPrint("반복 요일 설정: ${alarmItem.repeatDays}");

    for (int i = 0; i < 7; i++) {
      int nextDay = (currentWeekday + i) % 7;
      if (alarmItem.repeatDays[nextDay]) {
        DateTime candidate = DateTime(
          now.year,
          now.month,
          now.day + i,
          alarmTimeOfDay.hour,
          alarmTimeOfDay.minute,
        );

        debugPrint("후보 날짜 확인: $candidate");

        if (candidate.isAfter(now)) {
          nextAlarmTime = candidate;
          debugPrint("선택된 다음 알람 날짜: $nextAlarmTime");
          break;
        }
      }
    }

    // 후보가 없었다면 → 다음 주 같은 요일
    if (nextAlarmTime == null) {
      nextAlarmTime = DateTime(
        now.year,
        now.month,
        now.day + 7,
        alarmTimeOfDay.hour,
        alarmTimeOfDay.minute,
      );
      debugPrint("이번 주에 울릴 요일 없음 → 다음 주 예약: $nextAlarmTime");
    }

    // 기존 알람 ID + 1
    int newAlarmId = alarmItem.settings.id + 1;

    debugPrint(
        "알람 업데이트 - 기존 날짜: ${alarmItem.settings.dateTime} → 새로운 날짜: $nextAlarmTime");
    debugPrint(
        "알람 업데이트 - 기존 ID: ${alarmItem.settings.id} → 새로운 ID: $newAlarmId");

    // 알람 정보 업데이트
    alarmItem.settings = alarmItem.settings.copyWith(
      id: newAlarmId,
      dateTime: nextAlarmTime,
    );

    setState(() {
      _alarms = _alarms.map((a) {
        return (a.settings.id == newAlarmId - 1) ? alarmItem : a;
      }).toList();
    });

    await Alarm.set(alarmSettings: alarmItem.settings);
    debugPrint("알람 등록 완료 - ID: $newAlarmId, 시간: $nextAlarmTime");

    _saveAlarms();
  }

  Future<void> _addAlarm() async {
    final String newAlarmId = _uuid.v4(); // 고유한 ID 생성

    final AlarmSettings newAlarmSettings = AlarmSettings(
      id: newAlarmId.hashCode,
      dateTime: DateTime.now().add(const Duration(minutes: 1)),
      assetAudioPath: 'assets/sound/alarm_sound.mp3',
      notificationSettings: const NotificationSettings(
        title: '울림소리',
        body: '',
      ),
      loopAudio: true,
      vibrate: true,
      volume: 1.0,
      warningNotificationOnKill: true,
    );

    final updatedAlarmItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(
          alarmSettings: newAlarmSettings,
          repeatDays: List.filled(7, false),
          cancelMode: AlarmCancelMode.slider,
          quoteVolume: 1.0,
        ),
      ),
    );

    if (updatedAlarmItem != null) {
      setState(() {
        _alarms.add(updatedAlarmItem);
      });

      await Alarm.set(alarmSettings: updatedAlarmItem.settings);
      _saveAlarms();

      ToastUtil.showInfo(
        TimeUtil.remainingTimeText(updatedAlarmItem.settings.dateTime),
      );
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> alarmList = _alarms.map((alarm) {
      return [
        alarm.settings.id,
        alarm.settings.dateTime.toIso8601String(),
        alarm.repeatDays.join(","),
        alarm.cancelMode.index,
        alarm.settings.assetAudioPath,
        alarm.settings.volume,
        alarm.quoteVolume,
        alarm.settings.notificationSettings.body,
        alarm.isEnabled,
      ].join("|");
    }).toList();

    await prefs.setStringList('alarms', alarmList);
    debugPrint(alarmList.toString());
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? alarmList = prefs.getStringList('alarms');
    debugPrint(alarmList.toString());

    if (alarmList != null) {
      setState(() {
        _alarms = alarmList.map((alarmString) {
          final parts = alarmString.split('|');
          final alarmSettings = AlarmSettings(
            id: int.parse(parts[0]),
            dateTime: DateTime.parse(parts[1]),
            assetAudioPath: parts[4],
            notificationSettings: NotificationSettings(
              title: '울림소리',
              body: parts[7],
            ),
            loopAudio: true,
            vibrate: true,
            volume: double.parse(parts[5]),
            warningNotificationOnKill: true,
          );
          final repeatDays =
              parts[2].split(',').map((e) => e == 'true').toList();
          final cancelMode = AlarmCancelMode.values[int.parse(parts[3])];
          final quoteVolume = double.parse(parts[6]);
          final isEnabled = parts[8] == 'true';

          return AlarmItem(
            alarmSettings,
            repeatDays: repeatDays,
            cancelMode: cancelMode,
            quoteVolume: quoteVolume,
            isEnabled: isEnabled,
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

  @override
  Widget build(BuildContext context) {
    Widget getBody() {
      switch (_selectedIndex) {
        case 0:
          return AlarmListScreen(
            isDarkTheme: widget.isDarkTheme,
            alarms: _alarms,
            onTapAlarm: (index) async {
              final updatedAlarmItem = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmEditScreen(
                    alarmSettings: _alarms[index].settings,
                    repeatDays: _alarms[index].repeatDays,
                    cancelMode: _alarms[index].cancelMode,
                    quoteVolume: _alarms[index].quoteVolume,
                  ),
                ),
              );

              if (updatedAlarmItem != null) {
                setState(() {
                  _alarms[index] = AlarmItem(
                    updatedAlarmItem.settings,
                    repeatDays: updatedAlarmItem.repeatDays,
                    cancelMode: updatedAlarmItem.cancelMode,
                    quoteVolume: updatedAlarmItem.quoteVolume,
                    isEnabled: _alarms[index].isEnabled,
                  );
                });

                if (_alarms[index].isEnabled) {
                  await Alarm.set(alarmSettings: updatedAlarmItem.settings);
                  ToastUtil.showInfo(
                    TimeUtil.remainingTimeText(
                      updatedAlarmItem.settings.dateTime,
                    ),
                  );
                }

                _saveAlarms();
              }
            },
            onToggleAlarm: _toggleAlarm,
            onDeleteAlarm: deleteAlarm,
          );
        case 1:
          return const StatisticsScreen();
        case 2:
          return const NewsScreen();
        case 3:
          return const SettingsScreen();
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
