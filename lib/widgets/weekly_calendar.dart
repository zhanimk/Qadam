
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({Key? key}) : super(key: key);

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildWeekDays(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 7));
            });
          },
        ),
        Text(
          DateFormat('MMMM yyyy').format(_selectedDate),
          style: AppTheme.textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 7));
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    final weekDays = List.generate(7, (index) {
      final day = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1 - index));
      final isSelected = day.day == _selectedDate.day;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = day;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('E').format(day),
                style: TextStyle(color: isSelected ? Colors.white : AppTheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d').format(day),
                style: TextStyle(color: isSelected ? Colors.white : AppTheme.onSurface),
              ),
            ],
          ),
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays,
    );
  }
}
