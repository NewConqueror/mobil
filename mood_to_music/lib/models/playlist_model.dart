/// Model class for Spotify Playlist data
class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String externalUrl;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.externalUrl,
  });

  /// Factory constructor to create PlaylistModel from JSON
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      imageUrl: json['images'] != null && (json['images'] as List).isNotEmpty
          ? json['images'][0]['url']
          : '',
      externalUrl: json['external_urls']?['spotify'] ?? '',
    );
  }

  /// Convert PlaylistModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'externalUrl': externalUrl,
    };
  }
}
