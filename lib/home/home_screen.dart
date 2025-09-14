import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_edit_screen.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_list_screen.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_quote_screen.dart';
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
      debugPrint('RingRingRingRingRingRing');

      final matchingAlarm = _alarms
          .firstWhere((alarm) => alarm.alarmSettings.id == alarmSettings.id);

      final DateTime alarmStartTime = DateTime.now();
      final quoteService = QuoteService();
      final quote = await quoteService.fetchRandomQuote();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmQuoteScreen(
            quote: quote,
            alarmId: matchingAlarm.alarmSettings.id,
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
        TimeOfDay.fromDateTime(alarmItem.alarmSettings.dateTime);

    DateTime? nextAlarmTime;
    int currentWeekday = now.weekday % 7; // 0: 일요일, 6: 토요일

    debugPrint('현재 시간: $now');
    debugPrint('반복 요일 설정: ${alarmItem.repeatDays}');

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

        debugPrint('후보 날짜 확인: $candidate');

        if (candidate.isAfter(now)) {
          nextAlarmTime = candidate;
          debugPrint('선택된 다음 알람 날짜: $nextAlarmTime');
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
      debugPrint('이번 주에 울릴 요일 없음 → 다음 주 예약: $nextAlarmTime');
    }

    // 기존 알람 ID + 1
    int newAlarmId = alarmItem.alarmSettings.id + 1;

    debugPrint(
        '알람 업데이트 - 기존 날짜: ${alarmItem.alarmSettings.dateTime} → 새로운 날짜: $nextAlarmTime');
    debugPrint(
        '알람 업데이트 - 기존 ID: ${alarmItem.alarmSettings.id} → 새로운 ID: $newAlarmId');

    // 알람 정보 업데이트
    alarmItem.alarmSettings = alarmItem.alarmSettings.copyWith(
      id: newAlarmId,
      dateTime: nextAlarmTime,
    );

    setState(() {
      _alarms = _alarms.map((a) {
        return (a.alarmSettings.id == newAlarmId - 1) ? alarmItem : a;
      }).toList();
    });

    await Alarm.set(alarmSettings: alarmItem.alarmSettings);
    debugPrint('알람 등록 완료 - ID: $newAlarmId, 시간: $nextAlarmTime');

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
          cancelMode: AlarmCancelMode.slide,
          quoteVolume: 1.0,
        ),
      ),
    );

    if (updatedAlarmItem != null) {
      setState(() {
        _alarms.add(updatedAlarmItem);
      });

      await Alarm.set(alarmSettings: updatedAlarmItem.alarmSettings);
      _saveAlarms();

      ToastUtil.showInfo(
        TimeUtil.remainingTimeText(updatedAlarmItem.alarmSettings.dateTime),
      );
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmList = _alarms
        .map((alarm) => jsonEncode({
              'id': alarm.alarmSettings.id,
              'dateTime': alarm.alarmSettings.dateTime.toString(),
              'repeatDays': alarm.repeatDays,
              'cancelMode': alarm.cancelMode.key,
              'assetAudioPath': alarm.alarmSettings.assetAudioPath,
              'volume': alarm.alarmSettings.volume,
              'quoteVolume': alarm.quoteVolume,
              'notificationBody': alarm.alarmSettings.notificationSettings.body,
              'isEnabled': alarm.isEnabled,
            }))
        .toList();
    await prefs.setStringList('alarms', alarmList);
    debugPrint(alarmList.toString());
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? alarmList = prefs.getStringList('alarms');
    debugPrint(alarmList.toString());
    if (alarmList != null && alarmList.isNotEmpty) {
      setState(() {
        _alarms = alarmList.map((alarmString) {
          final parts = jsonDecode(alarmString);

          final alarmSettings = AlarmSettings(
            id: parts['id'],
            dateTime: DateTime.parse(parts['dateTime']),

            /// 문자열을 DateTime 객체로 변환
            assetAudioPath: parts['assetAudioPath'],
            notificationSettings: NotificationSettings(
              title: '울림소리',
              body: parts['notificationBody'],
            ),
            loopAudio: true,
            vibrate: true,
            volume: parts['volume'],
            warningNotificationOnKill: true,
          );

          return AlarmItem(
            alarmSettings: alarmSettings,
            repeatDays: List<bool>.from(parts['repeatDays']),

            /// JSON 배열(List<dynamic>)을 List<bool>로 변환
            cancelMode: AlarmCancelMode.fromKey(parts['cancelMode']),
            quoteVolume: parts['quoteVolume'],
            isEnabled: parts['isEnabled'],
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
      if (alarmItem.alarmSettings.dateTime.isBefore(now)) {
        await _scheduleNextAlarm(alarmItem);
      } else {
        await Alarm.set(alarmSettings: alarmItem.alarmSettings);
      }
    } else {
      await Alarm.stop(alarmItem.alarmSettings.id);
    }

    _saveAlarms();
  }

  void deleteAlarm(int index, AlarmItem alarmItem) async {
    await Alarm.stop(alarmItem.alarmSettings.id);
    setState(() {
      _alarms.removeAt(index);
    });
    _saveAlarms();
  }

  @override
  Widget build(BuildContext context) {
    Widget getBody() {
      switch (_selectedIndex) {
        case 0:
          return AlarmListScreen(
            alarms: _alarms,
            onTapAlarm: (index) async {
              final updatedAlarmItem = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmEditScreen(
                    alarmSettings: _alarms[index].alarmSettings,
                    repeatDays: _alarms[index].repeatDays,
                    cancelMode: _alarms[index].cancelMode,
                    quoteVolume: _alarms[index].quoteVolume,
                  ),
                ),
              );

              if (updatedAlarmItem != null) {
                setState(() {
                  _alarms[index] = AlarmItem(
                    alarmSettings: updatedAlarmItem.alarmSettings,
                    repeatDays: updatedAlarmItem.repeatDays,
                    cancelMode: updatedAlarmItem.cancelMode,
                    quoteVolume: updatedAlarmItem.quoteVolume,
                    isEnabled: _alarms[index].isEnabled,
                  );
                });

                if (_alarms[index].isEnabled) {
                  await Alarm.set(
                      alarmSettings: updatedAlarmItem.alarmSettings);
                  ToastUtil.showInfo(
                    TimeUtil.remainingTimeText(
                      updatedAlarmItem.alarmSettings.dateTime,
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
      ),
    );
  }
}
