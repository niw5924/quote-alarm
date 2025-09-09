import 'package:flutter/material.dart';

class AlarmCancelSlide extends StatelessWidget {
  final double slideValue;
  final ValueChanged<double> onSlideChanged;
  final VoidCallback onSlideComplete;

  const AlarmCancelSlide({
    super.key,
    required this.slideValue,
    required this.onSlideChanged,
    required this.onSlideComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Slide to Cancel Alarm',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 50.0,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 30.0,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 40.0,
              ),
              thumbColor: Colors.white,
              activeTrackColor: const Color(0xFF6BF3B1),
              inactiveTrackColor: Colors.grey,
            ),
            child: Slider(
              value: slideValue,
              min: 0,
              max: 1,
              onChanged: (value) {
                onSlideChanged(value);
                if (value == 1) {
                  onSlideComplete();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
