import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Import the real AuthScreen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Re-run animations for the new page
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(), // Navigate to the real AuthScreen
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // Onboarding data based on the design
  static final List<Map<String, dynamic>> _onboardingData = [
    {
      'icon': Icons.psychology,
      'gradient': [const Color(0xFFF92B7B), const Color(0xFF9040F8)],
      'title': 'Welcome to Qadam',
      'subtitle': 'Your Personal Growth Journey',
      'description': 'Transform your life one step at a time with our comprehensive self-development platform.',
      'features': null,
      'bottom_nav_label': 'Psychology',
    },
    {
      'icon': Icons.track_changes,
      'gradient': [const Color(0xFF00D2FF), const Color(0xFF3A7BD5)],
      'title': 'Set & Achieve Goals',
      'subtitle': 'Build Your Future',
      'description': 'Create meaningful goals, track your progress, and celebrate every milestone on your journey to success.',
      'features': [
        'Smart goal tracking',
        'Progress milestones',
        'Achievement rewards',
      ],
      'bottom_nav_label': 'Goals',
    },
    {
      'icon': Icons.show_chart, // Icon for the new screen
      'gradient': [const Color(0xFF11998e), const Color(0xFF38ef7d)], // Green gradient for the new screen
      'title': 'Track Your Growth',
      'subtitle': 'Measure What Matters',
      'description': 'Visualize your development across psychology, finance, health, intellect, and time management.',
      'features': [
        '5 key development areas',
        'Advanced analytics',
        'Weekly insights',
      ],
      'bottom_nav_label': 'Health', // Updated label
    },
    {
      'icon': Icons.military_tech,
      'gradient': [const Color(0xFFb92b27), const Color(0xFF1565C0)],
      'title': 'Earn Rewards',
      'subtitle': 'Celebrate Your Wins',
      'description': 'Stay motivated by earning rewards and celebrating your achievements along the way.',
      'features': null,
      'bottom_nav_label': 'Rewards',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13112A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTopIcon(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(data: _onboardingData[index]);
                },
              ),
            ),
            _buildPageIndicators(),
            const SizedBox(height: 20),
            _buildBottomNav(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIcon() {
    final data = _onboardingData[_currentPage];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: Container(
        key: ValueKey<int>(_currentPage), // Important for AnimatedSwitcher
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: data['gradient'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (data['gradient'] as List<Color>).first.withAlpha(102),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(data['icon'], color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildOnboardingPage({required Map<String, dynamic> data}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1D36),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(77),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDecorativeBar(data['gradient'], data['icon']),
                      const SizedBox(height: 30),
                      _buildTexts(data),
                      if (data['features'] != null)
                         _buildFeaturesList(data['features']!),
                      const SizedBox(height: 40),
                      _buildButtons(data['gradient']),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeBar(List<Color> gradientColors, IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildTexts(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26, // Increased font size
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data['subtitle'],
          style: const TextStyle(
            color: Color(0xFF9F92E3),
            fontSize: 18, // Increased font size
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          data['description'],
          style: TextStyle(
            color: Colors.white.withAlpha(204),
            fontSize: 17, // Increased font size
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(List<String> features) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFF2A2849),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9F92E3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Increased font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButtons(List<Color> gradientColors) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _navigateToAuth,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: Colors.grey.withAlpha(128)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_currentPage < _onboardingData.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              } else {
                _navigateToAuth();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Next', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_onboardingData.length, (index) {
        final gradient = _onboardingData[_currentPage]['gradient'] as List<Color>;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: 8,
          width: _currentPage == index ? 28 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: _currentPage == index ? gradient.last.withAlpha(204) : Colors.grey.withAlpha(128),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_onboardingData.length, (index) {
          final data = _onboardingData[index];
          final bool isSelected = _currentPage == index;
          return GestureDetector(
            onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data['icon'], color: isSelected ? Colors.white : Colors.grey.withAlpha(178)),
                const SizedBox(height: 8),
                Text(
                  data['bottom_nav_label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.withAlpha(178),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
