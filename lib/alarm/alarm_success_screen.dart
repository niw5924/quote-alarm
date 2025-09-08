import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AlarmSuccessScreen extends StatefulWidget {
  const AlarmSuccessScreen({super.key});

  @override
  AlarmSuccessScreenState createState() => AlarmSuccessScreenState();
}

class AlarmSuccessScreenState extends State<AlarmSuccessScreen> {
  late String displayText;

  @override
  void initState() {
    super.initState();
    displayText = getGreetingMessage(); // 초기 메시지 설정
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    switch (hour) {
      case >= 6 && < 12:
        return "좋은 아침!";
      case >= 12 && < 18:
        return "좋은 오후예요!";
      case >= 18 && < 24:
        return "좋은 저녁이에요!";
      case >= 0 && < 6:
        return "늦은 시간까지 고생했어요!";
      default:
        return "시간 정보 오류"; // 예외 처리용
    }
  }

  String getEncouragingMessage() {
    final hour = DateTime.now().hour;

    switch (hour) {
      case >= 6 && < 12:
        return "오늘 하루도 화이팅!";
      case >= 12 && < 18:
        return "남은 하루도 힘내세요!";
      case >= 18 && < 24:
        return "편안한 밤 되세요!";
      case >= 0 && < 6:
        return "충분한 휴식을 취하세요!";
      default:
        return "시간 정보 오류"; // 예외 처리용
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation/lottie_check.json',
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              repeat: false,
              onLoaded: (composition) {
                final halfDuration = composition.duration.inMilliseconds ~/ 2;

                Future.delayed(Duration(milliseconds: halfDuration), () {
                  setState(() {
                    displayText = getEncouragingMessage(); // 두 번째 메시지 설정
                  });
                });

                Future.delayed(composition.duration, () {
                  Navigator.pop(context);
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC1FBE0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
