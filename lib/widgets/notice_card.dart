import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/notice.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';
import '../screens/notice_detail_screen.dart';
import '../screens/notice_form_screen.dart';
import 'delete_notice_dialog.dart';
import 'media_view_helper.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;

  const NoticeCard({
    super.key,
    required this.notice,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final currentMember = provider.currentMember;
    final totalMemberCount = provider.members.length;
    final isReadByMe = notice.isReadBy(currentMember.id);
    final ackCount = notice.readMemberIds.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: notice.isPinned
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: notice.isPinned ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoticeDetailScreen(noticeId: notice.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top meta row
              Row(
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: notice.category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          notice.category.icon,
                          color: notice.category.color,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notice.category.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: notice.category.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (notice.isPinned) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin_rounded,
                            color: AppColors.secondary,
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '고정',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),

                  // Read / Ack status pill for current user
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isReadByMe
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isReadByMe
                              ? Icons.check_circle_rounded
                              : Icons.mark_email_unread_rounded,
                          size: 12,
                          color: isReadByMe
                              ? AppColors.success
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isReadByMe ? '확인완료' : '미확인',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isReadByMe
                                ? AppColors.success
                                : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Quick Options Menu (Pin / Edit / Delete)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: '공지 메뉴',
                    onSelected: (value) {
                      if (value == 'pin') {
                        provider.togglePin(notice.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(notice.isPinned
                                ? '상단 고정이 해제되었습니다.'
                                : '공지가 상단에 고정되었습니다 📌'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                NoticeFormScreen(noticeToEdit: notice),
                          ),
                        );
                      } else if (value == 'delete') {
                        DeleteNoticeDialog.show(context, notice: notice);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              notice.isPinned
                                  ? Icons.push_pin_outlined
                                  : Icons.push_pin_rounded,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(notice.isPinned ? '상단 고정 해제' : '상단 고정'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('공지 수정'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(
                              '공지 삭제',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content snippet
              Text(
                notice.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Attached Photos Preview
              if (notice.imageUrls.isNotEmpty)
                MediaViewHelper.buildCardPhotos(context, notice.imageUrls),

              // Video Link Preview
              if (notice.videoUrl != null && notice.videoUrl!.isNotEmpty)
                MediaViewHelper.buildVideoCard(context, notice.videoUrl!,
                    isCard: true),

              // Poll or Tags indicator
              if (notice.poll != null || notice.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (notice.poll != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.poll_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '투표 진행 중 (${notice.poll!.totalVotes}명 참여)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...notice.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                  ],
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),

              // Bottom row: Author, Date, Ack count, Comments
              Row(
                children: [
                  Text(
                    notice.authorEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notice.authorName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('•',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(notice.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),

                  // Acknowledged ratio
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 14,
                        color: ackCount == totalMemberCount
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$ackCount/$totalMemberCount명 확인',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ackCount == totalMemberCount
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Comment count
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${notice.comments.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
