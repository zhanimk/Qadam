
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({Key? key}) : super(key: key);

  @override
  _SpendingScreenState createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface.withAlpha(240),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Financial Goals', style: AppTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getSpendingGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final goals = snapshot.data!.docs;

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final data = goal.data();
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildGoalCard(data, goal.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(),
        backgroundColor: AppTheme.accent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.piggyBank, size: 80, color: AppTheme.mutedForeground),
          const SizedBox(height: 20),
          Text('No Financial Goals Yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tap the + button to add a goal!', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> data, String goalId) {
    final title = data['title'] ?? 'Untitled Goal';
    final targetAmount = (data['targetAmount'] ?? 0).toDouble();
    final savedAmount = (data['savedAmount'] ?? 0).toDouble();
    final progress = targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Saved: \$${savedAmount.toStringAsFixed(2)} / \$${targetAmount.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 14)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.surface.withAlpha(128),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(LucideIcons.plusCircle, size: 18),
                    label: const Text('Add Funds'),
                    onPressed: () => _showUpdateFundsSheet(goalId, savedAmount, targetAmount),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                     icon: const Icon(LucideIcons.trash2, size: 18),
                     label: const Text('Delete'),
                     onPressed: () => _firestoreService.deleteSpendingGoal(goalId),
                     style: TextButton.styleFrom(foregroundColor: AppTheme.chart5),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  
  void _showUpdateFundsSheet(String goalId, double currentSaved, double target) {
    final TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGlassModal(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Funds', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Amount to Add',
                  labelStyle: const TextStyle(color: AppTheme.mutedForeground),
                  filled: true,
                  fillColor: AppTheme.surface.withAlpha(128),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final double? amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0) {
                      _firestoreService.updateSpendingGoal(goalId, {'savedAmount': currentSaved + amount});
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                  style: _getButtonStyle(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGoalSheet() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController targetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGlassModal(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Financial Goal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: _getInputDecoration('Goal Title (e.g., New Laptop)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: _getInputDecoration('Target Amount (\$)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final String title = titleController.text;
                    final double? target = double.tryParse(targetController.text);
                    if (title.isNotEmpty && target != null && target > 0) {
                      _firestoreService.addSpendingGoal({
                        'title': title,
                        'targetAmount': target,
                        'savedAmount': 0.0,
                        'createdAt': Timestamp.now(),
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save Goal'),
                  style: _getButtonStyle(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.mutedForeground),
        filled: true,
        fillColor: AppTheme.surface.withAlpha(128),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      );
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: AppTheme.accent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildGlassModal({required Widget child}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(220),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, double borderRadius = 20}) {
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
          child: child,
        ),
      ),
    );
  }
}
