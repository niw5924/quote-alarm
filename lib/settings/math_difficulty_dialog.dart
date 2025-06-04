import 'package:flutter/material.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDifficulty = prefs.getString('mathDifficulty') ?? 'easy';
    });
  }

  Future<void> _saveDifficulty(String difficulty) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mathDifficulty', difficulty);
    setState(() {
      _selectedDifficulty = difficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: const Color(0xFFFFFBEA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calculate,
              size: 50,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 15),
            const Text(
              '수학 문제 난이도 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _buildDifficultyCard(
              icon: Icons.looks_one,
              title: '하 (한 자리수 덧셈)',
              value: 'easy',
              color: Colors.lightGreenAccent,
            ),
            _buildDifficultyCard(
              icon: Icons.looks_two,
              title: '중 (두 자리수 덧셈)',
              value: 'medium',
              color: Colors.orangeAccent,
            ),
            _buildDifficultyCard(
              icon: Icons.looks_3,
              title: '상 (세 자리수 덧셈)',
              value: 'hard',
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6BF3B1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _saveDifficulty(value);
      },
      child: Card(
        color: _selectedDifficulty == value
            ? color.withValues(alpha: 0.9)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedDifficulty == value
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
