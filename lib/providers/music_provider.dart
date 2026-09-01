import 'dart:convert';
import 'dart:math';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum MusicStartMode {
  lastSelected('내가 선택한 음악 유지', '다음 앱 실행 시 마지막으로 선택한 음악이 그대로 재생됩니다.'),
  random('실행할 때마다 랜덤 재생', '앱을 열 때마다 등록된 음악 중 새로운 곡이 자동으로 재생됩니다.'),
  cycle('순차 재생', '앱 실행 시 다음 곡으로 넘어가며 재생됩니다.');

  final String label;
  final String description;
  const MusicStartMode(this.label, this.description);
}

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String icon;
  final String? url;
  final Uint8List? customBytes;
  final String? customPath;
  final bool isCustom;
  final bool isYouTube;
  final String? youtubeVideoId;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.icon,
    this.url,
    this.customBytes,
    this.customPath,
    this.isCustom = false,
    this.isYouTube = false,
    this.youtubeVideoId,
  });

  /// Extract YouTube Video ID from any standard YouTube link format
  static String? extractYouTubeId(String url) {
    final clean = url.trim();
    if (clean.isEmpty) return null;

    // Pattern 1: youtu.be/<id>
    final shortRegExp = RegExp(r'youtu\.be\/([a-zA-Z0-9_-]{11})');
    final shortMatch = shortRegExp.firstMatch(clean);
    if (shortMatch != null) return shortMatch.group(1);

    // Pattern 2: youtube.com/watch?v=<id> or music.youtube.com/watch?v=<id>
    final watchRegExp = RegExp(r'youtube\.com\/watch\?.*v=([a-zA-Z0-9_-]{11})');
    final watchMatch = watchRegExp.firstMatch(clean);
    if (watchMatch != null) return watchMatch.group(1);

    // Pattern 3: youtube.com/shorts/<id>
    final shortsRegExp = RegExp(r'youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})');
    final shortsMatch = shortsRegExp.firstMatch(clean);
    if (shortsMatch != null) return shortsMatch.group(1);

    // Pattern 4: youtube.com/embed/<id>
    final embedRegExp = RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})');
    final embedMatch = embedRegExp.firstMatch(clean);
    if (embedMatch != null) return embedMatch.group(1);

    // Direct 11-char Video ID
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(clean)) {
      return clean;
    }

    return null;
  }

  String? get youtubeThumbnailUrl => youtubeVideoId != null
      ? 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg'
      : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'icon': icon,
        'url': url,
        'customPath': customPath,
        'isCustom': isCustom,
        'isYouTube': isYouTube,
        'youtubeVideoId': youtubeVideoId,
        if (customBytes != null && customBytes!.length < 5 * 1024 * 1024)
          'customBytes': base64Encode(customBytes!),
      };

  factory MusicTrack.fromJson(Map<String, dynamic> json) => MusicTrack(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String? ?? '내 맞춤 음악',
        icon: json['icon'] as String? ?? (json['isYouTube'] == true ? '🎬' : '🎧'),
        url: json['url'] as String?,
        customPath: json['customPath'] as String?,
        customBytes: json['customBytes'] != null
            ? base64Decode(json['customBytes'] as String)
            : null,
        isCustom: json['isCustom'] as bool? ?? false,
        isYouTube: json['isYouTube'] as bool? ?? false,
        youtubeVideoId: json['youtubeVideoId'] as String?,
      );
}

class MusicProvider with ChangeNotifier {
  static const String _autoPlayKey = 'tuna_family_music_autoplay';
  static const String _volumeKey = 'tuna_family_music_volume';
  static const String _selectedTrackKey = 'tuna_family_music_selected_track';
  static const String _customTracksKey = 'tuna_family_custom_tracks_v3';
  static const String _startModeKey = 'tuna_family_music_start_mode';

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isAutoPlayEnabled = true;
  double _volume = 0.6;
  MusicStartMode _startMode = MusicStartMode.lastSelected;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;

  // Preset Tuna Family Tracks (Royalty-free relaxing/cheerful background streams)
  static final List<MusicTrack> presetTracks = [
    const MusicTrack(
      id: 'track_sea',
      title: '바다의 멜로디 (Sea Breeze)',
      artist: '참치패밀리 힐링 사운드',
      icon: '🌊',
      url:
          'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
    ),
    const MusicTrack(
      id: 'track_cozy',
      title: '따뜻한 가족 카페 (Cozy Living Room)',
      artist: '어쿠스틱 패밀리',
      icon: '☕',
      url:
          'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3?filename=acoustic-guitar-loop-f-91bpm-14578.mp3',
    ),
  ];

  late MusicTrack _currentTrack;
  List<MusicTrack> _customTracks = [];

  MusicProvider() {
    _currentTrack = presetTracks[0];
    _initAudio();
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isAutoPlayEnabled => _isAutoPlayEnabled;
  double get volume => _volume;
  MusicStartMode get startMode => _startMode;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  MusicTrack get currentTrack => _currentTrack;
  List<MusicTrack> get customTracks => _customTracks;
  String? get errorMessage => _errorMessage;

  List<MusicTrack> get allTracks => [...presetTracks, ..._customTracks];

  Future<void> _initAudio() async {
    // Audio Player Listeners
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((d) {
      _totalDuration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _currentPosition = p;
      notifyListeners();
    });

    // Load Settings & Saved Custom Tracks
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAutoPlayEnabled = prefs.getBool(_autoPlayKey) ?? true;
      _volume = prefs.getDouble(_volumeKey) ?? 0.6;
      await _audioPlayer.setVolume(_volume);

      final modeIndex = prefs.getInt(_startModeKey) ?? 0;
      if (modeIndex >= 0 && modeIndex < MusicStartMode.values.length) {
        _startMode = MusicStartMode.values[modeIndex];
      }

      // Load Saved Custom Tracks
      final customJson = prefs.getString(_customTracksKey);
      if (customJson != null) {
        final List<dynamic> decoded = jsonDecode(customJson);
        final loadedTracks = <MusicTrack>[];
        for (final item in decoded) {
          try {
            final track = MusicTrack.fromJson(item as Map<String, dynamic>);
            // If on non-web and file path exists, ensure file is still accessible
            if (!kIsWeb && track.customPath != null) {
              if (File(track.customPath!).existsSync()) {
                loadedTracks.add(track);
              }
            } else {
              loadedTracks.add(track);
            }
          } catch (_) {}
        }
        _customTracks = loadedTracks;
      }

      // Determine Which Track to Play upon Start
      final tracks = allTracks;
      final savedTrackId = prefs.getString(_selectedTrackKey);

      if (_startMode == MusicStartMode.random && tracks.length > 1) {
        final randomIndex = Random().nextInt(tracks.length);
        _currentTrack = tracks[randomIndex];
      } else if (_startMode == MusicStartMode.cycle && tracks.length > 1) {
        final currentIndex = tracks.indexWhere((t) => t.id == savedTrackId);
        final nextIndex = (currentIndex + 1) % tracks.length;
        _currentTrack = tracks[nextIndex];
      } else {
        // Default: MusicStartMode.lastSelected -> Restore the user's chosen track
        if (savedTrackId != null) {
          final found = tracks.where((t) => t.id == savedTrackId).firstOrNull;
          if (found != null) {
            _currentTrack = found;
          }
        }
      }

      // If autoplay is enabled and not a raw youtube link, start playing audio
      if (_isAutoPlayEnabled && !_currentTrack.isYouTube) {
        playTrack(_currentTrack);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Music initialization error: $e');
      }
    }
  }

  Future<void> _saveCustomTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_customTracks.map((t) => t.toJson()).toList());
      await prefs.setString(_customTracksKey, encoded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving custom tracks: $e');
      }
    }
  }

  Future<void> playTrack(MusicTrack track, {bool autoLaunchYouTube = false}) async {
    _currentTrack = track;
    _errorMessage = null;

    try {
      await _audioPlayer.stop();

      if (track.isYouTube) {
        _isPlaying = true;
        if (autoLaunchYouTube) {
          await launchYouTube(track);
        }
      } else if (track.isCustom) {
        if (!kIsWeb &&
            track.customPath != null &&
            File(track.customPath!).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(track.customPath!));
        } else if (track.customBytes != null) {
          await _audioPlayer.play(BytesSource(track.customBytes!));
        } else if (track.url != null) {
          await _audioPlayer.play(UrlSource(track.url!));
        }
        _isPlaying = true;
      } else if (track.url != null) {
        await _audioPlayer.play(UrlSource(track.url!));
        _isPlaying = true;
      }

      // Always remember the selected track so next launch plays this track!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedTrackKey, track.id);
    } catch (e) {
      _errorMessage = '음악을 재생할 수 없습니다: $e';
      _isPlaying = false;
      if (kDebugMode) {
        print('Audio play error: $e');
      }
    }
    notifyListeners();
  }

  /// Launch YouTube app or browser for the given track
  Future<void> launchYouTube(MusicTrack track) async {
    final ytUrl = track.url ??
        (track.youtubeVideoId != null
            ? 'https://www.youtube.com/watch?v=${track.youtubeVideoId}'
            : null);
    if (ytUrl != null) {
      final uri = Uri.parse(ytUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    }
  }

  /// Add YouTube Music/Video Track by URL
  Future<String?> addYouTubeTrack({
    required String url,
    String? title,
    String? artist,
  }) async {
    final videoId = MusicTrack.extractYouTubeId(url);
    if (videoId == null) {
      return '올바른 유튜브 링크를 입력해 주세요.\n(예: https://youtu.be/... 또는 https://www.youtube.com/watch?v=...)';
    }

    final trackTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'YouTube BGM 음악 🎬';
    final trackArtist = (artist != null && artist.trim().isNotEmpty)
        ? artist.trim()
        : 'YouTube 링크 재생';

    final newTrack = MusicTrack(
      id: 'track_yt_${DateTime.now().millisecondsSinceEpoch}',
      title: trackTitle,
      artist: trackArtist,
      icon: '🎬',
      url: url.trim(),
      isCustom: true,
      isYouTube: true,
      youtubeVideoId: videoId,
    );

    // Add to saved custom tracks list
    _customTracks.insert(0, newTrack);
    await _saveCustomTracks();

    // Set as active and play
    await playTrack(newTrack, autoLaunchYouTube: true);
    notifyListeners();

    return null; // Success
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      if (_currentTrack.isYouTube) {
        _isPlaying = false;
      } else {
        await _audioPlayer.pause();
        _isPlaying = false;
      }
    } else {
      if (_currentTrack.isYouTube) {
        _isPlaying = true;
        await launchYouTube(_currentTrack);
      } else {
        await playTrack(_currentTrack);
      }
    }
    notifyListeners();
  }

  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
    notifyListeners();
  }

  Future<void> toggleAutoPlay(bool enable) async {
    _isAutoPlayEnabled = enable;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, enable);
    notifyListeners();
  }

  Future<void> setStartMode(MusicStartMode mode) async {
    _startMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startModeKey, mode.index);
    notifyListeners();
  }

  // Pick Custom Music File from user's device & save to storage
  Future<bool> pickCustomMusicFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final trackName = file.name;
        Uint8List? bytes;

        try {
          bytes = await file.readAsBytes();
        } catch (_) {}

        final newTrack = MusicTrack(
          id: 'track_custom_${DateTime.now().millisecondsSinceEpoch}',
          title: trackName,
          artist: '내 맞춤 음악 🎵',
          icon: '🎧',
          customBytes: bytes,
          customPath: file.path,
          isCustom: true,
        );

        // Add to saved custom tracks list
        _customTracks.insert(0, newTrack);
        await _saveCustomTracks();

        // Immediately play and save as active track
        await playTrack(newTrack);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = '파일을 불러오는데 실패했습니다: $e';
      if (kDebugMode) {
        print('File picker error: $e');
      }
      notifyListeners();
    }
    return false;
  }

  // Delete a saved custom music track
  Future<void> deleteCustomTrack(String trackId) async {
    _customTracks.removeWhere((t) => t.id == trackId);
    await _saveCustomTracks();

    if (_currentTrack.id == trackId) {
      // If deleted track was active, switch to first preset track
      await playTrack(presetTracks[0]);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
