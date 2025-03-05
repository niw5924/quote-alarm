import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    Future<void> signUp() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 일치하지 않습니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        await authProvider.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (context.mounted) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기
          Navigator.pop(context); // 회원가입 페이지 닫기
          Navigator.pop(context); // 로그인 페이지 닫기
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면 터치 시 키보드 해제
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/image/gear.gif'),
                Text(
                  'SIGN UP',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: textColor),
                    labelText: 'Email ID',
                    labelStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: textColor),
                    labelText: 'Password',
                    labelStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: textColor),
                    labelText: 'Confirm Password',
                    labelStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BF3B1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
