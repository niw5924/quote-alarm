import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/auth/logout_popup.dart';
import 'package:flutter_alarm_app_2/settings/sound_addition_page.dart';
import 'package:flutter_alarm_app_2/settings/star_grade_explanation_popup.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../auth/login_page.dart';
import 'math_difficulty_popup.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkTheme;

  const SettingsPage({super.key, required this.isDarkTheme});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final uid = authProvider.user?.uid;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.isLoggedIn)
              StreamBuilder<DocumentSnapshot>(
                stream: uid != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    print("유저 알람 해제 기록을 불러오는 중입니다...");
                  }

                  if (snapshot.connectionState == ConnectionState.active) {
                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    final alarmDismissals = data?['alarmDismissals'] ?? {};

                    // 월별 알람 해제 횟수 합산
                    int currentMonthDismissals = 0;
                    String currentMonthKey =
                        '${DateTime.now().year}-${DateTime.now().month}';

                    alarmDismissals.forEach((date, alarms) {
                      DateTime dateTime = DateTime.parse(date);
                      String monthKey = '${dateTime.year}-${dateTime.month}';

                      if (monthKey == currentMonthKey) {
                        currentMonthDismissals += (alarms as Map).length;
                      }
                    });

                    print('이번 달 알람 해제 횟수: $currentMonthDismissals');

                    // 해제 횟수에 따른 별 색상 설정
                    Icon starIcon;
                    if (currentMonthDismissals >= 10) {
                      starIcon = const Icon(Icons.star,
                          color: Colors.amber, size: 24); // 금색 별
                    } else if (currentMonthDismissals >= 5) {
                      starIcon = const Icon(Icons.star,
                          color: Colors.grey, size: 24); // 은색 별
                    } else {
                      starIcon = const Icon(Icons.star,
                          color: Colors.brown, size: 24); // 동색 별
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          starIcon,
                          const SizedBox(width: 8),
                          Text(
                            '${authProvider.user?.email} 님',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StarGradeExplanationPopup(
                                      currentMonthDismissals:
                                          currentMonthDismissals);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            InkWell(
              onTap: () async {
                if (!authProvider.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  // 팝업을 UI에서 호출
                  bool? shouldLogout = await LogoutPopup.show(context);
                  if (shouldLogout == true) {
                    await authProvider.signOut();
                  }
                }
              },
              splashColor: Colors.grey.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF8D8D58),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authProvider.isLoggedIn ? '로그아웃' : '로그인',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MathDifficultyPopup();
                  },
                );
              },
              splashColor: Colors.grey.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF00796B),
                      child: Icon(Icons.calculate, color: Colors.black),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '수학 문제 난이도 설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: const Color(0xFFFFFBEA),
                        title: const Text(
                          '로그인이 필요합니다',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          '이 기능을 사용하려면 로그인 해주세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF6BF3B1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SoundAdditionPage()),
                  );
                }
              },
              splashColor: Colors.grey.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF6A1B9A),
                      child: Icon(Icons.music_note, color: Colors.black),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '나만의 사운드 추가하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: uid != null
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    Map<DateTime, int> datasets = {};
                    if (snapshot.connectionState == ConnectionState.active &&
                        snapshot.hasData &&
                        authProvider.isLoggedIn) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final alarmDismissals = data?['alarmDismissals'] ?? {};

                      alarmDismissals.forEach((date, alarms) {
                        int minDuration = alarms.values
                            .map((alarm) => alarm['duration'])
                            .reduce((a, b) => a < b ? a : b);

                        DateTime dateTime = DateTime.parse(date);
                        datasets[dateTime] = minDuration > 30
                            ? 1
                            : minDuration > 0 && minDuration <= 30
                                ? 2
                                : 0;
                      });
                    }

                    return HeatMapCalendar(
                      datasets: datasets,
                      defaultColor: const Color(0xFFB0BEC5),
                      fontSize: 20,
                      monthFontSize: 22,
                      weekFontSize: 14,
                      textColor: const Color(0xFF263238),
                      flexible: true,
                      colorMode: ColorMode.color,
                      showColorTip: false,
                      colorsets: const {
                        0: Color(0xFFB0BEC5),
                        1: Color(0xFF78909C),
                        2: Color(0xFF455A64),
                      },
                    );
                  },
                ),
                if (!authProvider.isLoggedIn)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: const GradientBoxBorder(
                                gradient: LinearGradient(
                                    colors: [Colors.red, Colors.blue]),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                backgroundColor: const Color(0xFF6BF3B1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                '로그인하고 잔디 채우기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: '울림소리',
                  applicationIcon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage('assets/image/quote_alarm_icon.png'),
                      width: 100,
                      height: 100,
                    ),
                  ),
                  applicationLegalese: '2024 남인우 개인 프로젝트',
                );
              },
              splashColor: Colors.grey.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF00796B),
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '오픈소스 라이선스',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
