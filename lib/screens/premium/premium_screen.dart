import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // Default to the yearly plan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Go Premium', style: AppTheme.textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFeatureList(),
                const SizedBox(height: 24),
                _buildPlanSelector(),
                const SizedBox(height: 32),
                _buildCTAButton(),
                const SizedBox(height: 16),
                _buildFinePrint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withAlpha(100),
            blurRadius: 20,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.zap, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text('Unlock Your Full Potential',
              style: AppTheme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Get exclusive access to premium features and achieve your goals faster.',
              textAlign: TextAlign.center,
              style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white.withAlpha(200))),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {'icon': LucideIcons.pieChart, 'text': 'Detailed Analytics & Reports'},
      {'icon': LucideIcons.target, 'text': 'Unlimited Goal Tracking'},
      {'icon': LucideIcons.bookOpen, 'text': 'Exclusive Articles & Content'},
      {'icon': LucideIcons.sparkles, 'text': 'AI-Powered Insights'},
    ];
    return Column(
      children: features
          .map((feature) => ListTile(
                leading: Icon(feature['icon'] as IconData, color: AppTheme.primary, size: 28),
                title: Text(feature['text'] as String, style: AppTheme.textTheme.titleMedium),
                 contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ))
          .toList(),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      children: [
        PlanCard(
          title: 'Monthly Plan',
          price: '\$9.99',
          period: 'per month',
          isSelected: _selectedPlan == 0,
          onTap: () => setState(() => _selectedPlan = 0),
        ),
        const SizedBox(height: 16),
        PlanCard(
          title: 'Yearly Plan',
          price: '\$59.99',
          period: 'per year',
          badge: 'Save 50%',
          isSelected: _selectedPlan == 1,
          onTap: () => setState(() => _selectedPlan = 1),
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle purchase logic
      },
      child: Text('Continue', style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryForeground)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildFinePrint() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy. Your subscription will auto-renew unless canceled.',
      textAlign: TextAlign.center,
      style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard(
      {required this.title,
      required this.price,
      required this.period,
      this.badge,
      required this.isSelected,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withAlpha(26) : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1.5,
          ),
           boxShadow: isSelected ? [
             BoxShadow(
                color: AppTheme.primary.withAlpha(102),
                blurRadius: 15,
                spreadRadius: -8,
              ),
           ] : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? LucideIcons.checkCircle : LucideIcons.circle,
                  color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.baseline,
                         textBaseline: TextBaseline.alphabetic,
                         children: [
                           Text(price, style: AppTheme.textTheme.headlineSmall),
                           const SizedBox(width: 4),
                           Text(period, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                         ],
                       )
                    ],
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -30,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge!, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.surface, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
