import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../config/spotify_config.dart';

/// Service class for Spotify API interactions
class SpotifyService {
  String? _accessToken;
  DateTime? _tokenExpiry;
  final Random _random = Random();

  /// Get Spotify access token using Client Credentials flow
  Future<String?> getAccessToken() async {
    // Return cached token if still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      // Create credentials for Basic Auth
      final credentials = base64Encode(
        utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'),
      );

      final response = await http.post(
        Uri.parse(SpotifyConfig.authUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];

        // Token expires in 3600 seconds (1 hour), store expiry time
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));

        return _accessToken;
      } else {
        debugPrint('Failed to get access token: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  /// Search playlists based on mood
  Future<List<PlaylistModel>> searchPlaylists(String mood) async {
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        debugPrint('No access token available, using mock data');
        return _getMockPlaylists(mood);
      }

      // Get search query for mood
      final query = SpotifyConfig.moodToQuery[mood.toLowerCase()] ?? mood;

      // Search for playlists
      final response = await http.get(
        Uri.parse(
          '${SpotifyConfig.baseUrl}/search?q=$query&type=playlist&limit=10',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playlists = data['playlists']['items'] as List;

        return playlists.map((item) => PlaylistModel.fromJson(item)).toList();
      } else {
        debugPrint('Failed to search playlists: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        // Fallback to mock data
        return _getMockPlaylists(mood);
      }
    } catch (e) {
      debugPrint('Error searching playlists: $e');
      // Fallback to mock data
      return _getMockPlaylists(mood);
    }
  }

  /// Search tracks based on mood
  Future<List<TrackModel>> searchTracks(String mood) async {
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        debugPrint('No access token available, using mock data');
        return _getMockTracks(mood);
      }

      // Get search query for mood
      final query = SpotifyConfig.moodToQuery[mood.toLowerCase()] ?? mood;

      // Search for tracks
      final response = await http.get(
        Uri.parse(
          '${SpotifyConfig.baseUrl}/search?q=$query&type=track&limit=10',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;

        return tracks.map((item) => TrackModel.fromJson(item)).toList();
      } else {
        debugPrint('Failed to search tracks: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        // Fallback to mock data
        return _getMockTracks(mood);
      }
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      // Fallback to mock data
      return _getMockTracks(mood);
    }
  }

  /// Fallback mock data method for playlists
  Future<List<PlaylistModel>> _getMockPlaylists(String mood) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock playlists based on mood
    switch (mood.toLowerCase()) {
      case 'happy':
        return _getHappyPlaylists();
      case 'sad':
        return _getSadPlaylists();
      case 'energetic':
        return _getEnergeticPlaylists();
      case 'calm':
        return _getCalmPlaylists();
      case 'romantic':
        return _getRomanticPlaylists();
      case 'focused':
        return _getFocusedPlaylists();
      case 'angry':
        return _getAngryPlaylists();
      case 'nostalgic':
        return _getNostalgicPlaylists();
      case 'chill':
        return _getChillPlaylists();
      case 'party':
        return _getPartyPlaylists();
      case 'sleepy':
        return _getSleepyPlaylists();
      case 'motivated':
        return _getMotivatedPlaylists();
      case 'melancholic':
        return _getMelancholicPlaylists();
      case 'adventurous':
        return _getAdventurousPlaylists();
      case 'spiritual':
        return _getSpiritualPlaylists();
      case 'confident':
        return _getConfidentPlaylists();
      default:
        return [];
    }
  }

  /// Fallback mock data method for tracks
  Future<List<TrackModel>> _getMockTracks(String mood) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock tracks based on mood
    switch (mood.toLowerCase()) {
      case 'happy':
        return _getHappyTracks();
      case 'sad':
        return _getSadTracks();
      case 'energetic':
        return _getEnergeticTracks();
      case 'calm':
        return _getCalmTracks();
      case 'romantic':
        return _getRomanticTracks();
      case 'focused':
        return _getFocusedTracks();
      case 'angry':
        return _getAngryTracks();
      case 'nostalgic':
        return _getNostalgicTracks();
      case 'chill':
        return _getChillTracks();
      case 'party':
        return _getPartyTracks();
      case 'sleepy':
        return _getSleepyTracks();
      case 'motivated':
        return _getMotivatedTracks();
      case 'melancholic':
        return _getMelancholicTracks();
      case 'adventurous':
        return _getAdventurousTracks();
      case 'spiritual':
        return _getSpiritualTracks();
      case 'confident':
        return _getConfidentTracks();
      default:
        return [];
    }
  }

  List<PlaylistModel> _getHappyPlaylists() {
    return [
      PlaylistModel(
        id: '1',
        name: 'Happy Hits!',
        description: 'Feel-good songs to put you in a great mood',
        imageUrl: 'https://picsum.photos/seed/happy1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC',
      ),
      PlaylistModel(
        id: '2',
        name: 'Good Vibes',
        description: 'Positive energy for your day',
        imageUrl: 'https://picsum.photos/seed/happy2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX3rxVfibe1L0',
      ),
      PlaylistModel(
        id: '3',
        name: 'Sunny Day Mix',
        description: 'Bright songs for sunny moments',
        imageUrl: 'https://picsum.photos/seed/happy3/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWSf2RDTDayIx',
      ),
    ];
  }

  List<PlaylistModel> _getSadPlaylists() {
    return [
      PlaylistModel(
        id: '4',
        name: 'Life Sucks',
        description: 'Songs for when you need a good cry',
        imageUrl: 'https://picsum.photos/seed/sad1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1',
      ),
      PlaylistModel(
        id: '5',
        name: 'Sad Songs',
        description: 'Melancholic tunes for emotional moments',
        imageUrl: 'https://picsum.photos/seed/sad2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX3YSRoSdA634',
      ),
    ];
  }

  List<PlaylistModel> _getEnergeticPlaylists() {
    return [
      PlaylistModel(
        id: '6',
        name: 'Power Workout',
        description: 'High energy music to fuel your workout',
        imageUrl: 'https://picsum.photos/seed/energy1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP',
      ),
      PlaylistModel(
        id: '7',
        name: 'Beast Mode',
        description: 'Get pumped with these energetic tracks',
        imageUrl: 'https://picsum.photos/seed/energy2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4eRPd9frC1m',
      ),
    ];
  }

  List<PlaylistModel> _getCalmPlaylists() {
    return [
      PlaylistModel(
        id: '8',
        name: 'Peaceful Piano',
        description: 'Relax with peaceful piano music',
        imageUrl: 'https://picsum.photos/seed/calm1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
      ),
      PlaylistModel(
        id: '9',
        name: 'Chill Vibes',
        description: 'Calm and relaxing tunes',
        imageUrl: 'https://picsum.photos/seed/calm2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6',
      ),
    ];
  }

  List<PlaylistModel> _getRomanticPlaylists() {
    return [
      PlaylistModel(
        id: '10',
        name: 'Love Songs',
        description: 'Romantic songs for special moments',
        imageUrl: 'https://picsum.photos/seed/romance1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX50QitC6Oqtn',
      ),
      PlaylistModel(
        id: '11',
        name: 'Date Night',
        description: 'Perfect playlist for date night',
        imageUrl: 'https://picsum.photos/seed/romance2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX5idnIr2QFzL',
      ),
    ];
  }

  List<PlaylistModel> _getFocusedPlaylists() {
    return [
      PlaylistModel(
        id: '12',
        name: 'Deep Focus',
        description: 'Concentration music for productivity',
        imageUrl: 'https://picsum.photos/seed/focus1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
      ),
      PlaylistModel(
        id: '13',
        name: 'Study Music',
        description: 'Music to help you focus on your work',
        imageUrl: 'https://picsum.photos/seed/focus2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX8NTLI2TtZa6',
      ),
    ];
  }

  // New mood playlist methods
  List<PlaylistModel> _getAngryPlaylists() {
    return [
      PlaylistModel(
        id: '14',
        name: 'Rage Beats',
        description: 'Let out your anger with heavy tracks',
        imageUrl: 'https://picsum.photos/seed/angry1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX8n1qJ5bY0tG',
      ),
      PlaylistModel(
        id: '15',
        name: 'Metal Essentials',
        description: 'Heavy metal for intense moments',
        imageUrl: 'https://picsum.photos/seed/angry2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX3qCx5yEZM9A',
      ),
    ];
  }

  List<PlaylistModel> _getNostalgicPlaylists() {
    return [
      PlaylistModel(
        id: '16',
        name: '80s Hits',
        description: 'Classic hits from the 80s',
        imageUrl: 'https://picsum.photos/seed/nostalgia1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4UtSsGT1Sbe',
      ),
      PlaylistModel(
        id: '17',
        name: '90s Throwback',
        description: 'Remember the good old days',
        imageUrl: 'https://picsum.photos/seed/nostalgia2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXbTxeAdrVG2l',
      ),
    ];
  }

  List<PlaylistModel> _getChillPlaylists() {
    return [
      PlaylistModel(
        id: '18',
        name: 'Chill Hits',
        description: 'Laid back and easy going hits',
        imageUrl: 'https://picsum.photos/seed/chill1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6',
      ),
      PlaylistModel(
        id: '19',
        name: 'Lofi Beats',
        description: 'Chill beats to study/relax to',
        imageUrl: 'https://picsum.photos/seed/chill2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWWQRwui0ExPn',
      ),
    ];
  }

  List<PlaylistModel> _getPartyPlaylists() {
    return [
      PlaylistModel(
        id: '20',
        name: 'Party Hits',
        description: 'Get the party started!',
        imageUrl: 'https://picsum.photos/seed/party1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXaXB8fQg7xif',
      ),
      PlaylistModel(
        id: '21',
        name: 'Dance Party',
        description: 'Non-stop dance hits',
        imageUrl: 'https://picsum.photos/seed/party2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX0BcQWzuB7ZO',
      ),
    ];
  }

  List<PlaylistModel> _getSleepyPlaylists() {
    return [
      PlaylistModel(
        id: '22',
        name: 'Sleep',
        description: 'Soft music to help you fall asleep',
        imageUrl: 'https://picsum.photos/seed/sleep1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZd79rJ6a7lp',
      ),
      PlaylistModel(
        id: '23',
        name: 'Night Rain',
        description: 'Peaceful sounds for restful sleep',
        imageUrl: 'https://picsum.photos/seed/sleep2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWStLt4f1zHPB',
      ),
    ];
  }

  List<PlaylistModel> _getMotivatedPlaylists() {
    return [
      PlaylistModel(
        id: '24',
        name: 'Motivation Mix',
        description: 'Songs to push you forward',
        imageUrl: 'https://picsum.photos/seed/motivation1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdxcBWuJkbcy',
      ),
      PlaylistModel(
        id: '25',
        name: 'Winning Mindset',
        description: 'Achieve your goals',
        imageUrl: 'https://picsum.photos/seed/motivation2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX1s9knjP51Oa',
      ),
    ];
  }

  List<PlaylistModel> _getMelancholicPlaylists() {
    return [
      PlaylistModel(
        id: '26',
        name: 'Melancholia',
        description: 'Deep and thoughtful music',
        imageUrl: 'https://picsum.photos/seed/melancholy1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWVjSmmXz6oKV',
      ),
      PlaylistModel(
        id: '27',
        name: 'Rainy Day',
        description: 'Perfect for introspection',
        imageUrl: 'https://picsum.photos/seed/melancholy2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXbvABJXBIyiY',
      ),
    ];
  }

  List<PlaylistModel> _getAdventurousPlaylists() {
    return [
      PlaylistModel(
        id: '28',
        name: 'Epic Soundtrack',
        description: 'Music for your adventures',
        imageUrl: 'https://picsum.photos/seed/adventure1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX1h4hS9SbW9W',
      ),
      PlaylistModel(
        id: '29',
        name: 'Road Trip',
        description: 'Songs for the journey',
        imageUrl: 'https://picsum.photos/seed/adventure2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX8n1qJ5bY0tG',
      ),
    ];
  }

  List<PlaylistModel> _getSpiritualPlaylists() {
    return [
      PlaylistModel(
        id: '30',
        name: 'Meditation Music',
        description: 'Find your inner peace',
        imageUrl: 'https://picsum.photos/seed/spiritual1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZqd5JAYS6BP',
      ),
      PlaylistModel(
        id: '31',
        name: 'Healing Sounds',
        description: 'Music for the soul',
        imageUrl: 'https://picsum.photos/seed/spiritual2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX9uKNf5jGX6m',
      ),
    ];
  }

  List<PlaylistModel> _getConfidentPlaylists() {
    return [
      PlaylistModel(
        id: '32',
        name: 'Confidence Boost',
        description: 'Feel unstoppable',
        imageUrl: 'https://picsum.photos/seed/confident1/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX5g856aiKiDS',
      ),
      PlaylistModel(
        id: '33',
        name: 'Boss Vibes',
        description: 'Walk in like you own it',
        imageUrl: 'https://picsum.photos/seed/confident2/300',
        externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX7FY5ma9Uq0I',
      ),
    ];
  }

  // Mock Track Data Methods
  List<TrackModel> _getHappyTracks() {
    return [
      TrackModel(
        id: 't1',
        name: 'Happy',
        artist: 'Pharrell Williams',
        album: 'G I R L',
        imageUrl: 'https://picsum.photos/seed/track1/300',
        externalUrl: 'https://open.spotify.com/track/60nZcImufyMA1MKQY3dcCH',
        previewUrl: '',
        durationMs: 233000,
      ),
      TrackModel(
        id: 't2',
        name: 'Good Vibrations',
        artist: 'The Beach Boys',
        album: 'Smiley Smile',
        imageUrl: 'https://picsum.photos/seed/track2/300',
        externalUrl: 'https://open.spotify.com/track/3CA9pLiwRIGtUBiMjbZmRw',
        previewUrl: '',
        durationMs: 219000,
      ),
      TrackModel(
        id: 't3',
        name: 'Walking on Sunshine',
        artist: 'Katrina and the Waves',
        album: 'Walking on Sunshine',
        imageUrl: 'https://picsum.photos/seed/track3/300',
        externalUrl: 'https://open.spotify.com/track/05wIrZSwuaVWhcv5FfqeH0',
        previewUrl: '',
        durationMs: 239000,
      ),
    ];
  }

  List<TrackModel> _getSadTracks() {
    return [
      TrackModel(
        id: 't4',
        name: 'Someone Like You',
        artist: 'Adele',
        album: '21',
        imageUrl: 'https://picsum.photos/seed/track4/300',
        externalUrl: 'https://open.spotify.com/track/1zwMYTA5nlNjZxYrvBB2pV',
        previewUrl: '',
        durationMs: 285000,
      ),
      TrackModel(
        id: 't5',
        name: 'The Night We Met',
        artist: 'Lord Huron',
        album: 'Strange Trails',
        imageUrl: 'https://picsum.photos/seed/track5/300',
        externalUrl: 'https://open.spotify.com/track/0NRHj8hDwwmSPaA41o379r',
        previewUrl: '',
        durationMs: 208000,
      ),
    ];
  }

  List<TrackModel> _getEnergeticTracks() {
    return [
      TrackModel(
        id: 't6',
        name: 'Eye of the Tiger',
        artist: 'Survivor',
        album: 'Eye of the Tiger',
        imageUrl: 'https://picsum.photos/seed/track6/300',
        externalUrl: 'https://open.spotify.com/track/2KH16WveTQWT6KOG9Rg6e2',
        previewUrl: '',
        durationMs: 245000,
      ),
      TrackModel(
        id: 't7',
        name: "Can't Stop",
        artist: 'Red Hot Chili Peppers',
        album: 'By the Way',
        imageUrl: 'https://picsum.photos/seed/track7/300',
        externalUrl: 'https://open.spotify.com/track/3ZOEytgrvLwQaqXreDs2Jx',
        previewUrl: '',
        durationMs: 269000,
      ),
    ];
  }

  List<TrackModel> _getCalmTracks() {
    return [
      TrackModel(
        id: 't8',
        name: 'Weightless',
        artist: 'Marconi Union',
        album: 'Weightless',
        imageUrl: 'https://picsum.photos/seed/track8/300',
        externalUrl: 'https://open.spotify.com/track/4DgCIxFYGX8tyOa5DkI6L',
        previewUrl: '',
        durationMs: 482000,
      ),
      TrackModel(
        id: 't9',
        name: 'Clair de Lune',
        artist: 'Claude Debussy',
        album: 'Suite Bergamasque',
        imageUrl: 'https://picsum.photos/seed/track9/300',
        externalUrl: 'https://open.spotify.com/track/7s2We8KRH0J5tlTHJ5pBPj',
        previewUrl: '',
        durationMs: 298000,
      ),
    ];
  }

  List<TrackModel> _getRomanticTracks() {
    return [
      TrackModel(
        id: 't10',
        name: 'Perfect',
        artist: 'Ed Sheeran',
        album: '÷ (Divide)',
        imageUrl: 'https://picsum.photos/seed/track10/300',
        externalUrl: 'https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v',
        previewUrl: '',
        durationMs: 263000,
      ),
      TrackModel(
        id: 't11',
        name: 'At Last',
        artist: 'Etta James',
        album: 'At Last!',
        imageUrl: 'https://picsum.photos/seed/track11/300',
        externalUrl: 'https://open.spotify.com/track/4QNpBfC0zvjKqPJcyqBy9W',
        previewUrl: '',
        durationMs: 180000,
      ),
    ];
  }

  List<TrackModel> _getFocusedTracks() {
    return [
      TrackModel(
        id: 't12',
        name: 'Lofi Study',
        artist: 'Lofi Girl',
        album: 'Focus Beats',
        imageUrl: 'https://picsum.photos/seed/track12/300',
        externalUrl: 'https://open.spotify.com/track/3xKsf9qdS1CyvXSMEid6g8',
        previewUrl: '',
        durationMs: 156000,
      ),
      TrackModel(
        id: 't13',
        name: 'Brain Food',
        artist: 'Study Music',
        album: 'Concentration',
        imageUrl: 'https://picsum.photos/seed/track13/300',
        externalUrl: 'https://open.spotify.com/track/2rPE9A1vEgShuZxxzR2tZH',
        previewUrl: '',
        durationMs: 189000,
      ),
    ];
  }

  // New mood track methods
  List<TrackModel> _getAngryTracks() {
    return [
      TrackModel(
        id: 't14',
        name: 'Break Stuff',
        artist: 'Limp Bizkit',
        album: 'Significant Other',
        imageUrl: 'https://picsum.photos/seed/track14/300',
        externalUrl: 'https://open.spotify.com/track/3aBkHbMjHqhVNKxLNr2xqS',
        previewUrl: '',
        durationMs: 166000,
      ),
      TrackModel(
        id: 't15',
        name: 'Killing in the Name',
        artist: 'Rage Against the Machine',
        album: 'Rage Against the Machine',
        imageUrl: 'https://picsum.photos/seed/track15/300',
        externalUrl: 'https://open.spotify.com/track/59WN2psjkt1tyaxjspN8fp',
        previewUrl: '',
        durationMs: 312000,
      ),
    ];
  }

  List<TrackModel> _getNostalgicTracks() {
    return [
      TrackModel(
        id: 't16',
        name: 'Take On Me',
        artist: 'a-ha',
        album: 'Hunting High and Low',
        imageUrl: 'https://picsum.photos/seed/track16/300',
        externalUrl: 'https://open.spotify.com/track/2WfaOiMkCvy7F5fcp2zZ8L',
        previewUrl: '',
        durationMs: 225000,
      ),
      TrackModel(
        id: 't17',
        name: 'Sweet Child O Mine',
        artist: "Guns N' Roses",
        album: 'Appetite for Destruction',
        imageUrl: 'https://picsum.photos/seed/track17/300',
        externalUrl: 'https://open.spotify.com/track/7o2CTH4ctstm8TNelqjb51',
        previewUrl: '',
        durationMs: 356000,
      ),
    ];
  }

  List<TrackModel> _getChillTracks() {
    return [
      TrackModel(
        id: 't18',
        name: 'Sunset Lover',
        artist: 'Petit Biscuit',
        album: 'Presence',
        imageUrl: 'https://picsum.photos/seed/track18/300',
        externalUrl: 'https://open.spotify.com/track/0FDzzruyVECATHXKHFs9eJ',
        previewUrl: '',
        durationMs: 210000,
      ),
      TrackModel(
        id: 't19',
        name: 'Electric Feel',
        artist: 'MGMT',
        album: 'Oracular Spectacular',
        imageUrl: 'https://picsum.photos/seed/track19/300',
        externalUrl: 'https://open.spotify.com/track/3FtYbEfBqAlGO46NUDQSAt',
        previewUrl: '',
        durationMs: 229000,
      ),
    ];
  }

  List<TrackModel> _getPartyTracks() {
    return [
      TrackModel(
        id: 't20',
        name: "Don't Start Now",
        artist: 'Dua Lipa',
        album: 'Future Nostalgia',
        imageUrl: 'https://picsum.photos/seed/track20/300',
        externalUrl: 'https://open.spotify.com/track/6WrI0LAC5M1Rw2MnX2ZvEg',
        previewUrl: '',
        durationMs: 183000,
      ),
      TrackModel(
        id: 't21',
        name: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        imageUrl: 'https://picsum.photos/seed/track21/300',
        externalUrl: 'https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b',
        previewUrl: '',
        durationMs: 200000,
      ),
    ];
  }

  List<TrackModel> _getSleepyTracks() {
    return [
      TrackModel(
        id: 't22',
        name: 'Gymnopédie No. 1',
        artist: 'Erik Satie',
        album: 'Gymnopédies',
        imageUrl: 'https://picsum.photos/seed/track22/300',
        externalUrl: 'https://open.spotify.com/track/5NGtFXVpXSvwunEIGeviY3',
        previewUrl: '',
        durationMs: 195000,
      ),
      TrackModel(
        id: 't23',
        name: 'Nocturne No. 2',
        artist: 'Frédéric Chopin',
        album: 'Nocturnes',
        imageUrl: 'https://picsum.photos/seed/track23/300',
        externalUrl: 'https://open.spotify.com/track/5xEM5hIgJ1jjgcMCJqUJfP',
        previewUrl: '',
        durationMs: 252000,
      ),
    ];
  }

  List<TrackModel> _getMotivatedTracks() {
    return [
      TrackModel(
        id: 't24',
        name: 'Stronger',
        artist: 'Kanye West',
        album: 'Graduation',
        imageUrl: 'https://picsum.photos/seed/track24/300',
        externalUrl: 'https://open.spotify.com/track/4fzsfWzRhPawzqhX8Qt9F3',
        previewUrl: '',
        durationMs: 312000,
      ),
      TrackModel(
        id: 't25',
        name: 'Lose Yourself',
        artist: 'Eminem',
        album: '8 Mile',
        imageUrl: 'https://picsum.photos/seed/track25/300',
        externalUrl: 'https://open.spotify.com/track/5Z01UMMf7V1o0MzF86s6WJ',
        previewUrl: '',
        durationMs: 326000,
      ),
    ];
  }

  List<TrackModel> _getMelancholicTracks() {
    return [
      TrackModel(
        id: 't26',
        name: 'Mad World',
        artist: 'Gary Jules',
        album: 'Trading Snakeoil for Wolftickets',
        imageUrl: 'https://picsum.photos/seed/track26/300',
        externalUrl: 'https://open.spotify.com/track/3JOVTQ5h8HGFnDdp4VT3MP',
        previewUrl: '',
        durationMs: 193000,
      ),
      TrackModel(
        id: 't27',
        name: 'Creep',
        artist: 'Radiohead',
        album: 'Pablo Honey',
        imageUrl: 'https://picsum.photos/seed/track27/300',
        externalUrl: 'https://open.spotify.com/track/6b2oQwSGFkzsMtQruIWm2p',
        previewUrl: '',
        durationMs: 235000,
      ),
    ];
  }

  List<TrackModel> _getAdventurousTracks() {
    return [
      TrackModel(
        id: 't28',
        name: 'Time',
        artist: 'Hans Zimmer',
        album: 'Inception',
        imageUrl: 'https://picsum.photos/seed/track28/300',
        externalUrl: 'https://open.spotify.com/track/6ZFbXIJkuI1dVNWvzJzown',
        previewUrl: '',
        durationMs: 274000,
      ),
      TrackModel(
        id: 't29',
        name: "He's a Pirate",
        artist: 'Klaus Badelt',
        album: 'Pirates of the Caribbean',
        imageUrl: 'https://picsum.photos/seed/track29/300',
        externalUrl: 'https://open.spotify.com/track/16NXmjLlXSNHgVBokxF3gX',
        previewUrl: '',
        durationMs: 145000,
      ),
    ];
  }

  List<TrackModel> _getSpiritualTracks() {
    return [
      TrackModel(
        id: 't30',
        name: 'Deva Premal Om',
        artist: 'Deva Premal',
        album: 'The Essence',
        imageUrl: 'https://picsum.photos/seed/track30/300',
        externalUrl: 'https://open.spotify.com/track/2v4i9lGNJq5NzPqT9R3Jtw',
        previewUrl: '',
        durationMs: 300000,
      ),
      TrackModel(
        id: 't31',
        name: 'Spiegel im Spiegel',
        artist: 'Arvo Pärt',
        album: 'Alina',
        imageUrl: 'https://picsum.photos/seed/track31/300',
        externalUrl: 'https://open.spotify.com/track/38DgqbKV8NSJbfmlfIlXLG',
        previewUrl: '',
        durationMs: 590000,
      ),
    ];
  }

  List<TrackModel> _getConfidentTracks() {
    return [
      TrackModel(
        id: 't32',
        name: 'Confident',
        artist: 'Demi Lovato',
        album: 'Confident',
        imageUrl: 'https://picsum.photos/seed/track32/300',
        externalUrl: 'https://open.spotify.com/track/2ULDnG8UDEwlCHGPK6DYkL',
        previewUrl: '',
        durationMs: 197000,
      ),
      TrackModel(
        id: 't33',
        name: 'Run the World',
        artist: 'Beyoncé',
        album: '4',
        imageUrl: 'https://picsum.photos/seed/track33/300',
        externalUrl: 'https://open.spotify.com/track/5HMEIXxqgXOC7TuZNvIHY8',
        previewUrl: '',
        durationMs: 236000,
      ),
    ];
  }

  /// Get a completely random track without any mood/genre filter
  Future<TrackModel?> getRandomTrack() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        debugPrint('No access token available for random track');
        return _getRandomMockTrack();
      }

      // Pick a random search query
      final randomQuery = SpotifyConfig.randomSearchQueries[
          _random.nextInt(SpotifyConfig.randomSearchQueries.length)];

      // Random offset for more variety (0-1000)
      final randomOffset = _random.nextInt(1000);

      final response = await http.get(
        Uri.parse(
          '${SpotifyConfig.baseUrl}/search?q=$randomQuery&type=track&limit=50&offset=$randomOffset',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;

        if (tracks.isNotEmpty) {
          // Pick a random track from results
          final randomTrack = tracks[_random.nextInt(tracks.length)];
          return TrackModel.fromJson(randomTrack);
        }
      }

      // If API call fails or returns empty, try with no offset
      final fallbackResponse = await http.get(
        Uri.parse(
          '${SpotifyConfig.baseUrl}/search?q=$randomQuery&type=track&limit=50',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (fallbackResponse.statusCode == 200) {
        final data = json.decode(fallbackResponse.body);
        final tracks = data['tracks']['items'] as List;

        if (tracks.isNotEmpty) {
          final randomTrack = tracks[_random.nextInt(tracks.length)];
          return TrackModel.fromJson(randomTrack);
        }
      }

      return _getRandomMockTrack();
    } catch (e) {
      debugPrint('Error getting random track: $e');
      return _getRandomMockTrack();
    }
  }

  /// Get multiple random tracks
  Future<List<TrackModel>> getRandomTracks({int count = 10}) async {
    final List<TrackModel> randomTracks = [];

    for (int i = 0; i < count; i++) {
      final track = await getRandomTrack();
      if (track != null) {
        randomTracks.add(track);
      }
      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return randomTracks;
  }

  /// Get a random mock track for fallback
  TrackModel _getRandomMockTrack() {
    final allMockTracks = [
      ..._getHappyTracks(),
      ..._getSadTracks(),
      ..._getEnergeticTracks(),
      ..._getCalmTracks(),
      ..._getRomanticTracks(),
      ..._getFocusedTracks(),
      ..._getAngryTracks(),
      ..._getNostalgicTracks(),
      ..._getChillTracks(),
      ..._getPartyTracks(),
      ..._getSleepyTracks(),
      ..._getMotivatedTracks(),
      ..._getMelancholicTracks(),
      ..._getAdventurousTracks(),
      ..._getSpiritualTracks(),
      ..._getConfidentTracks(),
    ];

    return allMockTracks[_random.nextInt(allMockTracks.length)];
  }
}
