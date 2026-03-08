import 'dart:async';
import 'package:flutter/material.dart';
import 'models/timer_mode.dart';
import 'services/notification_service.dart';

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
      NotificationService.cancelAll();
    } else {
      NotificationService.scheduleNotification(
        secondsFromNow: seconds,
        title: "Time's Up!",
        body: "Starting ${nextMode.label} now.",
      );

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds > 0) {
          seconds--;
        } else {
          _autoSwitchMode();
        }
        notifyListeners();
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

    /* NotificationService.showNotification(
      title: "Time's Up!",
      body: "Starting ${currentMode.label} now.",
    );
    */
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

  void subtractSeconds(int secondsToSubtract) {
    if (!isRunning) return;

    if (seconds > secondsToSubtract) {
      seconds -= secondsToSubtract;
    } else {
      _autoSwitchMode();
    }
    notifyListeners();
  }

  void restartTimer() {
    _timer?.cancel();

    seconds =
        switch (currentMode) {
          TimerMode.focus => focusMins,
          TimerMode.shortBreak => shortBreakMins,
          TimerMode.longBreak => longBreakMins,
        } *
        60;

    notifyListeners();
  }

  TimerMode get nextMode {
    if (currentMode == TimerMode.focus) {
      return (pomodoroCount + 1) % 4 == 0
          ? TimerMode.longBreak
          : TimerMode.shortBreak;
    }
    return TimerMode.focus;
  }

  double get progress {
    int total =
        (currentMode == TimerMode.focus
            ? focusMins
            : currentMode == TimerMode.shortBreak
            ? shortBreakMins
            : longBreakMins) *
        60;
    if (total == 0) return 0.0;
    return 1.0 - (seconds / total);
  }
}
