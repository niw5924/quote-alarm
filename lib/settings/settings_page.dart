import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/auth/account_deletion_popup.dart';
import 'package:flutter_alarm_app_2/auth/logout_popup.dart';
import 'package:flutter_alarm_app_2/auth/login_required_popup.dart';
import 'package:flutter_alarm_app_2/settings/settings_tile.dart';
import 'package:flutter_alarm_app_2/settings/sound_addition_page.dart';
import 'package:flutter_alarm_app_2/settings/star_grade_explanation_popup.dart';
import 'package:flutter_alarm_app_2/utils/overlay_loader.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        padding: const EdgeInsets.all(8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          starIcon,
                          const SizedBox(width: 4),
                          Text(
                            '${authProvider.user?.email} 님',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
            SettingsTile(
              icon: Icons.person,
              iconBackgroundColor: const Color(0xFF8D8D58),
              title: authProvider.isLoggedIn ? '로그아웃' : '로그인',
              onTap: () async {
                if (!authProvider.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  bool? shouldLogout = await LogoutPopup.show(context);
                  if (shouldLogout == true) {
                    OverlayLoader.show(context); // 로딩 오버레이 표시
                    await authProvider.signOut();
                    OverlayLoader.hide(); // 로딩 오버레이 닫기
                    Fluttertoast.showToast(
                      msg: '로그아웃 되었습니다.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: const Color(0xFF6BF3B1),
                      textColor: Colors.black,
                    );
                  }
                }
              },
            ),
            SettingsTile(
              icon: Icons.calculate,
              iconBackgroundColor: const Color(0xFF00796B),
              title: '수학 문제 난이도 설정',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MathDifficultyPopup();
                  },
                );
              },
            ),
            SettingsTile(
              icon: Icons.music_note,
              iconBackgroundColor: const Color(0xFF6A1B9A),
              title: '나만의 사운드 추가하기',
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        const LoginRequiredPopup(),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SoundAdditionPage()),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  backgroundColor: const Color(0xFF6BF3B1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                  );
                                },
                                child: const Text(
                                  '로그인하고 잔디 채우기',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SettingsTile(
              icon: Icons.book,
              iconBackgroundColor: const Color(0xFF00796B),
              title: '오픈소스 라이선스',
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: '울림소리',
                  applicationIcon: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Image(
                      image: AssetImage('assets/image/quote_alarm_icon.png'),
                      width: 100,
                      height: 100,
                    ),
                  ),
                  applicationLegalese: '2025 남인우 개인 프로젝트',
                );
              },
            ),
            if (authProvider.isLoggedIn)
              SettingsTile(
                icon: Icons.delete_forever,
                iconBackgroundColor: Colors.redAccent,
                title: '계정 삭제',
                onTap: () async {
                  bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) =>
                        const AccountDeletionPopup(),
                  );

                  if (shouldDelete == true) {
                    OverlayLoader.show(context); // 로딩 오버레이 표시
                    try {
                      await authProvider.deleteAccount();
                      OverlayLoader.hide(); // 로딩 오버레이 닫기
                      Fluttertoast.showToast(
                        msg: "계정이 삭제되었습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: const Color(0xFF6BF3B1),
                        textColor: Colors.black,
                      );
                    } catch (e) {
                      OverlayLoader.hide(); // 로딩 오버레이 닫기
                      Fluttertoast.showToast(
                        msg: "계정 삭제 실패: $e",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
