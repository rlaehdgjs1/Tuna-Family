import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poll.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';
import 'member_avatar.dart';

class PollWidget extends StatelessWidget {
  final String noticeId;
  final Poll poll;

  const PollWidget({
    super.key,
    required this.noticeId,
    required this.poll,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final currentMemberId = provider.currentMember.id;
    final members = provider.members;
    final totalVotes = poll.totalVotes;
    final hasVoted = poll.hasVoted(currentMemberId);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasVoted ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.how_to_vote_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poll.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총 $totalVotes표 참여 • ${poll.isMultipleChoice ? '복수 선택 가능' : '단일 선택'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Options List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: poll.options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final option = poll.options[index];
              final isSelected = option.voterMemberIds.contains(currentMemberId);
              final percentage =
                  totalVotes > 0 ? (option.voteCount / totalVotes) : 0.0;
              final percentInt = (percentage * 100).toInt();

              // Voters for this option
              final optionVoters = members
                  .where((m) => option.voterMemberIds.contains(m.id))
                  .toList();

              return InkWell(
                onTap: () {
                  provider.votePoll(noticeId, option.id);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Progress Bar fill
                      if (totalVotes > 0)
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 60,
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.accent.withValues(alpha: 0.12),
                          ),
                        ),

                      // Option Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$percentInt% (${option.voteCount}표)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            // Voter avatars
                            if (optionVoters.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: optionVoters.map((voter) {
                                    return Tooltip(
                                      message: voter.nickname,
                                      child: MemberAvatar(
                                        member: voter,
                                        size: 22,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              hasVoted ? '💡 선택지를 다시 누르면 투표를 변경할 수 있습니다.' : '💡 원하는 항목을 터치하여 투표해 주세요.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
