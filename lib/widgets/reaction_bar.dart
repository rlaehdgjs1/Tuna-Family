import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notice.dart';
import '../models/reaction.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';
import 'member_avatar.dart';

class ReactionBar extends StatelessWidget {
  final Notice notice;

  const ReactionBar({
    super.key,
    required this.notice,
  });

  static const List<String> availableEmojis = ['🐟', '❤️', '👍', '🎉', '👏', '🎂'];

  void _showReactionDetail(BuildContext context, Reaction reaction) {
    final provider = context.read<NoticeProvider>();
    final members = provider.members;
    final reactedMembers =
        members.where((m) => reaction.memberIds.contains(m.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${reaction.emoji} 반응을 남긴 가족 (${reactedMembers.length}명)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: reactedMembers.map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MemberAvatar(member: m, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            m.nickname,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final currentMemberId = provider.currentMember.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing Reactions list
        if (notice.reactions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: notice.reactions.map((reaction) {
              final hasReacted = reaction.memberIds.contains(currentMemberId);
              return InkWell(
                onTap: () => provider.addReaction(notice.id, reaction.emoji),
                onLongPress: () => _showReactionDetail(context, reaction),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasReacted
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasReacted
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reaction.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${reaction.count}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: hasReacted ? FontWeight.bold : FontWeight.w600,
                          color: hasReacted
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Emoji Quick Picker Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: availableEmojis.map((emoji) {
              final existingReaction = notice.reactions.firstWhere(
                (r) => r.emoji == emoji,
                orElse: () => Reaction(emoji: emoji, memberIds: []),
              );
              final hasReacted =
                  existingReaction.memberIds.contains(currentMemberId);

              return InkWell(
                onTap: () => provider.addReaction(notice.id, emoji),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: AnimatedScale(
                    scale: hasReacted ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 22,
                        shadows: hasReacted
                            ? [
                                const BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
