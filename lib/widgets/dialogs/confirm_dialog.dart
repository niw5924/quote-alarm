import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/grey_text_button.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';

class ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFFFFFBEA),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.redAccent),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GreyTextButton(
                  text: cancelText,
                  onPressed: () => Navigator.pop(context, false),
                ),
                PrimaryButton(
                  text: confirmText,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
