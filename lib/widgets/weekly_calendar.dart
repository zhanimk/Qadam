import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qadam/theme/app_theme.dart';

class WeeklyCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const WeeklyCalendar({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildCalendar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat.yMMMM().format(_selectedDate),
          style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.add(Duration(days: index)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = day.day == _selectedDate.day;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
            });
            widget.onDateSelected(day);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? null : Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat.E().format(day).substring(0, 2),
                  style: TextStyle(color: isSelected ? Colors.white : AppTheme.mutedForeground),
                ),
                const SizedBox(height: 8),
                Text(
                  day.day.toString(),
                  style: TextStyle(color: isSelected ? Colors.white : AppTheme.onSurface, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
