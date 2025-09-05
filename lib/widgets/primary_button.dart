import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final double? width;
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    this.width,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 24.0,
          ),
          backgroundColor: const Color(0xFF6BF3B1),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
