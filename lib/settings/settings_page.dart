import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/auth/login_required_dialog.dart';
import 'package:flutter_alarm_app_2/settings/quote_language_dialog.dart';
import 'package:flutter_alarm_app_2/settings/settings_tile.dart';
import 'package:flutter_alarm_app_2/settings/sound_addition_page.dart';
import 'package:flutter_alarm_app_2/settings/star_grade_explanation_dialog.dart';
import 'package:flutter_alarm_app_2/utils/overlay_loader.dart';
import 'package:flutter_alarm_app_2/widgets/confirm_dialog.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../auth/login_page.dart';
import 'math_difficulty_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots()
                    .handleError((error) {
                  debugPrint("Firestore 스트림 오류 발생: $error");
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint("Firestore 데이터 로드 실패: ${snapshot.error}");
                    return const Center(child: Text("데이터를 불러올 수 없습니다."));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    debugPrint("Firestore 데이터 로딩 중...");
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    debugPrint("Firestore에 유저 데이터가 없습니다.");
                    return const Center(child: Text("데이터가 없습니다."));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final alarmDismissals = data?['alarmDismissals'] ?? {};

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

                  Icon starIcon;
                  if (currentMonthDismissals >= 10) {
                    starIcon =
                        const Icon(Icons.star, color: Colors.amber, size: 30);
                  } else if (currentMonthDismissals >= 5) {
                    starIcon =
                        const Icon(Icons.star, color: Colors.grey, size: 30);
                  } else {
                    starIcon =
                        const Icon(Icons.star, color: Colors.brown, size: 30);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[850]
                            : const Color(0xFFEAD3B2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StarGradeExplanationDialog(
                                    currentMonthDismissals:
                                        currentMonthDismissals,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            SettingsTile(
              icon: Icons.person,
              iconBackgroundColor: Colors.blueGrey,
              title: authProvider.isLoggedIn ? '로그아웃' : '로그인',
              onTap: () async {
                if (!authProvider.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => const ConfirmDialog(
                      icon: Icons.logout,
                      title: '로그아웃',
                      message: '정말로 로그아웃 하시겠습니까?',
                      cancelText: '취소',
                      confirmText: '로그아웃',
                    ),
                  );

                  if (confirmed == true) {
                    if (!context.mounted) return;
                    OverlayLoader.show(context);
                    await authProvider.signOut();
                    OverlayLoader.hide();
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
              iconBackgroundColor: Colors.teal,
              title: '수학 문제 난이도 설정',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MathDifficultyDialog();
                  },
                );
              },
            ),
            SettingsTile(
              icon: Icons.translate,
              iconBackgroundColor: Colors.indigo,
              title: '명언 언어 설정',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const QuoteLanguageDialog();
                  },
                );
              },
            ),
            SettingsTile(
              icon: Icons.music_note,
              iconBackgroundColor: Colors.purple,
              title: '나만의 사운드 추가하기',
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        const LoginRequiredDialog(),
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
                            .handleError((error) {
                            debugPrint("Firestore 스트림 오류 발생: $error");
                          })
                        : null,
                    builder: (context, snapshot) {
                      Map<DateTime, int> datasets = {};

                      if (snapshot.hasError) {
                        debugPrint("Firestore 데이터 로드 실패: ${snapshot.error}");
                        return const Center(child: Text("데이터를 불러올 수 없습니다."));
                      }

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
                          datasets[dateTime] =
                              (minDuration >= 0 && minDuration < 30)
                                  ? 2
                                  : (minDuration >= 30)
                                      ? 1
                                      : 0;
                        });
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          HeatMapCalendar(
                            datasets: datasets,
                            defaultColor: const Color(0xFFB0BEC5),
                            borderRadius: 4,
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
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildColorIndicator(
                                  "기록 없음", const Color(0xFFB0BEC5)),
                              const SizedBox(width: 12),
                              _buildColorIndicator(
                                  "30초 이상", const Color(0xFF78909C)),
                              const SizedBox(width: 12),
                              _buildColorIndicator(
                                  "30초 미만", const Color(0xFF455A64)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  if (!authProvider.isLoggedIn)
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
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
              iconBackgroundColor: Colors.amber,
              title: '오픈소스 라이선스',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: isDarkMode
                            ? const Color(0xFF101317)
                            : const Color(0xFFFFFBEA),
                      ),
                      child: const LicensePage(
                        applicationName: '울림소리',
                        applicationIcon: Padding(
                          padding: EdgeInsets.all(8),
                          child: Image(
                            image:
                                AssetImage('assets/image/quote_alarm_icon.png'),
                            width: 100,
                            height: 100,
                          ),
                        ),
                        applicationLegalese: '2025 남인우 개인 프로젝트',
                      ),
                    ),
                  ),
                );
              },
            ),
            if (authProvider.isLoggedIn)
              SettingsTile(
                icon: Icons.delete_forever,
                iconBackgroundColor: Colors.redAccent,
                title: '계정 삭제',
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => const ConfirmDialog(
                      icon: Icons.warning_amber_rounded,
                      title: '계정 삭제',
                      message: '계정을 삭제하면 복구할 수 없습니다.\n정말 삭제하시겠습니까?',
                      cancelText: '취소',
                      confirmText: '삭제',
                    ),
                  );

                  if (confirmed == true) {
                    if (!context.mounted) return;
                    OverlayLoader.show(context);
                    try {
                      await authProvider.deleteAccount();
                      OverlayLoader.hide();
                      Fluttertoast.showToast(
                        msg: "계정이 삭제되었습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: const Color(0xFF6BF3B1),
                        textColor: Colors.black,
                      );
                    } catch (e) {
                      OverlayLoader.hide();
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

  // 색상 인디케이터 위젯
  Widget _buildColorIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
