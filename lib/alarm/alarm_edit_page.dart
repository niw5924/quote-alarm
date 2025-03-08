import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_alarm_app_2/home/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmEditPage extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final AlarmCancelMode cancelMode;
  final double volume;
  final List<bool> repeatDays;

  const AlarmEditPage({
    super.key,
    required this.alarmSettings,
    required this.cancelMode,
    required this.volume,
    required this.repeatDays,
  });

  @override
  AlarmEditPageState createState() => AlarmEditPageState();
}

class AlarmEditPageState extends State<AlarmEditPage> {
  late TimeOfDay _selectedTime;
  late TextEditingController _memoController;
  late AlarmCancelMode _cancelMode;
  String _selectedAudioPath = 'assets/sound/alarm_sound.mp3';
  late double _volume;
  List<String> _customSoundFiles = []; // 사용자 사운드 파일 목록
  late List<bool> _repeatDays; // 요일 선택 상태

  final List<String> _defaultSoundFiles = [
    'assets/sound/alarm_cuckoo.mp3',
    'assets/sound/alarm_sound.mp3',
    'assets/sound/alarm_bell.mp3',
    'assets/sound/alarm_gun.mp3',
    'assets/sound/alarm_emergency.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.fromDateTime(widget.alarmSettings.dateTime);
    _memoController =
        TextEditingController(text: widget.alarmSettings.notificationBody);
    _cancelMode = widget.cancelMode;
    _selectedAudioPath = widget.alarmSettings.assetAudioPath;
    _volume = widget.volume;
    _repeatDays = List.from(widget.repeatDays);
    print(_repeatDays);

    _loadCustomSounds(); // 사용자 사운드 파일 불러오기
  }

  Future<void> _loadCustomSounds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSoundFiles = prefs.getStringList('customSoundFiles') ?? [];
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveAlarm() async {
    if (!_repeatDays.contains(true)) {
      Fluttertoast.showToast(
        msg: '요일을 최소 하루 이상 선택해야 합니다.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        textColor: Colors.white,
      );
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
      notificationBody: _memoController.text,
      assetAudioPath: _selectedAudioPath,
    );

    final updatedAlarmItem = AlarmItem(
      updatedAlarmSettings,
      true,
      cancelMode: _cancelMode,
      volume: _volume,
      repeatDays: _repeatDays,
    );

    if (context.mounted) {
      Navigator.pop(context, updatedAlarmItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기본 사운드와 사용자 사운드를 합친 리스트
    final allSoundFiles = [..._defaultSoundFiles, ..._customSoundFiles];
    final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

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
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text(
                  '알람 시간',
                  style: TextStyle(color: Colors.grey),
                ),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
                onTap: _selectTime,
              ),
            ),
            const SizedBox(height: 16),
            const Text('반복 요일', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
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
                            ? const Color(0xFF94FFCB)
                            : const Color(0xFF1A1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: _repeatDays[index]
                              ? const Color(0xFF1A1A1A)
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            const Text('알람 해제 방법', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _getAlignmentForCancelMode(),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 48) / 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF94FFCB),
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
                              '슬라이더',
                              style: TextStyle(
                                color: _cancelMode == AlarmCancelMode.slider
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
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
                              '수학 문제',
                              style: TextStyle(
                                color:
                                    _cancelMode == AlarmCancelMode.mathProblem
                                        ? const Color(0xFF1A1A1A)
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _cancelMode = AlarmCancelMode.puzzle;
                            });
                          },
                          child: Center(
                            child: Text(
                              '퍼즐',
                              style: TextStyle(
                                color: _cancelMode == AlarmCancelMode.puzzle
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
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
                              '음성 인식',
                              style: TextStyle(
                                color: _cancelMode ==
                                        AlarmCancelMode.voiceRecognition
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
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
            const Text('알람 소리 선택', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAudioPath,
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A1A1A),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAudioPath = newValue!;
                    });
                  },
                  items: allSoundFiles
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.contains('assets/sound/')
                            ? value.split('/').last.replaceAll('.mp3', '')
                            : 'Custom: ${value.split('/').last.replaceAll('.mp3', '')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('명언 소리 크기', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.grey),
                  Expanded(
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (newValue) {
                        setState(() {
                          _volume = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('메모', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _memoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.note, color: Colors.grey),
                  labelText: '메모',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  hintText: '알람에 대한 메모를 입력하세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
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
        return const Alignment(-1.0, 0.0); // 첫 번째 위치
      case AlarmCancelMode.mathProblem:
        return const Alignment(-1 / 3, 0.0); // -1/3 위치
      case AlarmCancelMode.puzzle:
        return const Alignment(1 / 3, 0.0); // +1/3 위치
      case AlarmCancelMode.voiceRecognition:
        return const Alignment(1.0, 0.0); // 마지막 위치
    }
  }
}
