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

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final currentTrack = musicProvider.currentTrack;
    final isPlaying = musicProvider.isPlaying;
    final allTracks = musicProvider.allTracks;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Tuna Icon / Music artwork
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/tuna_icon.png',
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 54,
                            height: 54,
                            color: Colors.white24,
                            child: const Center(
                              child: Text('🐟', style: TextStyle(fontSize: 28)),
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
                      // Play / Pause Button
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

            // Pick Local Music File Button (User Request!)
            InkWell(
              onTap: () async {
                final success = await musicProvider.pickCustomMusicFile();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '🎵 "${musicProvider.currentTrack.title}" 음악이 재생됩니다!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        color: AppColors.secondary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      '📁 내 기기 음악 파일 선택하기 (MP3 / WAV)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
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
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Track List Header
            const Text(
              '참치패밀리 추천 BGM 목록',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Track List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allTracks.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final track = allTracks[index];
                  final isCurrent = track.id == currentTrack.id;

                  return InkWell(
                    onTap: () => musicProvider.playTrack(track),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryLight.withValues(alpha: 0.4)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.background,
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
                                Text(
                                  track.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isCurrent
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
