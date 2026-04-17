/// Model class for Spotify Track data
class TrackModel {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String imageUrl;
  final String externalUrl;
  final String previewUrl; // 30 second preview
  final int durationMs;

  TrackModel({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.externalUrl,
    required this.previewUrl,
    required this.durationMs,
  });

  /// Factory constructor to create TrackModel from JSON
  factory TrackModel.fromJson(Map<String, dynamic> json) {
    // Get artists string
    final artists = json['artists'] as List?;
    final artistName = artists != null && artists.isNotEmpty
        ? artists.map((a) => a['name']).join(', ')
        : 'Unknown Artist';

    // Get album image
    final album = json['album'] as Map<String, dynamic>?;
    final albumImages = album?['images'] as List?;
    final imageUrl = albumImages != null && albumImages.isNotEmpty
        ? albumImages[0]['url']
        : '';

    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artist: artistName,
      album: album?['name'] ?? 'Unknown Album',
      imageUrl: imageUrl,
      externalUrl: json['external_urls']?['spotify'] ?? '',
      previewUrl: json['preview_url'] ?? '',
      durationMs: json['duration_ms'] ?? 0,
    );
  }

  /// Convert TrackModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'album': album,
      'imageUrl': imageUrl,
      'externalUrl': externalUrl,
      'previewUrl': previewUrl,
      'durationMs': durationMs,
    };
  }

  /// Get duration as formatted string (e.g., "3:45")
  String get formattedDuration {
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
