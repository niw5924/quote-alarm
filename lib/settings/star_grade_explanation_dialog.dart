import 'package:flutter/material.dart';

class StarGradeExplanationDialog extends StatelessWidget {
  final int currentMonthDismissals;

  const StarGradeExplanationDialog({
    super.key,
    required this.currentMonthDismissals,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: const Color(0xFFFFFBEA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 50,
              color: Colors.amber,
            ),
            const SizedBox(height: 15),
            const Text(
              '알람 해제 등급 설명',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '이번 달 해제 횟수에 따라\n다음과 같이 등급이 부여됩니다!',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildGradeRow(
                Icons.star, Colors.amber, '10회 이상 해제', Colors.black87),
            const SizedBox(height: 12),
            _buildGradeRow(
                Icons.star, Colors.grey, '5회 이상 9회 이하 해제', Colors.black87),
            const SizedBox(height: 12),
            _buildGradeRow(
                Icons.star, Colors.brown, '5회 미만 해제', Colors.black87),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDDEBF7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm, size: 24, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    '이번 달 해제 횟수: $currentMonthDismissals회',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6BF3B1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeRow(
      IconData icon, Color color, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ],
    );
  }
}
