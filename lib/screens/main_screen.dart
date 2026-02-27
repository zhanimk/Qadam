import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import 'home_screen.dart';
import 'goals_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'awards_screen.dart';
import 'package:qadam/theme/app_theme.dart';
import 'package:qadam/widgets/add_goal_sheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  Key _homeKey = UniqueKey();
  Key _goalsKey = UniqueKey();
  Key _progressKey = UniqueKey();
  Key _awardsKey = UniqueKey();
  Key _profileKey = UniqueKey();

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          _homeKey = UniqueKey();
          break;
        case 1:
          _goalsKey = UniqueKey();
          break;
        case 2:
          _progressKey = UniqueKey();
          break;
        case 3:
          _awardsKey = UniqueKey();
          break;
        case 4:
          _profileKey = UniqueKey();
          break;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(key: _homeKey),
      GoalsScreen(key: _goalsKey),
      ProgressPage(key: _progressKey),
      AwardsScreen(key: _awardsKey),
      ProfilePage(key: _profileKey, onBack: () => _onItemTapped(0)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF13112A),
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: _buildFrostedNavBar(),
      floatingActionButton: _selectedIndex == 1 ? _buildFancyFab(context) : null,
    );
  }

  Widget _buildFancyFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddGoalSheet(),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(56.0),
        ),
        child: const Center(
          child: Icon(LucideIcons.plus, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFrostedNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
             padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, 'Home', 0),
                _buildNavItem(Icons.track_changes, 'Goals', 1),
                _buildNavItem(Icons.show_chart, 'Progress', 2),
                _buildNavItem(Icons.military_tech, 'Awards', 3),
                _buildNavItem(Icons.person_outline, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final activeColor = Colors.white;
    final inactiveColor = Colors.white.withAlpha(153);
    final highlightColor = const Color(0xFF9040F8);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: highlightColor.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? highlightColor : inactiveColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? activeColor : inactiveColor, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
