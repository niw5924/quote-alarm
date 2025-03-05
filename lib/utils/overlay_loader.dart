import 'package:flutter/material.dart';

class OverlayLoader {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
