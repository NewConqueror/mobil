import 'package:get/get.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../services/spotify_service.dart';

/// Controller for managing Spotify playlists, tracks and API state
class SpotifyController extends GetxController {
  final SpotifyService _spotifyService = SpotifyService();

  // Reactive variables for playlists
  final playlists = <PlaylistModel>[].obs;

  // Reactive variables for tracks
  final tracks = <TrackModel>[].obs;

  // Single random track for Random Song feature
  final randomTrack = Rxn<TrackModel>();

  // Flag for random song mode
  final isRandomSongMode = false.obs;

  // Loading and error states
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Fetch both playlists and tracks based on mood
  Future<void> fetchContentByMood(String mood) async {
    try {
      // Set loading state
      isLoading.value = true;
      errorMessage.value = '';
      playlists.clear();
      tracks.clear();
      randomTrack.value = null;
      isRandomSongMode.value = false;

      // Fetch both playlists and tracks in parallel
      final results = await Future.wait([
        _spotifyService.searchPlaylists(mood),
        _spotifyService.searchTracks(mood),
      ]);

      playlists.value = results[0] as List<PlaylistModel>;
      tracks.value = results[1] as List<TrackModel>;

      // Check if both results are empty
      if (playlists.isEmpty && tracks.isEmpty) {
        errorMessage.value = 'No content found for this mood';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load content: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch a completely random song
  Future<void> fetchRandomSong() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      playlists.clear();
      tracks.clear();
      randomTrack.value = null;
      isRandomSongMode.value = true;

      // Get a single random track
      final track = await _spotifyService.getRandomTrack();

      if (track != null) {
        randomTrack.value = track;
      } else {
        errorMessage.value = 'Could not find a random song. Please try again!';
      }
    } catch (e) {
      errorMessage.value = 'Failed to get random song: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Shuffle to get another random song
  Future<void> shuffleRandomSong() async {
    await fetchRandomSong();
  }

  /// Fetch only playlists based on mood (for backward compatibility)
  Future<void> fetchPlaylistsByMood(String mood) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      playlists.clear();

      final results = await _spotifyService.searchPlaylists(mood);
      playlists.value = results;

      if (results.isEmpty) {
        errorMessage.value = 'No playlists found for this mood';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load playlists: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear current content
  void clearContent() {
    playlists.clear();
    tracks.clear();
    randomTrack.value = null;
    errorMessage.value = '';
    isRandomSongMode.value = false;
  }

  /// Retry fetching content
  void retry(String mood) {
    if (isRandomSongMode.value) {
      fetchRandomSong();
    } else {
      fetchContentByMood(mood);
    }
  }
}
