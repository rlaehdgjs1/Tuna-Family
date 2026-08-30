import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../utils/app_theme.dart';
import 'music_player_sheet.dart';

class MiniMusicBar extends StatelessWidget {
  const MiniMusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final currentTrack = musicProvider.currentTrack;
    final isPlaying = musicProvider.isPlaying;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
          width: isPlaying ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => MusicPlayerSheet.show(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Icon or Image
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    isPlaying ? '🎵' : currentTrack.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (isPlaying) ...[
                          const Icon(Icons.equalizer_rounded,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            currentTrack.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isPlaying
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPlaying ? '배경음악 재생 중 • 터치하여 변경' : '배경음악 일시정지됨',
                      style: TextStyle(
                        fontSize: 11,
                        color: isPlaying
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight: isPlaying
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // Play / Pause Icon Button
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
                onPressed: () => musicProvider.togglePlayPause(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
