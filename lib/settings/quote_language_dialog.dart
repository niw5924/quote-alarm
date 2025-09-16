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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('quoteLanguage') ?? 'ko';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              '명언 언어 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _LanguageCard(
              icon: Icons.translate,
              title: '한국어 (Korean)',
              color: Colors.orangeAccent,
              isSelected: _selectedLanguage == 'ko',
              onTap: () {
                HapticFeedback.lightImpact();
                _saveLanguage('ko');
              },
            ),
            const SizedBox(height: 8),
            _LanguageCard(
              icon: Icons.language,
              title: '영어 (English)',
              color: Colors.lightBlueAccent,
              isSelected: _selectedLanguage == 'en',
              onTap: () {
                HapticFeedback.lightImpact();
                _saveLanguage('en');
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
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
