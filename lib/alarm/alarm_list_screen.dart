import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_app_2/widgets/dialogs/confirm_dialog.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../models/alarm_item.dart';
import '../utils/time_util.dart';
import '../utils/toast_util.dart';

class AlarmListScreen extends StatelessWidget {
  final bool isDarkTheme;
  final List<AlarmItem> alarms;
  final Function(int) onTapAlarm;
  final Function(AlarmItem) onToggleAlarm;
  final Function(int, AlarmItem) onDeleteAlarm;

  const AlarmListScreen({
    super.key,
    required this.isDarkTheme,
    required this.alarms,
    required this.onTapAlarm,
    required this.onToggleAlarm,
    required this.onDeleteAlarm,
  });

  // 가장 가까운 알람 가져오기
  Future<AlarmSettings?> getNearestAlarm() async {
    final alarms = await Alarm.getAlarms(); // 모든 알람 가져오기

    if (alarms.isEmpty) return null;

    // 가장 가까운 알람 찾기
    return alarms.reduce((a, b) => a.dateTime.isBefore(b.dateTime) ? a : b);
  }

  // 남은 시간 계산
  Future<String> getTimeUntilNextAlarm() async {
    final nearestAlarm = await getNearestAlarm();
    if (nearestAlarm == null) return "예정된 알람 없음";
    return TimeUtil.remainingTimeText(nearestAlarm.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final List<String> days = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      children: [
        StreamBuilder<String>(
          stream: Stream.value(DateTime.now().minute).concatWith([
            Stream.periodic(
                    const Duration(seconds: 1), (_) => DateTime.now().minute)
                .distinct(),
          ]).asyncMap((_) => getTimeUntilNextAlarm()),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final text = isLoading
                ? "알람 정보를 불러오는 중..."
                : hasError
                    ? "알람 정보를 가져오는 데 실패했어요"
                    : snapshot.data ?? "예정된 알람 없음";

            return Card(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: isDarkTheme
                  ? const Color(0xFF2A2F35)
                  : const Color(0xFFF1F4F8),
              child: ListTile(
                leading: Icon(
                  Icons.alarm,
                  size: 28,
                  color: textColor,
                ),
                title: Text(
                  '다음 알람',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarmItem = alarms[index];
              final dateTime = alarmItem.settings.dateTime;

              // 시간 표시 포맷팅
              final formattedTime = DateFormat('a h:mm')
                  .format(dateTime)
                  .replaceAll('AM', '오전')
                  .replaceAll('PM', '오후');

              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Icon(
                    Icons.delete,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => const ConfirmDialog(
                      icon: Icons.delete_forever,
                      title: '알람 삭제',
                      message: '이 알람을 삭제하시겠습니까?',
                      cancelText: '취소',
                      confirmText: '삭제',
                    ),
                  );
                  return confirmed ?? false;
                },
                onDismissed: (direction) {
                  onDeleteAlarm(index, alarmItem);
                },
                child: Opacity(
                  opacity: alarmItem.isEnabled ? 1.0 : 0.5,
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: isDarkTheme
                        ? Colors.grey[850]
                        : const Color(0xFFFCFCFC),
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
                              alarmItem.cancelMode.label,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              alarmItem.settings.notificationSettings.body
                                      .isEmpty
                                  ? '메모 없음'
                                  : alarmItem
                                      .settings.notificationSettings.body,
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
                          activeTrackColor: isDarkTheme
                              ? Colors.lightBlueAccent
                              : Colors.lightBlue,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor:
                              isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                          onChanged: (value) {
                            HapticFeedback.mediumImpact();
                            onToggleAlarm(alarmItem);

                            if (value) {
                              ToastUtil.showInfo(
                                TimeUtil.remainingTimeText(
                                  alarmItem.settings.dateTime,
                                ),
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
          ),
        ),
      ],
    );
  }
}
