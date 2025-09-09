import 'package:alarm/alarm.dart';
import 'package:flutter_alarm_app_2/constants/alarm_cancel_mode.dart';

class AlarmItem {
  AlarmSettings alarmSettings;
  List<bool> repeatDays;
  AlarmCancelMode cancelMode;
  double quoteVolume;
  bool isEnabled;

  AlarmItem({
    required this.alarmSettings,
    this.repeatDays = const [false, false, false, false, false, false, false],
    this.cancelMode = AlarmCancelMode.slide,
    this.quoteVolume = 1.0,
    this.isEnabled = true,
  });
}
