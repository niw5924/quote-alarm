import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/utils/overlay_loader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    Future<void> signUp() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (passwordController.text != confirmPasswordController.text) {
        Fluttertoast.showToast(
          msg: '비밀번호가 일치하지 않습니다.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      OverlayLoader.show(context); // 로딩 오버레이 표시

      try {
        await authProvider.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (context.mounted) {
          OverlayLoader.hide(); // 로딩 오버레이 닫기
          Fluttertoast.showToast(
            msg: '회원가입 성공! 자동 로그인 되었습니다.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xFF6BF3B1),
            textColor: Colors.black,
          );
          Navigator.pop(context); // 회원가입 페이지 닫기
          Navigator.pop(context); // 로그인 페이지 닫기
        }
      } catch (e) {
        if (context.mounted) OverlayLoader.hide(); // 로딩 오버레이 닫기
        Fluttertoast.showToast(
          msg: '회원가입 실패: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
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
                const Text(
                  'SIGN UP',
                  style: TextStyle(
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
                    labelStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor:
                        isDarkMode ? Colors.grey[850] : const Color(0xFFEAD3B2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: textColor),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor:
                        isDarkMode ? Colors.grey[850] : const Color(0xFFEAD3B2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: textColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: textColor),
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor:
                        isDarkMode ? Colors.grey[850] : const Color(0xFFEAD3B2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: textColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
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
                      color: Colors.black,
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
