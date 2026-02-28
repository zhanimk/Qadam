import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qadam/utils/string_extension.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Health & Wellness", style: AppTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirestoreService().getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final userData = snapshot.data!.data() ?? {};
          final dailyProgress = userData['dailyProgress'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSleepTracker(context, dailyProgress, userData),
                const SizedBox(height: 24),
                _buildActivityChart(context, dailyProgress, userData),
                const SizedBox(height: 24),
                _buildHealthTips(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSleepTracker(BuildContext context, Map<String, dynamic> dailyProgress, Map<String, dynamic> userData) {
    final sleepHours = dailyProgress['sleepHours'] ?? 0;
    final sleepGoal = userData['sleepGoal'] ?? 8;
    final double percent = sleepGoal > 0 ? (sleepHours / sleepGoal).clamp(0.0, 1.0) : 0.0;

    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.bedDouble, color: AppTheme.chart3, size: 28),
                const SizedBox(width: 12),
                Text("Sleep Analysis", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: CircularPercentIndicator(
                radius: 70.0,
                lineWidth: 12.0,
                percent: percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${sleepHours}h", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                    Text("of $sleepGoal hours", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: AppTheme.surface.withAlpha(128),
                progressColor: AppTheme.chart3,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                   _showUpdateValueSheet(context, 'sleepHours', dailyProgress['sleepHours'] ?? 0);
                },
                child: const Text("Log Sleep"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.chart3,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context, Map<String, dynamic> dailyProgress, Map<String, dynamic> userData) {
    final calories = dailyProgress['caloriesBurned'] ?? 0;
    final calorieGoal = userData['calorieGoal'] ?? 500;
    final double percent = calorieGoal > 0 ? (calories / calorieGoal).clamp(0.0, 1.0) : 0.0;

    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                const Icon(LucideIcons.flame, color: AppTheme.chart4, size: 28),
                const SizedBox(width: 12),
                Text("Activity", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Center(child: Text("$calories / $calorieGoal kcal burned", style: AppTheme.textTheme.titleLarge)),
             const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: AppTheme.surface.withAlpha(128),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.chart4),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTips(BuildContext context) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                children: [
                  const Icon(LucideIcons.brainCircuit, color: AppTheme.accent, size: 28),
                  const SizedBox(width: 12),
                  Text("Tip of the Day", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              "Stay hydrated! Drinking enough water can help improve your mood, boost your energy levels, and prevent headaches.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateValueSheet(BuildContext context, String field, num currentValue) {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.surface.withAlpha(204),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Update ${field.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').capitalizeFirst()}", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'New Value',
                      filled: true,
                      fillColor: AppTheme.surface.withAlpha(128),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (value) {
                      final num? newValue = num.tryParse(value);
                      if (newValue != null) {
                         FirestoreService().updateDailyProgress(field, newValue);
                      }
                      Navigator.pop(context);
                    },
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text("Done"),
                    onPressed: () {
                        final num? newValue = num.tryParse(controller.text);
                        if (newValue != null) {
                          FirestoreService().updateDailyProgress(field, newValue);
                        }
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(50),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: child,
        ),
      ),
    );
  }
}
