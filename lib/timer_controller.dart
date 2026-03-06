import 'dart:async';
import 'package:flutter/material.dart';
import 'models/timer_mode.dart';

class TimerController extends ChangeNotifier {
  Timer? _timer;
  TimerMode currentMode = TimerMode.focus;
  int seconds = 1500;
  int pomodoroCount = 0;

  int focusMins = 25;
  int shortBreakMins = 5;
  int longBreakMins = 15;

  bool get isRunning => _timer?.isActive ?? false;

  void toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds > 0) {
          seconds--;
        } else {
          _autoSwitchMode();
        }
        notifyListeners(); // This is the "setState" for controllers
      });
    }
    notifyListeners();
  }

  void setMode(TimerMode mode) {
    _timer?.cancel();
    currentMode = mode;
    _resetSeconds();
    notifyListeners();
  }

  void updateDuration(String value) {
    int total = 0;
    if (value.contains(':')) {
      final parts = value.split(':');
      total =
          (int.tryParse(parts[0]) ?? 0) * 60 +
          (parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);
    } else {
      total = (int.tryParse(value) ?? 0) * 60;
    }

    if (total > 0) {
      // Logic for saving based on current mode
      if (currentMode == TimerMode.focus) focusMins = total ~/ 60;
      if (currentMode == TimerMode.shortBreak) shortBreakMins = total ~/ 60;
      if (currentMode == TimerMode.longBreak) longBreakMins = total ~/ 60;
      seconds = total;
      notifyListeners();
    }
  }

  void _autoSwitchMode() {
    if (currentMode == TimerMode.focus) {
      pomodoroCount++;
      currentMode = (pomodoroCount % 4 == 0)
          ? TimerMode.longBreak
          : TimerMode.shortBreak;
    } else {
      currentMode = TimerMode.focus;
    }
    _resetSeconds();
  }

  void _resetSeconds() {
    seconds =
        (currentMode == TimerMode.focus
            ? focusMins
            : currentMode == TimerMode.shortBreak
            ? shortBreakMins
            : longBreakMins) *
        60;
  }

  void restartTimer() {
    _timer?.cancel(); // Stop the heartbeat

    // Reset seconds based on the current mode's duration
    seconds =
        switch (currentMode) {
          TimerMode.focus => focusMins,
          TimerMode.shortBreak => shortBreakMins,
          TimerMode.longBreak => longBreakMins,
        } *
        60;

    notifyListeners(); // Tell the UI to refresh the display
  }
}
