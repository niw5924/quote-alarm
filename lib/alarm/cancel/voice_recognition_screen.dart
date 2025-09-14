import 'package:flutter/material.dart';

import '../../widgets/buttons/themed_icon_button.dart';

class VoiceRecognitionScreen extends StatelessWidget {
  final String randomWord;
  final bool isListening;
  final String lastWords;
  final String resultMessage;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;

  const VoiceRecognitionScreen({
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          ThemedIconButton(
            icon: isListening ? Icons.mic_off : Icons.mic,
            label: isListening ? '그만하기' : '말하기',
            onPressed: isListening ? onStopListening : onStartListening,
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
          if (resultMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              resultMessage,
              style: TextStyle(
                fontSize: 18,
                color: (resultMessage == '정답입니다!') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
