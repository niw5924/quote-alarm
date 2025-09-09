enum AlarmCancelMode {
  slide('slide', '슬라이드'),
  mathProblem('math_problem', '수학 문제'),
  voiceRecognition('voice_recognition', '음성 인식');

  final String key;
  final String label;

  const AlarmCancelMode(this.key, this.label);

  static AlarmCancelMode fromKey(String key) {
    return AlarmCancelMode.values.firstWhere((e) => e.key == key);
  }
}
