import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_app_2/alarm/alarm_delete_popup.dart';
import 'package:flutter_alarm_app_2/home/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AlarmListPage extends StatelessWidget {
  final bool isDarkTheme;
  final List<AlarmItem> alarms;
  final Function(int) onTapAlarm;
  final Function(AlarmItem) onToggleAlarm;
  final Function(int, AlarmItem) onDeleteAlarm;

  const AlarmListPage({
    super.key,
    required this.isDarkTheme,
    required this.alarms,
    required this.onTapAlarm,
    required this.onToggleAlarm,
    required this.onDeleteAlarm,
  });

  // 알람 해제 유형을 텍스트로 변환
  String _getCancelModeText(AlarmCancelMode cancelMode) {
    switch (cancelMode) {
      case AlarmCancelMode.slider:
        return '슬라이더';
      case AlarmCancelMode.mathProblem:
        return '수학 문제';
      case AlarmCancelMode.puzzle:
        return '퍼즐';
      case AlarmCancelMode.voiceRecognition:
        return '음성 인식';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

    return ListView.builder(
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarmItem = alarms[index];
        final dateTime = alarmItem.settings.dateTime;

        // 시간 표시 포맷팅
        final formattedTime = DateFormat('a h:mm')
            .format(dateTime)
            .replaceAll('AM', '오전')
            .replaceAll('PM', '오후');

        // 알람 해제 유형 텍스트 변환
        final cancelModeText = _getCancelModeText(alarmItem.cancelMode);

        return Dismissible(
          key: UniqueKey(),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => const AlarmDeletePopup(),
            );
            return shouldDelete ?? false; // null이면 삭제 취소
          },
          onDismissed: (direction) {
            onDeleteAlarm(index, alarmItem);
          },
          child: Opacity(
            opacity: alarmItem.isEnabled ? 1.0 : 0.5,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: isDarkTheme ? Colors.grey[850] : const Color(0xFFFCFCFC),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  onTapAlarm(index);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 요일 표시
                      Text.rich(
                        TextSpan(
                          children: List.generate(7, (dayIndex) {
                            return TextSpan(
                              text: '${days[dayIndex]} ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(
                                    alpha: alarmItem.repeatDays[dayIndex]
                                        ? 1.0
                                        : 0.5),
                              ),
                            );
                          }),
                        ),
                      ),
                      // 기존 시간 표시
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${formattedTime.split(' ')[0]} ',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: formattedTime.split(' ')[1],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cancelModeText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        alarmItem.settings.notificationSettings.body.isEmpty
                            ? '메모 없음'
                            : alarmItem.settings.notificationSettings.body,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  trailing: Switch(
                    value: alarmItem.isEnabled,
                    activeColor: Colors.white,
                    activeTrackColor:
                        isDarkTheme ? Colors.lightBlueAccent : Colors.lightBlue,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor:
                        isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                    onChanged: (value) {
                      HapticFeedback.mediumImpact();
                      onToggleAlarm(alarmItem);

                      if (value) {
                        final now = DateTime.now();
                        final alarmTime = alarmItem.settings.dateTime;
                        final difference = alarmTime.difference(now);
                        final totalMinutes = (difference.inSeconds / 60).ceil();
                        final hours = totalMinutes ~/ 60;
                        final minutes = totalMinutes % 60;

                        Fluttertoast.showToast(
                          msg: hours > 0
                              ? '알람이 약 $hours시간 $minutes분 후에 울립니다.'
                              : '알람이 약 $minutes분 후에 울립니다.',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black.withValues(alpha: 0.8),
                          textColor: Colors.white,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
