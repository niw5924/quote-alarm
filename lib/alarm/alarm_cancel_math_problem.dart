import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';

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
    final textColor = isDarkTheme ? Colors.white : Colors.black;

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
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkTheme ? Colors.grey[850] : const Color(0xFFEAD3B2),
            hintText: '정답을 입력하세요',
            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            errorText: errorMessage,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: '확인',
          onPressed: onValidateAnswer,
        ),
      ],
    );
  }
}
