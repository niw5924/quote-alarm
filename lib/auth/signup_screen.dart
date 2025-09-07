import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/utils/overlay_loader.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_util.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
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
        ToastUtil.showFailure('비밀번호가 일치하지 않습니다.');
        return;
      }

      OverlayLoader.show(context);

      try {
        await authProvider.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        OverlayLoader.hide();
        ToastUtil.showSuccess('회원가입 성공! 자동 로그인 되었습니다.');
        Navigator.pop(context);
        Navigator.pop(context);
      } catch (e) {
        OverlayLoader.hide();
        ToastUtil.showFailure('회원가입 실패: $e');
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                width: double.infinity,
                text: 'SIGN UP',
                onPressed: signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
