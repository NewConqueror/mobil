import 'dart:math';
import 'package:get/get.dart';

/// Controller for managing mood selection
class MoodController extends GetxController {
  // Selected mood stored as reactive string
  final selectedMood = ''.obs;

  // Flag for random song mode
  final isRandomSongMode = false.obs;

  // Available moods list - expanded with more options
  static const List<String> availableMoods = [
    'Happy',
    'Sad',
    'Energetic',
    'Calm',
    'Romantic',
    'Focused',
    'Angry',
    'Nostalgic',
    'Chill',
    'Party',
    'Sleepy',
    'Motivated',
    'Melancholic',
    'Adventurous',
    'Spiritual',
    'Confident',
  ];

  /// Mood descriptions for detailed information
  static const Map<String, String> moodDescriptions = {
    'happy': 'Neşeli, pozitif ve enerjik şarkılar. Güne güzel başlamak veya moralinizi yükseltmek için ideal. Gülümsetecek melodiler ve coşkulu ritimler.',
    'sad': 'Duygusal ve hüzünlü melodiler. Zor zamanlarınızda yanınızda olacak, içinizi dökmenize yardımcı olacak şarkılar. Bazen ağlamak da iyidir.',
    'energetic': 'Yüksek tempolu, adrenalin dolu parçalar. Spor yaparken, koşarken veya enerji patlaması yaşamak istediğinizde mükemmel seçim.',
    'calm': 'Sakinleştirici ve huzur verici melodiler. Stresli bir günün ardından rahatlama, meditasyon veya yoga için ideal ambient sesler.',
    'romantic': 'Aşk dolu, tutkulu ve duygusal şarkılar. Sevgilinizle özel bir akşam veya romantik anlar için mükemmel playlist.',
    'focused': 'Konsantrasyon ve odaklanma için tasarlanmış müzikler. Çalışırken, ders çalışırken veya kod yazarken dikkatinizi dağıtmayan melodiler.',
    'angry': 'Öfkenizi dışa vurmanıza yardımcı olacak güçlü ve yoğun parçalar. Rock, metal ve agresif beatler ile stresinizi atın.',
    'nostalgic': 'Geçmişe götüren, anıları canlandıran şarkılar. Eski güzel günleri hatırlamak ve tatlı bir hüzün yaşamak için.',
    'chill': 'Rahatlatıcı, laid-back ve soğukkanlı vibes. Arkadaşlarla takılırken veya evde dinlenirken perfect bir atmosfer.',
    'party': 'Dans pistini yakacak, herkesi ayağa kaldıracak hit parçalar. Parti, kutlama ve eğlence zamanları için en iyi seçimler.',
    'sleepy': 'Uykuya dalmadan önce dinlenebilecek yumuşak ve sakinleştirici melodiler. Derin uyku ve rüya dolu geceler için.',
    'motivated': 'Hedeflerinize ulaşmanız için ilham verecek güçlendirici şarkılar. Yeni başlangıçlar ve zorlukları aşmak için motivasyon.',
    'melancholic': 'Derin düşüncelere dalmak için melankolik ve düşündürücü melodiler. Hayatın anlamını sorgularken dinlenecek şarkılar.',
    'adventurous': 'Macera ve keşif ruhunu uyandıran epik parçalar. Yolculuklarda, yeni deneyimlerde ve cesaret gerektiren anlarda.',
    'spiritual': 'Ruhani ve içsel yolculuk için meditasyon, new age ve dünya müzikleri. İç huzuru ve manevi bağlantı arayanlar için.',
    'confident': 'Özgüveninizi artıracak güçlü ve kendinden emin şarkılar. Önemli sunumlar, mülakatlar veya cesarete ihtiyaç duyduğunuz anlar için.',
  };

  /// Update the selected mood
  void selectMood(String mood) {
    selectedMood.value = mood;
    isRandomSongMode.value = false;
  }

  /// Enable random song mode
  void enableRandomSongMode() {
    isRandomSongMode.value = true;
    selectedMood.value = 'Random Song';
  }

  /// Select a random mood from available moods
  String selectRandomMood() {
    final random = Random();
    final randomIndex = random.nextInt(availableMoods.length);
    final randomMood = availableMoods[randomIndex];
    selectedMood.value = randomMood;
    isRandomSongMode.value = false;
    return randomMood;
  }

  /// Get mood description
  String getMoodDescription(String mood) {
    return moodDescriptions[mood.toLowerCase()] ?? 'Bu mood için müzik keşfedin.';
  }

  /// Get background color based on selected mood
  String getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '#FFD700'; // Gold
      case 'sad':
        return '#4169E1'; // Royal Blue
      case 'energetic':
        return '#FF4500'; // Orange Red
      case 'calm':
        return '#20B2AA'; // Light Sea Green
      case 'romantic':
        return '#FF69B4'; // Hot Pink
      case 'focused':
        return '#9370DB'; // Medium Purple
      case 'angry':
        return '#DC143C'; // Crimson
      case 'nostalgic':
        return '#DEB887'; // Burlywood
      case 'chill':
        return '#87CEEB'; // Sky Blue
      case 'party':
        return '#FF1493'; // Deep Pink
      case 'sleepy':
        return '#483D8B'; // Dark Slate Blue
      case 'motivated':
        return '#32CD32'; // Lime Green
      case 'melancholic':
        return '#708090'; // Slate Gray
      case 'adventurous':
        return '#FF8C00'; // Dark Orange
      case 'spiritual':
        return '#8A2BE2'; // Blue Violet
      case 'confident':
        return '#B8860B'; // Dark Goldenrod
      case 'random song':
        return '#1DB954'; // Spotify Green
      default:
        return '#808080'; // Gray
    }
  }

  /// Get emoji icon for mood
  String getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'energetic':
        return '⚡';
      case 'calm':
        return '🧘';
      case 'romantic':
        return '💖';
      case 'focused':
        return '🎯';
      case 'angry':
        return '😤';
      case 'nostalgic':
        return '📼';
      case 'chill':
        return '😎';
      case 'party':
        return '🎉';
      case 'sleepy':
        return '😴';
      case 'motivated':
        return '💪';
      case 'melancholic':
        return '🌧️';
      case 'adventurous':
        return '🗺️';
      case 'spiritual':
        return '🕉️';
      case 'confident':
        return '👑';
      case 'random song':
        return '🎲';
      default:
        return '🎵';
    }
  }
}
