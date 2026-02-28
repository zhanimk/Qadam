
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Health Tracking'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final userData = snapshot.data?.data() ?? {};
          final dailyProgress =
              userData['dailyProgress'] as Map<String, dynamic>? ?? {};
          final waterIntake = (dailyProgress['waterIntake'] ?? 0).toDouble();
          final waterGoal = (dailyProgress['waterGoal'] ?? 8).toDouble();
          final weight = (dailyProgress['weight'] ?? 0.0).toDouble();
          final waterProgress =
              waterGoal > 0 ? (waterIntake / waterGoal).clamp(0.0, 1.0) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWaterTracker(
                    context, waterIntake, waterGoal, waterProgress),
                const SizedBox(height: 32),
                _buildOtherMetrics(context, weight),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaterTracker(BuildContext context, double waterIntake,
      double waterGoal, double waterProgress) {
    return _buildGlowContainer(
      color: Colors.blue,
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Water Intake",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Center(
                child: CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 15.0,
                  percent: waterProgress,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.glassWater,
                          size: 40, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        "${waterIntake.toStringAsFixed(1)} L",
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface),
                      ),
                      Text(
                        "of ${waterGoal.toStringAsFixed(1)} L",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.mutedForeground),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: AppTheme.surface.withAlpha(128),
                  progressColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWaterButton(context, "-1", -1.0, false),
                  _buildWaterButton(context, "+0.25", 0.25, true),
                  _buildWaterButton(context, "+0.5", 0.5, true),
                  _buildWaterButton(context, "+1", 1.0, true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterButton(
      BuildContext context, String label, double amount, bool isAdding) {
    return ElevatedButton(
      onPressed: () {
        _firestoreService.incrementDailyProgress('waterIntake', amount);
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isAdding ? Colors.blue : AppTheme.surface.withAlpha(128),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildOtherMetrics(BuildContext context, double weight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Other Metrics",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildMetricCard(context, "Calories", "1200 kcal", LucideIcons.flame, Colors.orange, isTappable: false),
        const SizedBox(height: 16),
        _buildMetricCard(context, "Weight", "${weight.toStringAsFixed(1)} kg", LucideIcons.activity, Colors.green, isTappable: true, onTap: () => _showWeightInputDialog(context, weight)),
      ],
    );
  }

  void _showWeightInputDialog(BuildContext context, double currentWeight) {
    final TextEditingController controller = TextEditingController(text: currentWeight.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: const Text("Enter Your Weight"),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(hintText: "kg"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final double? newWeight = double.tryParse(controller.text);
                if (newWeight != null) {
                  _firestoreService.updateDailyProgress('weight', newWeight);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color, {bool isTappable = false, VoidCallback? onTap}) {
    return _buildGlassCard(
      isTappable: isTappable,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowContainer(
      {required Widget child, required Color color, double borderRadius = 28}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 25,
              spreadRadius: -8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGlassCard(
      {required Widget child,
      bool isTappable = false,
      double borderRadius = 28,
      VoidCallback? onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(50),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: isTappable
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: child,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}
