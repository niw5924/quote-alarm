import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteLanguageDialog extends StatefulWidget {
  const QuoteLanguageDialog({super.key});

  @override
  QuoteLanguageDialogState createState() => QuoteLanguageDialogState();
}

class QuoteLanguageDialogState extends State<QuoteLanguageDialog> {
  String _selectedLanguage = 'ko';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('quoteLanguage') ?? 'ko';
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
              icon: Icons.translate,
              title: '한국어 (Korean)',
              value: 'ko',
              color: Colors.orangeAccent,
            ),
            _buildLanguageCard(
              icon: Icons.language,
              title: '영어 (English)',
              value: 'en',
              color: Colors.lightBlueAccent,
            ),
            const SizedBox(height: 20),
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

  Widget _buildLanguageCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _saveLanguage(value);
      },
      child: Card(
        color: _selectedLanguage == value
            ? color.withValues(alpha: 0.9)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _selectedLanguage == value ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
