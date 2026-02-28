
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/models/mood.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PsychologyScreen extends StatefulWidget {
  const PsychologyScreen({Key? key}) : super(key: key);

  @override
  _PsychologyScreenState createState() => _PsychologyScreenState();
}

class _PsychologyScreenState extends State<PsychologyScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<Mood> moods = [
    Mood(name: 'Happy', icon: LucideIcons.smile, color: Colors.green),
    Mood(name: 'Calm', icon: LucideIcons.coffee, color: Colors.blue),
    Mood(name: 'Productive', icon: LucideIcons.trendingUp, color: Colors.purple),
    Mood(name: 'Sad', icon: LucideIcons.frown, color: Colors.grey),
    Mood(name: 'Stressed', icon: LucideIcons.loader, color: Colors.orange),
  ];

  final List<String> _videoIds = [
    'Wp0u_J9fN8k', // Calming music
    'inpok4MKVLM', // Guided meditation
    '86sY0W1wDrI', // Ocean waves
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Your Mood'),
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
          final currentMood = dailyProgress['mood'] as String? ?? 'Calm';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodSelector(context, currentMood),
                const SizedBox(height: 32),
                _buildRelaxationVideos(context),
                const SizedBox(height: 32),
                _buildMoodHistory(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, String currentMood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("How are you feeling today?",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = mood.name == currentMood;
              return _buildMoodCard(context, mood, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCard(BuildContext context, Mood mood, bool isSelected) {
    return GestureDetector(
      onTap: () => _firestoreService.updateDailyProgress('mood', mood.name),
      child: _buildGlowContainer(
        color: isSelected ? mood.color : Colors.transparent,
        borderRadius: 28,
        child: _buildGlassCard(
          borderRadius: 28,
          child: SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mood.icon, size: 40, color: isSelected ? mood.color : AppTheme.onSurface),
                const SizedBox(height: 8),
                Text(mood.name, style: TextStyle(color: isSelected ? mood.color : AppTheme.onSurface)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelaxationVideos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Relaxation Videos", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _videoIds.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 300,
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: _videoIds[index],
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mood History", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildGlassCard(
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text("Mood chart coming soon!", style: TextStyle(color: AppTheme.mutedForeground)),
            ),
          ),
        ),
      ],
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
