import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';

class StarGradeExplanationDialog extends StatelessWidget {
  final int currentMonthDismissals;

  const StarGradeExplanationDialog({
    super.key,
    required this.currentMonthDismissals,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFBEA),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 50, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              '알람 해제 등급 설명',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '이번 달 해제 횟수에 따라\n다음과 같이 등급이 부여됩니다!',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const _GradeRow(
              icon: Icons.star,
              iconColor: Colors.amber,
              text: '10회 이상 해제',
            ),
            const SizedBox(height: 8),
            const _GradeRow(
              icon: Icons.star,
              iconColor: Colors.grey,
              text: '5회 이상 9회 이하 해제',
            ),
            const SizedBox(height: 8),
            const _GradeRow(
              icon: Icons.star,
              iconColor: Colors.brown,
              text: '5회 미만 해제',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAD3B2),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm, size: 24, color: Colors.black),
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
            const SizedBox(height: 16),
            PrimaryButton(
              text: '확인',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }
}
