import 'package:get/get.dart';
import '../controllers/mood_controller.dart';
import '../controllers/spotify_controller.dart';

/// Binding for MoodSelectView - initializes required controllers
class MoodBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize MoodController
    Get.lazyPut<MoodController>(() => MoodController());

    // Initialize SpotifyController (needed for fetching playlists)
    Get.lazyPut<SpotifyController>(() => SpotifyController());
  }
}
