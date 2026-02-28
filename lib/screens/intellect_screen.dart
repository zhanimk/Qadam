import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class IntellectPage extends StatefulWidget {
  final VoidCallback onBack;

  const IntellectPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _IntellectPageState createState() => _IntellectPageState();
}

class _IntellectPageState extends State<IntellectPage> with TickerProviderStateMixin {
  late AnimationController _staggeredController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  // Mock data for articles
  final List<Map<String, String>> articles = [
    {
      "title": "The Power of Habit: Why We Do What We Do",
      "author": "Charles Duhigg",
      "readTime": "15 min read",
      "image": "assets/images/placeholder1.jpg" // Add actual asset paths
    },
    {
      "title": "Atomic Habits: An Easy & Proven Way to Build Good Habits",
      "author": "James Clear",
      "readTime": "20 min read",
      "image": "assets/images/placeholder2.jpg"
    },
    {
      "title": "Deep Work: Rules for Focused Success in a Distracted World",
      "author": "Cal Newport",
      "readTime": "12 min read",
      "image": "assets/images/placeholder3.jpg"
    },
     {
      "title": "Thinking, Fast and Slow",
      "author": "Daniel Kahneman",
      "readTime": "25 min read",
      "image": "assets/images/placeholder1.jpg"
    },
  ];
  
  final List<String> filters = ["All", "Articles", "Podcasts", "Videos", "Courses"];


  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Widget _buildAnimatedChild(Widget child, {required double start, double? duration}) {
    return AnimatedBuilder(
      animation: _staggeredController,
      child: child,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(start, (start + (duration ?? 0.5)).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, (1.0 - curve.value) * 50),
            child: child,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFF080812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: widget.onBack,
        ),
        title: Text("Intellect Hub", style: AppTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedChild(_buildSearchBar(), start: 0.1),
            const SizedBox(height: 16),
            _buildAnimatedChild(_buildFilterChips(), start: 0.2),
            const SizedBox(height: 24),
            _buildAnimatedChild(_buildFeaturedSection(), start: 0.3),
            const SizedBox(height: 24),
            _buildAnimatedChild(_buildArticleList(), start: 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search articles, podcasts...",
          prefixIcon: const Icon(LucideIcons.search, color: AppTheme.mutedForeground),
          filled: true,
          fillColor: AppTheme.surface.withAlpha(50),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              backgroundColor: AppTheme.surface.withAlpha(50),
              selectedColor: AppTheme.accent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
              shape: StadiumBorder(
                side: BorderSide(color: isSelected ? AppTheme.accent : Colors.white.withAlpha(26))
              ),
            ),
          );
        },
      ),
    );
  }

   Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text("Featured", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 2, // only first 2 for featured
            itemBuilder: (context, index) {
              final article = articles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 280,
                  child: _buildGlassCard(
                    isTappable: true,
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Placeholder for image
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                             color: AppTheme.surface,
                             borderRadius: const BorderRadius.vertical(top: Radius.circular(28))
                          ),
                          child: const Center(child: Icon(LucideIcons.image, color: AppTheme.mutedForeground, size: 40)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title']!,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${article['author']!} • ${article['readTime']!}",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArticleList() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 24.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Text("All Articles", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildArticleListItem(article),
                );
              },
            ),
         ],
       ),
     );
  }
  
  Widget _buildArticleListItem(Map<String, String> article) {
    return _buildGlassCard(
      isTappable: true,
      onTap: () {},
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16)
              ),
              child: const Center(child: Icon(LucideIcons.bookOpen, color: AppTheme.mutedForeground, size: 30)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${article['author']!} • ${article['readTime']!}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.arrowRight, color: AppTheme.mutedForeground)
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, bool isTappable = false, double borderRadius = 28, VoidCallback? onTap}) {
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
