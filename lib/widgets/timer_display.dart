import 'package:flutter/material.dart';
import '../timer_controller.dart';

class TimerDisplay extends StatelessWidget {
  final TimerController controller;
  const TimerDisplay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: _format(controller.seconds)),
      onSubmitted: controller.updateDuration,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.datetime,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 80,
        fontWeight: FontWeight.bold,
      ),
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }

  String _format(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
