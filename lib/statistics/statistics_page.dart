import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../auth/login_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final uid = authProvider.user?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '알람 해제 유형별 평균 해제 시간',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: uid == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Lottie.asset(
                          'assets/animation/lottie_statistics.json',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity, // 버튼이 부모 너비를 따라감
                        decoration: BoxDecoration(
                          border: const GradientBoxBorder(
                            gradient: LinearGradient(
                                colors: [Colors.blue, Colors.red]),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            // 높이는 패딩으로 설정
                            backgroundColor: const Color(0xFF6BF3B1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            '로그인하고 통계 확인하기',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  )
                : StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots()
                        .handleError((error) {
                      print("Firestore 스트림 오류 발생: $error");
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print("Firestore 데이터 로드 실패: ${snapshot.error}");
                        return const Center(child: Text("데이터를 불러올 수 없습니다."));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final alarmDismissals = data?['alarmDismissals'] ?? {};

                      double sliderAverage = 0,
                          mathAverage = 0,
                          puzzleAverage = 0,
                          voiceAverage = 0;
                      int sliderTotalDuration = 0, sliderCount = 0;
                      int mathTotalDuration = 0, mathCount = 0;
                      int puzzleTotalDuration = 0, puzzleCount = 0;
                      int voiceTotalDuration = 0, voiceCount = 0;

                      // Calculate averages
                      alarmDismissals.forEach((date, alarms) {
                        alarms.forEach((alarmId, alarmData) {
                          final duration =
                              (alarmData['duration'] as num).toInt();
                          final cancelMode = alarmData['cancelMode'];

                          switch (cancelMode) {
                            case 'slider':
                              sliderTotalDuration += duration;
                              sliderCount++;
                              break;
                            case 'mathProblem':
                              mathTotalDuration += duration;
                              mathCount++;
                              break;
                            case 'puzzle':
                              puzzleTotalDuration += duration;
                              puzzleCount++;
                              break;
                            case 'voiceRecognition':
                              voiceTotalDuration += duration;
                              voiceCount++;
                              break;
                            default:
                              debugPrint('Unknown cancel mode: $cancelMode');
                              break;
                          }
                        });
                      });

                      // Set formatted averages to one decimal place
                      sliderAverage = sliderCount > 0
                          ? double.parse((sliderTotalDuration / sliderCount)
                              .toStringAsFixed(1))
                          : 0;
                      mathAverage = mathCount > 0
                          ? double.parse((mathTotalDuration / mathCount)
                              .toStringAsFixed(1))
                          : 0;
                      puzzleAverage = puzzleCount > 0
                          ? double.parse((puzzleTotalDuration / puzzleCount)
                              .toStringAsFixed(1))
                          : 0;
                      voiceAverage = voiceCount > 0
                          ? double.parse((voiceTotalDuration / voiceCount)
                              .toStringAsFixed(1))
                          : 0;

                      // Sorting for medals
                      final averages = {
                        'slider': sliderAverage,
                        'mathProblem': mathAverage,
                        'puzzle': puzzleAverage,
                        'voiceRecognition': voiceAverage,
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
                          _buildMedalRanking(sortedAverages, zeroAverages),
                          const SizedBox(height: 20),
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
                                      toY: sliderAverage,
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
                                      toY: puzzleAverage,
                                      width: 40,
                                      color: Colors.orange,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    )
                                  ]),
                                  BarChartGroupData(x: 3, barRods: [
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
                                        TextStyle style = const TextStyle(
                                            fontWeight: FontWeight.w600);
                                        switch (value.toInt()) {
                                          case 0:
                                            return Text('슬라이더', style: style);
                                          case 1:
                                            return Text('수학 문제', style: style);
                                          case 2:
                                            return Text('퍼즐', style: style);
                                          case 3:
                                            return Text('음성 인식', style: style);
                                          default:
                                            return const Text('');
                                        }
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

  Widget _buildMedalRanking(List<MapEntry<String, double>> sortedAverages,
      List<MapEntry<String, double>> zeroAverages) {
    final medalColors = [Colors.amber, Colors.grey, Colors.brown];
    final icons = [
      Icons.emoji_events, // 1등 트로피
      Icons.emoji_events, // 2등 트로피
      Icons.emoji_events, // 3등 트로피
      Icons.sentiment_dissatisfied, // 순위권 밖
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(sortedAverages.length, (index) {
          final entry = sortedAverages[index];
          final modeLabel = _getModeLabel(entry.key);
          final averageTime = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  icons[index],
                  color: index < 3 ? medalColors[index] : Colors.grey,
                  // 순위권 밖은 회색 아이콘
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '$modeLabel ${averageTime.toStringAsFixed(1)}초',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
        // 0초 항목 표시
        if (zeroAverages.isNotEmpty)
          ...zeroAverages.map((entry) {
            final modeLabel = _getModeLabel(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.sentiment_dissatisfied, // 기록 없음 아이콘
                    color: Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$modeLabel 기록 없음',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _getModeLabel(String mode) {
    switch (mode) {
      case 'slider':
        return '슬라이더';
      case 'mathProblem':
        return '수학문제';
      case 'puzzle':
        return '퍼즐';
      case 'voiceRecognition':
        return '음성인식';
      default:
        return '';
    }
  }
}
