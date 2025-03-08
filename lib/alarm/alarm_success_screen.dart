import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AlarmSuccessScreen extends StatefulWidget {
  const AlarmSuccessScreen({super.key});

  @override
  AlarmSuccessScreenState createState() => AlarmSuccessScreenState();
}

class AlarmSuccessScreenState extends State<AlarmSuccessScreen> {
  String displayText = '좋은 아침!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/animation/lottie_check.json',
                repeat: false, // 애니메이션 반복 안 함
                onLoaded: (composition) {
                  final halfDuration = composition.duration.inMilliseconds ~/ 2;

                  // 첫 번째 절반: "좋은 아침!" 표시
                  Future.delayed(Duration(milliseconds: halfDuration), () {
                    if (mounted) {
                      setState(() {
                        displayText = '오늘 하루도 화이팅!';
                      });
                    }
                  });

                  // 전체 애니메이션 시간 후 화면 닫기
                  Future.delayed(composition.duration, () {
                    if (mounted) Navigator.pop(context);
                  });
                },
              ),
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
