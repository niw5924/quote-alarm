import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_success_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../constants/alarm_cancel_mode.dart';
import '../models/quote_item.dart';
import '../providers/auth_provider.dart';
import '../utils/time_util.dart';
import 'cancel/alarm_cancel_math_problem_screen.dart';
import 'cancel/alarm_cancel_slide_screen.dart';
import 'cancel/alarm_cancel_voice_recognition_screen.dart';

class AlarmQuoteScreen extends StatefulWidget {
  final QuoteItem quote;
  final int alarmId;
  final AlarmCancelMode cancelMode;
  final double quoteVolume;
  final DateTime alarmStartTime;

  const AlarmQuoteScreen({
    super.key,
    required this.quote,
    required this.alarmId,
    required this.cancelMode,
    required this.quoteVolume,
    required this.alarmStartTime,
  });

  @override
  AlarmQuoteScreenState createState() => AlarmQuoteScreenState();
}

class AlarmQuoteScreenState extends State<AlarmQuoteScreen> {
  /// TTS
  final FlutterTts _flutterTts = FlutterTts();

  /// 슬라이드 관련 상태
  double _slideValue = 0;

  /// 수학 문제 관련 상태
  late int _firstNumber;
  late int _secondNumber;
  final TextEditingController _answerController = TextEditingController();
  String? _errorMessage;
  bool _isMathProblemGenerated = false;

  /// 음성 인식 관련 상태
  final SpeechToText _speechToText = SpeechToText();
  late String _randomWord;
  bool _isListening = false;
  String _lastWords = '';
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _speakQuote();
    if (widget.cancelMode == AlarmCancelMode.mathProblem) {
      _generateMathProblem();
    }
    if (widget.cancelMode == AlarmCancelMode.voiceRecognition) {
      _generateRandomWord();
    }
  }

  @override
  void dispose() {
    Alarm.stop(widget.alarmId); // 알람 중단
    _flutterTts.stop(); // TTS 중단
    _answerController.dispose(); // 텍스트 컨트롤러 정리
    super.dispose();
  }

  Future<void> cancelAlarm() async {
    await Alarm.stop(widget.alarmId); // 알람 중단
    await _flutterTts.stop(); // TTS 중단
    try {
      await _saveAlarmDismissalRecord(); // 해제 기록 저장
    } catch (e) {
      debugPrint("Firebase 저장 실패: $e");
    }
    debugPrint('알람이 취소되었습니다.');

    if (!mounted) return;

    // 알람 성공 스크린으로 이동
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AlarmSuccessScreen(),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _speakQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('quoteLanguage') ?? 'ko';

    await _flutterTts.setLanguage(language == 'ko' ? "ko-KR" : "en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(widget.quoteVolume);
    await _flutterTts.speak('"${widget.quote.quote}" - ${widget.quote.author}');
  }

  Future<void> _generateMathProblem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String difficulty = prefs.getString('mathDifficulty') ?? 'easy';

    final random = Random();
    setState(() {
      switch (difficulty) {
        case 'easy':
          _firstNumber = 1 + random.nextInt(10);
          _secondNumber = 1 + random.nextInt(10);
          break;
        case 'medium':
          _firstNumber = 10 + random.nextInt(90);
          _secondNumber = 10 + random.nextInt(90);
          break;
        case 'hard':
          _firstNumber = 100 + random.nextInt(900);
          _secondNumber = 100 + random.nextInt(900);
          break;
      }
      _isMathProblemGenerated = true;
    });
  }

  void _validateAnswer() {
    final answer = int.tryParse(_answerController.text);
    if (answer == _firstNumber + _secondNumber) {
      cancelAlarm();
    } else {
      setState(() {
        _errorMessage = "틀렸습니다. 다시 시도하세요!";
      });
    }
  }

  void _generateRandomWord() {
    const wordList = ['happy', 'nice', 'good', 'smile', 'love'];
    final random = Random();
    _randomWord = wordList[random.nextInt(wordList.length)];
  }

  // 말하기 버튼 누르기
  void _startListening() async {
    bool hasPermission = await _speechToText.initialize();
    if (!hasPermission) {
      return;
    }

    setState(() {
      _lastWords = ""; // 초기화
      _resultMessage = ""; // 결과 메시지 초기화
      _isListening = true; // 마이크 활성화 상태
    });

    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          _lastWords = result.recognizedWords; // 실시간으로 텍스트 업데이트
        });
      },
      listenOptions: SpeechListenOptions(
        partialResults: true, // 부분 결과 반환
      ),
      localeId: 'en-US', // 언어 설정
    );
  }

  void _stopListening() async {
    await _speechToText.stop();

    setState(() {
      _isListening = false;
    });

    if (_lastWords.toLowerCase() == _randomWord.toLowerCase()) {
      setState(() {
        _resultMessage = '정답입니다!';
      });

      Future.delayed(const Duration(seconds: 1), () {
        cancelAlarm();
      });
    } else {
      setState(() {
        _resultMessage = '틀렸습니다. 다시 시도하세요.';
      });
    }
  }

  // Firebase에 알람 해제 기록을 저장하는 메서드
  Future<void> _saveAlarmDismissalRecord() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid;

    if (uid == null) return; // 로그인되지 않은 경우 저장하지 않음

    // 날짜 및 시간 포맷
    String formattedDate = TimeUtil.formatDate(DateTime.now());
    String alarmStartTimeFormatted = TimeUtil.formatTime(widget.alarmStartTime);
    String alarmEndTimeFormatted = TimeUtil.formatTime(DateTime.now());
    int duration = DateTime.now().difference(widget.alarmStartTime).inSeconds;

    // 저장할 데이터
    Map<String, dynamic> alarmData = {
      'cancelMode': widget.cancelMode.key,
      'alarmStartTime': alarmStartTimeFormatted,
      'alarmEndTime': alarmEndTimeFormatted,
      'duration': duration,
    };

    // Firestore에 알람 해제 기록 저장
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'alarmDismissals': {
        formattedDate: {'${widget.alarmId}': alarmData}
      }
    }, SetOptions(merge: true)).timeout(
      const Duration(seconds: 1),
    ); // 타임아웃 설정(인터넷 연결 X)
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 제어
      child: Scaffold(
        appBar: AppBar(
          title: const Text('오늘의 명언'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          // 화면을 터치하면 키보드가 닫히도록 설정
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '"${widget.quote.quote}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '- ${widget.quote.author}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCancelModeUI(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelModeUI() {
    switch (widget.cancelMode) {
      case AlarmCancelMode.slide:
        return AlarmCancelSlideScreen(
          slideValue: _slideValue,
          onSlideChanged: (value) => setState(() => _slideValue = value),
          onSlideComplete: cancelAlarm,
        );
      case AlarmCancelMode.mathProblem:
        return _isMathProblemGenerated
            ? AlarmCancelMathProblemScreen(
                firstNumber: _firstNumber,
                secondNumber: _secondNumber,
                answerController: _answerController,
                errorMessage: _errorMessage,
                onValidateAnswer: _validateAnswer,
              )
            : const CircularProgressIndicator();
      case AlarmCancelMode.voiceRecognition:
        return AlarmCancelVoiceRecognitionScreen(
          randomWord: _randomWord,
          isListening: _isListening,
          lastWords: _lastWords,
          resultMessage: _resultMessage,
          onStartListening: _startListening,
          onStopListening: _stopListening,
        );
    }
  }
}
