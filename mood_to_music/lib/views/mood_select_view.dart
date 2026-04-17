import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mood_controller.dart';
import '../controllers/spotify_controller.dart';
import '../routes/app_routes.dart';

class MoodSelectView extends StatelessWidget {
  const MoodSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = Get.find<MoodController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade300,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Title
              const Text(
                '🎵 Mood to Music',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              // Mood Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                        ),
                    itemCount: MoodController.availableMoods.length,
                    itemBuilder: (context, index) {
                      final mood = MoodController.availableMoods[index];
                      return _buildMoodCard(mood, moodController);
                    },
                  ),
                ),
              ),
              // Special Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Random Song Button - NEW FEATURE
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Enable random song mode
                          moodController.enableRandomSongMode();

                          // Fetch random song
                          final spotifyController = Get.find<SpotifyController>();
                          spotifyController.fetchRandomSong();

                          // Navigate to playlist view
                          Get.toNamed(AppRoutes.playlist);
                        },
                        icon: const Icon(Icons.casino, size: 28),
                        label: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🎲 Random Song',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Surprise me with any song!',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954), // Spotify Green
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Random Vibe Button (existing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Select random mood
                          final randomMood = moodController.selectRandomMood();

                          // Fetch both playlists and tracks for random mood
                          final spotifyController = Get.find<SpotifyController>();
                          spotifyController.fetchContentByMood(randomMood);

                          // Navigate to playlist view
                          Get.toNamed(AppRoutes.playlist);
                        },
                        icon: const Icon(Icons.shuffle, size: 22),
                        label: const Text(
                          'Random Vibe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(String mood, MoodController moodController) {
    final emoji = moodController.getMoodEmoji(mood);
    final colorHex = moodController.getMoodColor(mood);
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    final description = moodController.getMoodDescription(mood);

    return GestureDetector(
      onTap: () {
        // Update selected mood
        moodController.selectMood(mood);

        // Fetch both playlists and tracks for this mood
        final spotifyController = Get.find<SpotifyController>();
        spotifyController.fetchContentByMood(mood);

        // Navigate to playlist view
        Get.toNamed(AppRoutes.playlist);
      },
      onLongPress: () {
        // Show mood description on long press
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Text(
                  mood,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Kapat'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  moodController.selectMood(mood);
                  final spotifyController = Get.find<SpotifyController>();
                  spotifyController.fetchContentByMood(mood);
                  Get.toNamed(AppRoutes.playlist);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Seç'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            // Mood name
            Text(
              mood,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            // Hint for long press
            Text(
              'Detay için basılı tut',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
