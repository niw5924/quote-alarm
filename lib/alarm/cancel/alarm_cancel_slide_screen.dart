import 'package:flutter/material.dart';

class AlarmCancelSlideScreen extends StatelessWidget {
  final double slideValue;
  final ValueChanged<double> onSlideChanged;
  final VoidCallback onSlideComplete;

  const AlarmCancelSlideScreen({
    super.key,
    required this.slideValue,
    required this.onSlideChanged,
    required this.onSlideComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                activeTrackColor: const Color(0xFF6BF3B1),
                inactiveTrackColor: Colors.grey,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 30.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 40.0,
                ),
              ),
              child: Slider(
                min: 0.0,
                max: 1.0,
                value: slideValue,
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
      ),
    );
  }
}
