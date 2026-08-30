import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String icon;
  final String? url;
  final Uint8List? customBytes;
  final String? customPath;
  final bool isCustom;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.icon,
    this.url,
    this.customBytes,
    this.customPath,
    this.isCustom = false,
  });
}

class MusicProvider with ChangeNotifier {
  static const String _autoPlayKey = 'tuna_family_music_autoplay';
  static const String _volumeKey = 'tuna_family_music_volume';
  static const String _selectedTrackKey = 'tuna_family_music_selected_track';

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isAutoPlayEnabled = true;
  double _volume = 0.6;
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
      url: 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
    ),
    const MusicTrack(
      id: 'track_joyful',
      title: '활기찬 참치패밀리 (Joyful Tuna)',
      artist: '참치패밀리 오리지널',
      icon: '🐟',
      url: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3?filename=happy-acoustic-guitar-background-music-122614.mp3',
    ),
    const MusicTrack(
      id: 'track_cozy',
      title: '따뜻한 가족 카페 (Cozy Living Room)',
      artist: '어쿠스틱 패밀리',
      icon: '☕',
      url: 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3?filename=acoustic-guitar-loop-f-91bpm-14578.mp3',
    ),
    const MusicTrack(
      id: 'track_jeju',
      title: '제주도 가족 여행 (Jeju Island Trip)',
      artist: '우쿨렐레 바캉스',
      icon: '🏖️',
      url: 'https://cdn.pixabay.com/download/audio/2022/11/06/audio_05ad59cb12.mp3?filename=ukulele-trip-125633.mp3',
    ),
  ];

  late MusicTrack _currentTrack;
  MusicTrack? _customTrack;

  MusicProvider() {
    _currentTrack = presetTracks[0];
    _initAudio();
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isAutoPlayEnabled => _isAutoPlayEnabled;
  double get volume => _volume;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  MusicTrack get currentTrack => _currentTrack;
  MusicTrack? get customTrack => _customTrack;
  String? get errorMessage => _errorMessage;

  List<MusicTrack> get allTracks {
    if (_customTrack != null) {
      return [...presetTracks, _customTrack!];
    }
    return presetTracks;
  }

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

    // Load Settings
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAutoPlayEnabled = prefs.getBool(_autoPlayKey) ?? true;
      _volume = prefs.getDouble(_volumeKey) ?? 0.6;
      await _audioPlayer.setVolume(_volume);

      final savedTrackId = prefs.getString(_selectedTrackKey);
      if (savedTrackId != null) {
        final found =
            presetTracks.where((t) => t.id == savedTrackId).firstOrNull;
        if (found != null) {
          _currentTrack = found;
        }
      }

      // If autoplay is enabled, try playing on launch without blocking
      if (_isAutoPlayEnabled) {
        playTrack(_currentTrack);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Music initialization error: $e');
      }
    }
  }

  Future<void> playTrack(MusicTrack track) async {
    _currentTrack = track;
    _errorMessage = null;

    try {
      await _audioPlayer.stop();

      if (track.isCustom) {
        if (track.customBytes != null) {
          await _audioPlayer.play(BytesSource(track.customBytes!));
        } else if (track.customPath != null) {
          await _audioPlayer.play(DeviceFileSource(track.customPath!));
        }
      } else if (track.url != null) {
        await _audioPlayer.play(UrlSource(track.url!));
      }

      _isPlaying = true;

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

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await playTrack(_currentTrack);
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

  // Pick Custom Music File from user's device
  Future<bool> pickCustomMusicFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final trackName = file.name;
        final bytes = await file.readAsBytes();

        _customTrack = MusicTrack(
          id: 'track_custom_${DateTime.now().millisecondsSinceEpoch}',
          title: trackName,
          artist: '내 기기 맞춤 음악 🎵',
          icon: '🎧',
          customBytes: bytes,
          customPath: file.path,
          isCustom: true,
        );

        // Auto-play the custom selected track
        await playTrack(_customTrack!);
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
