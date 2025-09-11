import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/utils/overlay_loader.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/grey_text_button.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_util.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    Future<void> signIn() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      OverlayLoader.show(context);

      try {
        await authProvider.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        OverlayLoader.hide();
        ToastUtil.showSuccess('${emailController.text.trim()}님, 환영합니다!');
        Navigator.pop(context);
      } catch (e) {
        OverlayLoader.hide();
        ToastUtil.showFailure('로그인 실패: $e');
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset('assets/image/gear.gif'),
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscureText,
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
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: textColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                width: double.infinity,
                text: 'LOGIN',
                onPressed: signIn,
              ),
              const SizedBox(height: 16),
              GreyTextButton(
                text: 'SIGN UP',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
