
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const int _workDuration = 25 * 60; // 25 minutes in seconds
  static const int _breakDuration = 5 * 60; // 5 minutes in seconds

  Timer? _timer;
  int _remainingTime = _workDuration;
  bool _isTimerRunning = false;
  bool _isWorkTime = true;

  void _startTimer() {
    if (_isTimerRunning) return;
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          // Switch between work and break
          _isWorkTime = !_isWorkTime;
          _remainingTime = _isWorkTime ? _workDuration : _breakDuration;
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isTimerRunning) return;
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isWorkTime = true;
      _remainingTime = _workDuration;
    });
  }

  String get _formattedTime {
    final minutes = (_remainingTime / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              _isWorkTime ? "Focus Time" : "Break Time",
              style: AppTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text(
              _formattedTime,
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Icon(LucideIcons.play),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pauseTimer,
                  child: const Icon(LucideIcons.pause),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Icon(LucideIcons.refreshCw),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
