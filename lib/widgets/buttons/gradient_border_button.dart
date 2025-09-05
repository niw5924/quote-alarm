import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class GradientBorderButton extends StatelessWidget {
  final double? width;
  final String text;
  final VoidCallback onPressed;

  const GradientBorderButton({
    super.key,
    this.width,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: const GradientBoxBorder(
          gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
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
