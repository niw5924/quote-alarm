import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_alarm_app_2/widgets/buttons/gradient_border_button.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../constants/alarm_cancel_mode.dart';
import '../providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../auth/login_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final uid = authProvider.user?.uid;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '알람 해제 유형별 평균 해제 시간',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: uid == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lotties/statistics.json',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      GradientBorderButton(
                        width: double.infinity,
                        text: '로그인하고 통계 확인하기',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      )
                    ],
                  )
                : StreamBuilder<DocumentSnapshot>(
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

                      if (!snapshot.hasData) {
                        debugPrint("Firestore 데이터 로딩 중...");
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final alarmDismissals = data?['alarmDismissals'] ?? {};

                      double slideAverage = 0,
                          mathAverage = 0,
                          voiceAverage = 0;
                      int slideTotalDuration = 0, slideCount = 0;
                      int mathTotalDuration = 0, mathCount = 0;
                      int voiceTotalDuration = 0, voiceCount = 0;

                      // Calculate averages
                      alarmDismissals.forEach((date, alarms) {
                        alarms.forEach((alarmId, alarmData) {
                          final duration =
                              (alarmData['duration'] as num).toInt();
                          final cancelMode =
                              AlarmCancelMode.fromKey(alarmData['cancelMode']);

                          switch (cancelMode) {
                            case AlarmCancelMode.slide:
                              slideTotalDuration += duration;
                              slideCount++;
                              break;
                            case AlarmCancelMode.mathProblem:
                              mathTotalDuration += duration;
                              mathCount++;
                              break;
                            case AlarmCancelMode.voiceRecognition:
                              voiceTotalDuration += duration;
                              voiceCount++;
                              break;
                          }
                        });
                      });

                      // Set formatted averages to one decimal place
                      slideAverage = slideCount > 0
                          ? double.parse((slideTotalDuration / slideCount)
                              .toStringAsFixed(1))
                          : 0;
                      mathAverage = mathCount > 0
                          ? double.parse((mathTotalDuration / mathCount)
                              .toStringAsFixed(1))
                          : 0;
                      voiceAverage = voiceCount > 0
                          ? double.parse((voiceTotalDuration / voiceCount)
                              .toStringAsFixed(1))
                          : 0;

                      // Sorting for medals
                      final averages = {
                        AlarmCancelMode.slide.key: slideAverage,
                        AlarmCancelMode.mathProblem.key: mathAverage,
                        AlarmCancelMode.voiceRecognition.key: voiceAverage,
                      };

                      // 0초를 제외한 값만 정렬
                      final sortedAverages = averages.entries
                          .where((entry) => entry.value > 0) // 0초 제거
                          .toList()
                        ..sort((a, b) => a.value.compareTo(b.value));

                      // 0초인 항목을 별도로 그룹화
                      final zeroAverages = averages.entries
                          .where((entry) => entry.value == 0) // 0초만 선택
                          .toList();

                      return Column(
                        children: [
                          _MedalRanking(
                            sortedAverages: sortedAverages,
                            zeroAverages: zeroAverages,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.center,
                                groupsSpace: 60,
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [
                                    BarChartRodData(
                                      toY: slideAverage,
                                      width: 40,
                                      color: Colors.blue,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    )
                                  ]),
                                  BarChartGroupData(x: 1, barRods: [
                                    BarChartRodData(
                                      toY: mathAverage,
                                      width: 40,
                                      color: Colors.lime,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    )
                                  ]),
                                  BarChartGroupData(x: 2, barRods: [
                                    BarChartRodData(
                                      toY: voiceAverage,
                                      width: 40,
                                      color: Colors.green,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    )
                                  ]),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        final mode = AlarmCancelMode
                                            .values[value.toInt()];

                                        return Text(
                                          mode.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MedalRanking extends StatelessWidget {
  final List<MapEntry<String, double>> sortedAverages;
  final List<MapEntry<String, double>> zeroAverages;

  const _MedalRanking({
    required this.sortedAverages,
    required this.zeroAverages,
  });

  @override
  Widget build(BuildContext context) {
    const medalColors = [Colors.amber, Colors.grey, Colors.brown];

    final items = [
      ...sortedAverages.map((entry) {
        return Row(
          children: [
            Icon(
              sortedAverages.indexOf(entry) < 3
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
              color: sortedAverages.indexOf(entry) < 3
                  ? medalColors[sortedAverages.indexOf(entry)]
                  : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              '${AlarmCancelMode.fromKey(entry.key).label} ${entry.value.toStringAsFixed(1)}초',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
      ...zeroAverages.map((entry) {
        return Row(
          children: [
            const Icon(Icons.block, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              '${AlarmCancelMode.fromKey(entry.key).label} 기록 없음',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    ];

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}
