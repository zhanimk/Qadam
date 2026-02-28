import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const int _pomodoroDuration = 25; // minutes
  static const int _shortBreakDuration = 5; // minutes
  static const int _longBreakDuration = 15; // minutes

  Timer? _timer;
  int _minutes = _pomodoroDuration;
  int _seconds = 0;
  bool _isRunning = false;
  String _currentMode = 'Pomodoro';
  int _pomodoroCount = 0;

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _switchMode();
          }
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentMode == 'Pomodoro') {
        _minutes = _pomodoroDuration;
      } else if (_currentMode == 'Short Break') {
        _minutes = _shortBreakDuration;
      } else {
        _minutes = _longBreakDuration;
      }
      _seconds = 0;
    });
  }

  void _switchMode() {
    setState(() {
      if (_currentMode == 'Pomodoro') {
        _pomodoroCount++;
        if (_pomodoroCount % 4 == 0) {
          _currentMode = 'Long Break';
          _minutes = _longBreakDuration;
        } else {
          _currentMode = 'Short Break';
          _minutes = _shortBreakDuration;
        }
      } else {
        _currentMode = 'Pomodoro';
        _minutes = _pomodoroDuration;
      }
      _seconds = 0;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface.withAlpha(50),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        children: [
          Text(_currentMode, style: AppTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text(
            '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
            style: AppTheme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isRunning ? LucideIcons.pause : LucideIcons.play, size: 40, color: AppTheme.accent),
                onPressed: _isRunning ? _pauseTimer : _startTimer,
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(LucideIcons.rotateCw, size: 32),
                onPressed: _resetTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
