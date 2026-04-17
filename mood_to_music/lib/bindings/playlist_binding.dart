import 'package:get/get.dart';
import '../controllers/mood_controller.dart';
import '../controllers/spotify_controller.dart';

/// Binding for PlaylistView - ensures controllers are available
class PlaylistBinding extends Bindings {
  @override
  void dependencies() {
    // MoodController should already exist, but ensure it's available
    Get.lazyPut<MoodController>(() => MoodController(), fenix: true);

    // SpotifyController should already exist, but ensure it's available
    Get.lazyPut<SpotifyController>(() => SpotifyController(), fenix: true);
  }
}
