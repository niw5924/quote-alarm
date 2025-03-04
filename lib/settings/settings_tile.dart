import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey.withValues(alpha: 0.2),
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconBackgroundColor,
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
