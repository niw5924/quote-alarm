import 'package:flutter/material.dart';

class AlarmCancelVoiceRecognition extends StatelessWidget {
  final String randomWord;
  final bool isListening;
  final String lastWords;
  final String resultMessage;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;

  const AlarmCancelVoiceRecognition({
    super.key,
    required this.randomWord,
    required this.isListening,
    required this.lastWords,
    required this.resultMessage,
    required this.onStartListening,
    required this.onStopListening,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "랜덤 단어",
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(width: 8),
            Icon(Icons.double_arrow, size: 24, color: textColor),
            const SizedBox(width: 8),
            Text(
              randomWord,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: isListening ? onStopListening : onStartListening,
          icon: Icon(
            isListening ? Icons.mic_off : Icons.mic,
            color: Colors.black,
          ),
          label: Text(
            isListening ? '그만하기' : '말하기',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6BF3B1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "들린 단어",
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(width: 8),
            Icon(Icons.double_arrow, size: 24, color: textColor),
            const SizedBox(width: 8),
            Text(
              lastWords,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (resultMessage.isNotEmpty)
          Text(
            resultMessage,
            style: TextStyle(
              fontSize: 18,
              color: (resultMessage == '정답입니다!') ? Colors.green : Colors.red,
            ),
          ),
      ],
    );
  }
}
