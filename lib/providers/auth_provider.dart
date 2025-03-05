import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Firebase 인증 상태 확인
  void _checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      print("Auth State Changed: $user");
      notifyListeners();
    });
  }

  // 로그인
  Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // 회원가입
  Future<void> signUp(String email, String password) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'email': email,
      'createdAt': DateTime.now(),
      'alarmDismissals': {},
    });
  }

  // 계정 삭제
  Future<void> deleteAccount() async {
    String uid = _user!.uid;

    // Firestore에서 사용자 데이터 삭제
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    // Firebase Authentication에서 계정 삭제
    await _user!.delete();
  }
}
