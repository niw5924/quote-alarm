class TimeUtil {
  static String remainingTimeText(DateTime alarmTime) {
    final now = DateTime.now();
    final diff = alarmTime.difference(now);

    final totalMinutes = (diff.inSeconds / 60).ceil();
    if (totalMinutes <= 0) return '곧 울립니다.';

    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    final minutes = totalMinutes % 60;

    if (days > 0) {
      return '알람이 약 $days일 $hours시간 $minutes분 후에 울립니다.';
    } else if (hours > 0) {
      return '알람이 약 $hours시간 $minutes분 후에 울립니다.';
    } else {
      return '알람이 약 $minutes분 후에 울립니다.';
    }
  }
}
