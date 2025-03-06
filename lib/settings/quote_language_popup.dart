import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteLanguagePopup extends StatefulWidget {
  const QuoteLanguagePopup({super.key});

  @override
  _QuoteLanguagePopupState createState() => _QuoteLanguagePopupState();
}

class _QuoteLanguagePopupState extends State<QuoteLanguagePopup> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('quoteLanguage') ?? 'en';
    });
  }

  Future<void> _saveLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('quoteLanguage', language);
    setState(() {
      _selectedLanguage = language;
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
              Icons.translate,
              size: 50,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 15),
            const Text(
              '명언 언어 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _buildLanguageCard(
              icon: Icons.language,
              title: '영어 (English)',
              value: 'en',
              color: Colors.lightBlueAccent,
            ),
            _buildLanguageCard(
              icon: Icons.translate,
              title: '한국어 (Korean)',
              value: 'ko',
              color: Colors.orangeAccent,
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

  Widget _buildLanguageCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _saveLanguage(value);
      },
      child: Card(
        color: _selectedLanguage == value
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
                  color: _selectedLanguage == value
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
