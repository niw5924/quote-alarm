import 'package:flutter/material.dart';
import 'package:flutter_puzzle_vcode/flutter_puzzle_vcode.dart';

class AlarmCancelPuzzle extends StatelessWidget {
  final VoidCallback onPuzzleSuccess;

  const AlarmCancelPuzzle({
    super.key,
    required this.onPuzzleSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return FlutterPuzzleVCode(
              onSuccess: () {
                onPuzzleSuccess(); // 퍼즐 성공 시 콜백 호출
                Navigator.pop(context); // 다이얼로그 닫기
              },
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6BF3B1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        '퍼즐 해제',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}
