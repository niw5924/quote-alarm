import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MathDifficultyPopup extends StatefulWidget {
  const MathDifficultyPopup({super.key});

  @override
  _MathDifficultyPopupState createState() => _MathDifficultyPopupState();
}

class _MathDifficultyPopupState extends State<MathDifficultyPopup> {
  String _selectedDifficulty = 'easy'; // 기본 난이도는 'easy'로 설정

  @override
  void initState() {
    super.initState();
    _loadDifficulty(); // SharedPreferences에서 저장된 값을 불러옴
  }

  // SharedPreferences에서 저장된 난이도 불러오기
  Future<void> _loadDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDifficulty = prefs.getString('mathDifficulty') ?? 'easy';
    });
  }

  // 선택한 난이도를 SharedPreferences에 저장
  Future<void> _saveDifficulty(String difficulty) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mathDifficulty', difficulty);
    setState(() {
      _selectedDifficulty = difficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFFFFBEA),
      // 부드러운 배경 색상
      title: const Text(
        '수학 문제 난이도 설정',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 팝업 닫기
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF6BF3B1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            '확인',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 난이도 선택 카드 빌드 메서드
  Widget _buildDifficultyCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _saveDifficulty(value); // 난이도 선택 시 SharedPreferences에 저장
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
