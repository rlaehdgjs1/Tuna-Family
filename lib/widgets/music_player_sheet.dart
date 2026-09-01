import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../utils/app_theme.dart';

class MusicPlayerSheet extends StatelessWidget {
  const MusicPlayerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const MusicPlayerSheet(),
    );
  }

  void _showAddYouTubeDialog(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();
    final urlController = TextEditingController();
    final titleController = TextEditingController();
    final artistController = TextEditingController();

    String? currentVideoId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.play_circle_filled_rounded,
                            color: Color(0xFFFF0000), size: 28),
                        SizedBox(width: 8),
                        Text(
                          '유튜브 배경음악 등록 🎬',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '좋아하는 YouTube 영상이나 음악 링크를 등록하여 BGM으로 재생하세요.',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                    // YouTube URL Input
                    const Text(
                      '유튜브 링크 (URL) *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'https://youtu.be/... 또는 https://youtube.com/...',
                        prefixIcon: const Icon(Icons.link_rounded,
                            color: Color(0xFFFF0000)),
                        suffixIcon: currentVideoId != null
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.success)
                            : null,
                      ),
                      onChanged: (val) {
                        final extracted = MusicTrack.extractYouTubeId(val);
                        setDialogState(() {
                          currentVideoId = extracted;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Live Thumbnail Preview if valid YouTube link
                    if (currentVideoId != null) ...[
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black,
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://img.youtube.com/vi/$currentVideoId/hqdefault.jpg'),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                              color: const Color(0xFFFF0000), width: 1.5),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Song Title Input (Optional)
                    const Text(
                      '음악 제목 (선택)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: '예: 신나는 참치 여행 BGM, 힐링 피아노',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Artist/Channel Input (Optional)
                    const Text(
                      '아티스트 / 유튜브 채널명 (선택)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: artistController,
                      decoration: const InputDecoration(
                        hintText: '예: YouTube 채널명 또는 가수',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final url = urlController.text.trim();
                          final title = titleController.text.trim();
                          final artist = artistController.text.trim();

                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('유튜브 링크를 입력해 주세요.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final err = await musicProvider.addYouTubeTrack(
                            url: url,
                            title: title.isNotEmpty ? title : null,
                            artist: artist.isNotEmpty ? artist : null,
                          );

                          if (err != null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(err),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🎬 유튜브 배경음악이 등록되고 재생됩니다!'),
                                  backgroundColor: Color(0xFF1E293B),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 24),
                            SizedBox(width: 6),
                            Text(
                              '유튜브 음악 등록 및 재생 🎬',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final currentTrack = musicProvider.currentTrack;
    final isPlaying = musicProvider.isPlaying;
    final customTracks = musicProvider.customTracks;
    final presetTracks = MusicProvider.presetTracks;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '참치패밀리 배경음악 플레이어 🎵',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '가족 소통방의 분위기를 더해주는 BGM',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Currently Playing Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentTrack.isYouTube
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: currentTrack.isYouTube
                          ? const Color(0xFFFF0000).withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Artwork / YouTube Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: currentTrack.youtubeThumbnailUrl != null
                              ? Image.network(
                                  currentTrack.youtubeThumbnailUrl!,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 58,
                                    height: 58,
                                    color: const Color(0xFFFF0000),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_filled_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/tuna_icon.png',
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                    width: 54,
                                    height: 54,
                                    color: Colors.white24,
                                    child: const Center(
                                      child: Text('🐟',
                                          style: TextStyle(fontSize: 28)),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (currentTrack.isYouTube)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF0000),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'YouTube',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    currentTrack.icon,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      currentTrack.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentTrack.artist,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play / Pause / YouTube Launcher Button
                        IconButton(
                          iconSize: 42,
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => musicProvider.togglePlayPause(),
                        ),
                      ],
                    ),

                    // If YouTube track, show direct YouTube Open button
                    if (currentTrack.isYouTube) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              musicProvider.launchYouTube(currentTrack),
                          icon: const Icon(Icons.open_in_new_rounded,
                              size: 16, color: Colors.white),
                          label: const Text(
                            '유튜브 앱 / 브라우저에서 바로 열기 🎬',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Volume Slider
                    Row(
                      children: [
                        Icon(
                          musicProvider.volume == 0
                              ? Icons.volume_off_rounded
                              : Icons.volume_down_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        Expanded(
                          child: Slider(
                            value: musicProvider.volume,
                            min: 0.0,
                            max: 1.0,
                            activeColor: AppColors.secondary,
                            inactiveColor: Colors.white24,
                            onChanged: (val) => musicProvider.setVolume(val),
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded,
                            color: Colors.white70, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Two Buttons: 1. YouTube Link Add, 2. Local File Add
              Row(
                children: [
                  // YouTube Button
                  Expanded(
                    child: InkWell(
                      onTap: () => _showAddYouTubeDialog(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0000).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                const Color(0xFFFF0000).withValues(alpha: 0.4),
                            width: 1.3,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled_rounded,
                                color: Color(0xFFFF0000), size: 20),
                            SizedBox(width: 6),
                            Text(
                              '유튜브 링크 추가',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF0000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // MP3 File Button
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final success =
                            await musicProvider.pickCustomMusicFile();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '🎵 "${musicProvider.currentTrack.title}" 음악이 저장되고 재생됩니다!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            width: 1.3,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded,
                                color: AppColors.secondary, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'MP3 파일 추가',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Auto Play Toggle
              SwitchListTile(
                value: musicProvider.isAutoPlayEnabled,
                onChanged: (val) => musicProvider.toggleAutoPlay(val),
                title: const Text(
                  '앱 실행 시 배경음악 자동 재생',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  '어플을 열었을 때 자동으로 음악이 흘러나옵니다.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),

              // App Start Music Mode Selector (내가 선택한 곡 유지 / 랜덤 재생)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          '앱 실행 시 재생 방식 설정',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: MusicStartMode.values.map((mode) {
                        final isSelected = musicProvider.startMode == mode;
                        return InkWell(
                          onTap: () => musicProvider.setStartMode(mode),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mode.label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        mode.description,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- My Custom & YouTube Music List (If any) ---
              if (customTracks.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.folder_shared_rounded,
                        size: 18, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      '내가 등록한 음악 & 유튜브 (${customTracks.length}곡)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customTracks.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final track = customTracks[index];
                    final isCurrent = track.id == currentTrack.id;

                    return _buildTrackTile(
                      context: context,
                      musicProvider: musicProvider,
                      track: track,
                      isCurrent: isCurrent,
                      isPlaying: isPlaying,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('음악 삭제'),
                            content: Text(
                                '\'${track.title}\' 음악을 보관함에서 삭제하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('취소'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await musicProvider.deleteCustomTrack(track.id);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // --- Preset Recommended Tracks ---
              const Row(
                children: [
                  Icon(Icons.queue_music_rounded,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    '참치패밀리 추천 테마 BGM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: presetTracks.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final track = presetTracks[index];
                  final isCurrent = track.id == currentTrack.id;

                  return _buildTrackTile(
                    context: context,
                    musicProvider: musicProvider,
                    track: track,
                    isCurrent: isCurrent,
                    isPlaying: isPlaying,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackTile({
    required BuildContext context,
    required MusicProvider musicProvider,
    required MusicTrack track,
    required bool isCurrent,
    required bool isPlaying,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: () {
        if (track.isYouTube) {
          musicProvider.playTrack(track, autoLaunchYouTube: true);
        } else {
          musicProvider.playTrack(track);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primaryLight.withValues(alpha: 0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon or YouTube Thumbnail
            if (track.youtubeThumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  track.youtubeThumbnailUrl!,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    width: 42,
                    height: 42,
                    color: const Color(0xFFFF0000),
                    child: const Center(
                      child: Text('🎬', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    track.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (track.isYouTube)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'YouTube',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          track.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent && isPlaying)
              const Icon(
                Icons.equalizer_rounded,
                color: AppColors.primary,
                size: 22,
              )
            else if (isCurrent)
              const Icon(
                Icons.pause_rounded,
                color: AppColors.primary,
                size: 20,
              )
            else
              const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
