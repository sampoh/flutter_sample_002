//ダブルクリック判定処理汎用
import 'package:flutter/material.dart';
import 'dart:async';

class ClickListener extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onSingleClick;
  final VoidCallback? onDoubleClick;

  const ClickListener(
      {Key? key, this.child, this.onSingleClick, this.onDoubleClick})
      : super(key: key);

  @override
  ClickListenerState createState() => ClickListenerState();
}

class ClickListenerState extends State<ClickListener> {
  DateTime? _lastTap;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        if (_lastTap != null &&
            now.difference(_lastTap!) < const Duration(milliseconds: 300)) {
          // If the previous tap was within 300 milliseconds, we consider it a double tap
          widget.onDoubleClick?.call();
          _lastTap = null;
        } else {
          // If the previous tap was not within 300 milliseconds, we start a timer. If the timer finishes without getting interrupted by a second tap, we consider it a single tap
          _lastTap = now;
          _timer = Timer(const Duration(milliseconds: 300), () {
            widget.onSingleClick?.call();
            _lastTap = null;
          });
        }
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
