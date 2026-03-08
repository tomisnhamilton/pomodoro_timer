import 'package:flutter/material.dart';
import 'timer_controller.dart';
import 'models/timer_mode.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  // Our logic is now a separate object we can talk to
  final TimerController _logic = TimerController();
  DateTime? _backgroundTimestamp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logic.addListener(() => setState(() {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // User just left the app
      _backgroundTimestamp = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // User just came back!
      if (_backgroundTimestamp != null && _logic.isRunning) {
        final gap = DateTime.now().difference(_backgroundTimestamp!).inSeconds;
        _logic.subtractSeconds(gap); // Tell the logic to "catch up"
      }
    }
  }

  Color _getModeColor(TimerMode mode) {
    return switch (mode) {
      TimerMode.focus => const Color(0xFFBA4949),
      TimerMode.shortBreak => const Color(0xFF388E3C),
      TimerMode.longBreak => const Color(0xFF397097),
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor = _getModeColor(_logic.currentMode);
    final Color nextColor = _getModeColor(_logic.nextMode);

    // Blend them based on timer progress
    final Color blendedColor = Color.lerp(
      currentColor,
      nextColor,
      _logic.progress,
    )!;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: blendedColor,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2), // Pushes content to the middle

              Text(
                _logic.currentMode.label.toUpperCase(),
                style: const TextStyle(color: Colors.white70, letterSpacing: 2),
              ),

              TextField(
                controller: TextEditingController(
                  text: _format(_logic.seconds),
                ),
                onSubmitted: _logic.updateDuration,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
                keyboardType: TextInputType.datetime,
              ),

              // FIXED: Putting the buttons side-by-side in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. The Main Play/Pause Button
                  IconButton(
                    iconSize: 100,
                    color: Colors.white,
                    icon: Icon(
                      _logic.isRunning
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    onPressed: _logic.toggleTimer,
                  ),

                  const SizedBox(width: 10), // Small gap
                  // 2. The Restart Button
                  IconButton(
                    iconSize: 50,
                    color: Colors.white70,
                    icon: const Icon(Icons.refresh),
                    onPressed: _logic.restartTimer,
                  ),
                ],
              ),

              const Spacer(flex: 3), // Pushes the mode buttons to the bottom
              // Bottom Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: TimerMode.values
                    .map((mode) => _modeBtn(mode))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeBtn(TimerMode mode) {
    final bool active = _logic.currentMode == mode;
    return TextButton(
      onPressed: () => _logic.setMode(mode),
      child: Text(
        mode.label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          decoration: active ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  String _format(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;

    if (h > 0) {
      // Returns HH:MM:SS
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    } else {
      // Returns MM:SS
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
  }
}
