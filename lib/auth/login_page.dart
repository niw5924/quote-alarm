import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // 현재 테마 모드 확인
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    Future<void> signIn() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 로딩 인디케이터 표시
      showDialog(
        context: context,
        barrierDismissible: false, // 사용자가 닫을 수 없도록 설정
        barrierColor: Colors.black54, // 배경을 어둡게 처리
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(), // 로딩 인디케이터
          );
        },
      );

      try {
        await authProvider.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        // 로그인 성공 시 로딩 인디케이터 닫기 및 페이지 닫기
        if (context.mounted) Navigator.pop(context); // 로딩 창 닫기
        Navigator.pop(context);
      } catch (e) {
        // 로그인 실패 처리
        if (context.mounted) Navigator.pop(context); // 로딩 창 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () {
        // 화면을 터치하면 키보드 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/image/gear.gif', // gear.gif 이미지 추가
                ),
                Text(
                  'LOGIN',
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BF3B1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 16,
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
