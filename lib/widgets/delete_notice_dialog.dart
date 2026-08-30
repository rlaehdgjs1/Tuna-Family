import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notice.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';

class DeleteNoticeDialog extends StatelessWidget {
  final Notice notice;
  final VoidCallback? onDeleted;

  const DeleteNoticeDialog({
    super.key,
    required this.notice,
    this.onDeleted,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Notice notice,
    VoidCallback? onDeleted,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteNoticeDialog(
        notice: notice,
        onDeleted: onDeleted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '공지 삭제',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\'${notice.title}\'',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const Text(
            '이 공지사항을 정말 삭제하시겠습니까?\n삭제된 공지와 댓글, 투표 데이터는 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            '취소',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            final provider = context.read<NoticeProvider>();
            await provider.deleteNotice(notice.id);
            if (context.mounted) {
              Navigator.pop(context, true);
              onDeleted?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('\'${notice.title}\' 공지가 삭제되었습니다 🗑️'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          icon: const Icon(Icons.delete_rounded, size: 18),
          label: const Text(
            '삭제하기',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
