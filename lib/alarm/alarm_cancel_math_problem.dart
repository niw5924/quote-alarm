import 'package:flutter/material.dart';

class AlarmCancelMathProblem extends StatelessWidget {
  final int firstNumber;
  final int secondNumber;
  final TextEditingController answerController;
  final String? errorMessage;
  final VoidCallback onValidateAnswer;

  const AlarmCancelMathProblem({
    super.key,
    required this.firstNumber,
    required this.secondNumber,
    required this.answerController,
    this.errorMessage,
    required this.onValidateAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          '$firstNumber + $secondNumber = ?',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: answerController,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
            hintText: '정답을 입력하세요',
            hintStyle: TextStyle(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            errorText: errorMessage,
          ),
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onValidateAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6BF3B1),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            '확인',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
