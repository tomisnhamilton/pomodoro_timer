enum TimerMode {
  focus,
  shortBreak,
  longBreak;

  String get label => switch (this) {
    focus => "Focus Time",
    shortBreak => "Short Break",
    longBreak => "Long Break",
  };

  // Modern Dart allows getters inside enums to keep logic centralized
  int get defaultMinutes => switch (this) {
    focus => 25,
    shortBreak => 5,
    longBreak => 15,
  };
}
