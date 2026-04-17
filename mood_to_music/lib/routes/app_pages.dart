import 'package:get/get.dart';
import '../views/mood_select_view.dart';
import '../views/playlist_view.dart';
import '../bindings/mood_binding.dart';
import '../bindings/playlist_binding.dart';
import 'app_routes.dart';

/// Define all GetX pages with their bindings
abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.mood,
      page: () => const MoodSelectView(),
      binding: MoodBinding(),
    ),
    GetPage(
      name: AppRoutes.playlist,
      page: () => const PlaylistView(),
      binding: PlaylistBinding(),
    ),
  ];
}
