import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MathDifficultyDialog extends StatefulWidget {
  const MathDifficultyDialog({super.key});

  @override
  MathDifficultyDialogState createState() => MathDifficultyDialogState();
}

class MathDifficultyDialogState extends State<MathDifficultyDialog> {
  String _selectedDifficulty = 'easy';

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
  }

  Future<void> _loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDifficulty = prefs.getString('mathDifficulty') ?? 'easy';
    });
  }

  Future<void> _saveDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mathDifficulty', difficulty);
    setState(() {
      _selectedDifficulty = difficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFBEA),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calculate, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              '수학 문제 난이도 설정',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _DifficultyCard(
              icon: Icons.looks_one,
              title: '하 (한 자리수 덧셈)',
              color: Colors.lightGreenAccent,
              isSelected: _selectedDifficulty == 'easy',
              onTap: () {
                HapticFeedback.lightImpact();
                _saveDifficulty('easy');
              },
            ),
            const SizedBox(height: 8),
            _DifficultyCard(
              icon: Icons.looks_two,
              title: '중 (두 자리수 덧셈)',
              color: Colors.orangeAccent,
              isSelected: _selectedDifficulty == 'medium',
              onTap: () {
                HapticFeedback.lightImpact();
                _saveDifficulty('medium');
              },
            ),
            const SizedBox(height: 8),
            _DifficultyCard(
              icon: Icons.looks_3,
              title: '상 (세 자리수 덧셈)',
              color: Colors.redAccent,
              isSelected: _selectedDifficulty == 'hard',
              onTap: () {
                HapticFeedback.lightImpact();
                _saveDifficulty('hard');
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: '확인',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? color.withValues(alpha: 0.9) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
