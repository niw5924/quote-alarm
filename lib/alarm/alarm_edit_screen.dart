import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_alarm_app_2/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/alarm_cancel_mode.dart';
import '../utils/toast_util.dart';

class AlarmEditScreen extends StatefulWidget {
  final bool isDarkTheme;
  final AlarmSettings alarmSettings;
  final List<bool> repeatDays;
  final AlarmCancelMode cancelMode;
  final double quoteVolume;

  const AlarmEditScreen({
    super.key,
    required this.isDarkTheme,
    required this.alarmSettings,
    required this.repeatDays,
    required this.cancelMode,
    required this.quoteVolume,
  });

  @override
  AlarmEditScreenState createState() => AlarmEditScreenState();
}

class AlarmEditScreenState extends State<AlarmEditScreen> {
  late bool _isDarkTheme;
  late TimeOfDay _selectedTime;
  late List<bool> _repeatDays; // 요일 선택 상태
  late AlarmCancelMode _cancelMode;
  final List<String> _defaultSoundFiles = [
    'assets/sound/alarm_cuckoo.mp3',
    'assets/sound/alarm_sound.mp3',
    'assets/sound/alarm_bell.mp3',
    'assets/sound/alarm_gun.mp3',
    'assets/sound/alarm_emergency.mp3',
  ];
  String _selectedAudioPath = 'assets/sound/alarm_sound.mp3';
  List<String> _customSoundFiles = []; // 사용자 사운드 파일 목록
  late double _alarmVolume;
  late double _quoteVolume;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
    _selectedTime = TimeOfDay.fromDateTime(widget.alarmSettings.dateTime);
    _repeatDays = List.from(widget.repeatDays);
    _cancelMode = widget.cancelMode;
    _selectedAudioPath = widget.alarmSettings.assetAudioPath;
    _alarmVolume = widget.alarmSettings.volume!;
    _quoteVolume = widget.quoteVolume;
    _memoController = TextEditingController(
        text: widget.alarmSettings.notificationSettings.body);

    _loadCustomSounds(); // 사용자 사운드 파일 불러오기
  }

  Future<void> _loadCustomSounds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSoundFiles = prefs.getStringList('customSoundFiles') ?? [];
    });
  }

  Future<void> _saveAlarm() async {
    if (!_repeatDays.contains(true)) {
      ToastUtil.showInfo('요일을 최소 하루 이상 선택해야 합니다.');
      return;
    }

    final DateTime now = DateTime.now();
    int currentWeekday = now.weekday % 7; // 일요일(0) ~ 토요일(6)
    int selectedHour = _selectedTime.hour;
    int selectedMinute = _selectedTime.minute;

    // 현재보다 전 시간이면 하루 건너뛰기
    DateTime candidateAlarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedHour,
      selectedMinute,
    );

    if (candidateAlarmTime.isBefore(now)) {
      candidateAlarmTime = candidateAlarmTime.add(const Duration(days: 1));
      currentWeekday = (currentWeekday + 1) % 7; // 다음 요일로 변경
    }

    // 현재 요일부터 반복 요일 중 가장 가까운 요일 찾기
    int daysUntilNextAlarm = 0;

    for (int i = 0; i < 7; i++) {
      int closestRepeatDay = (currentWeekday + i) % 7; // 가장 가까운 반복 요일 찾기

      if (_repeatDays[closestRepeatDay]) {
        daysUntilNextAlarm = i;
        break;
      }
    }

    // 최종 알람 시간 설정
    DateTime updatedAlarmTime =
        candidateAlarmTime.add(Duration(days: daysUntilNextAlarm));

    // 알람 설정 업데이트
    final updatedAlarmSettings = widget.alarmSettings.copyWith(
      dateTime: updatedAlarmTime,
      assetAudioPath: _selectedAudioPath,
      notificationSettings: widget.alarmSettings.notificationSettings.copyWith(
        title: widget.alarmSettings.notificationSettings.title,
        body: _memoController.text,
      ),
      volume: _alarmVolume,
    );

    final updatedAlarmItem = AlarmItem(
      updatedAlarmSettings,
      repeatDays: _repeatDays,
      cancelMode: _cancelMode,
      quoteVolume: _quoteVolume,
    );

    if (context.mounted) {
      Navigator.pop(context, updatedAlarmItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isDarkTheme ? Colors.white : Colors.black;
    final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
    final allSoundFiles = [
      ..._defaultSoundFiles,
      ..._customSoundFiles
    ]; // 기본 사운드와 사용자 사운드를 합친 리스트

    return Scaffold(
      appBar: AppBar(
        title: const Text('알람 편집'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAlarm,
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  '알람 시간',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                trailing: Icon(
                  Icons.access_time,
                  color: textColor,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    showPicker(
                      context: context,
                      value: Time(
                          hour: _selectedTime.hour,
                          minute: _selectedTime.minute),
                      onChange: (newTime) {
                        setState(() {
                          _selectedTime = TimeOfDay(
                              hour: newTime.hour, minute: newTime.minute);
                        });
                      },
                      sunrise: Time(hour: 6, minute: 0),
                      sunset: Time(hour: 18, minute: 0),
                      duskSpanInMinutes: 120,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '반복 요일 설정',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _repeatDays = List.filled(7, false);
                          });
                        },
                        child: Icon(Icons.refresh, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickRepeatButton('매일', List.filled(7, true)),
                      _buildQuickRepeatButton(
                          '평일', [false, true, true, true, true, true, false]),
                      _buildQuickRepeatButton('주말',
                          [true, false, false, false, false, false, true]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _repeatDays[index] = !_repeatDays[index];
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 10,
                          height: MediaQuery.of(context).size.width / 10,
                          decoration: BoxDecoration(
                            color: _repeatDays[index]
                                ? const Color(0xFF6BF3B1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            days[index],
                            style: TextStyle(
                              color:
                                  _repeatDays[index] ? Colors.black : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('알람 해제 방법', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _getAlignmentForCancelMode(),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 48) / 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6BF3B1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _cancelMode = AlarmCancelMode.slider;
                            });
                          },
                          child: Center(
                            child: Text(
                              AlarmCancelMode.slider.label,
                              style: TextStyle(
                                color: _cancelMode == AlarmCancelMode.slider
                                    ? Colors.black
                                    : textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _cancelMode = AlarmCancelMode.mathProblem;
                            });
                          },
                          child: Center(
                            child: Text(
                              AlarmCancelMode.mathProblem.label,
                              style: TextStyle(
                                color:
                                    _cancelMode == AlarmCancelMode.mathProblem
                                        ? Colors.black
                                        : textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _cancelMode = AlarmCancelMode.voiceRecognition;
                            });
                          },
                          child: Center(
                            child: Text(
                              AlarmCancelMode.voiceRecognition.label,
                              style: TextStyle(
                                color: _cancelMode ==
                                        AlarmCancelMode.voiceRecognition
                                    ? Colors.black
                                    : textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('알람 소리 선택', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAudioPath,
              icon: Icon(Icons.arrow_drop_down, color: textColor),
              isExpanded: true,
              dropdownColor:
                  _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
              borderRadius: BorderRadius.circular(10),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAudioPath = newValue!;
                });
              },
              items:
                  allSoundFiles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.contains('assets/sound/')
                        ? value.split('/').last.replaceAll('.mp3', '')
                        : 'Custom: ${value.split('/').last.replaceAll('.mp3', '')}',
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('알람 소리 크기', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.volume_up, color: textColor),
                  Expanded(
                    child: Slider(
                      value: _alarmVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: const Color(0xFF6BF3B1),
                      inactiveColor: Colors.white,
                      onChanged: (newValue) {
                        setState(() {
                          _alarmVolume = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('명언 소리 크기', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.volume_up, color: textColor),
                  Expanded(
                    child: Slider(
                      value: _quoteVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: const Color(0xFF6BF3B1),
                      inactiveColor: Colors.white,
                      onChanged: (newValue) {
                        setState(() {
                          _quoteVolume = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('메모', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    _isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                prefixIcon: Icon(Icons.note, color: textColor),
                labelText: '메모',
                labelStyle: TextStyle(color: textColor),
                hintText: '알람에 대한 메모를 입력하세요.',
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Alignment _getAlignmentForCancelMode() {
    switch (_cancelMode) {
      case AlarmCancelMode.slider:
        return const Alignment(-1.0, 0.0);
      case AlarmCancelMode.mathProblem:
        return const Alignment(0.0, 0.0);
      case AlarmCancelMode.voiceRecognition:
        return const Alignment(1.0, 0.0);
    }
  }

  Widget _buildQuickRepeatButton(String label, List<bool> days) {
    final isSame = _listsAreEqual(_repeatDays, days);
    return GestureDetector(
      onTap: () {
        setState(() {
          _repeatDays = isSame ? List.filled(7, false) : List.from(days);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSame
              ? const Color(0xFF6BF3B1)
              : (_isDarkTheme
                  ? const Color(0xFF151922)
                  : const Color(0xFFF8EDD8)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSame
                ? Colors.black
                : (_isDarkTheme ? Colors.white : Colors.black),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _listsAreEqual(List<bool> a, List<bool> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
