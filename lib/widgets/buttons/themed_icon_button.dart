import 'package:flutter/material.dart';

class ThemedIconButton extends StatelessWidget {
  final double? width;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ThemedIconButton({
    super.key,
    this.width,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 24.0,
          ),
          backgroundColor:
              isDarkMode ? Colors.grey[850] : const Color(0xFFEAD3B2),
        ),
      ),
    );
  }
}
