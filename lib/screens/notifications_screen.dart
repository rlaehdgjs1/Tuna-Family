import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/notice_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import 'notice_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final bool isTab;

  const NotificationsScreen({
    super.key,
    this.isTab = false,
  });

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return DateFormat('MM.dd HH:mm').format(dateTime);
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_notice':
        return Icons.campaign_rounded;
      case 'poll':
        return Icons.how_to_vote_rounded;
      case 'comment':
        return Icons.chat_bubble_rounded;
      case 'reaction':
        return Icons.favorite_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_notice':
        return AppColors.primary;
      case 'poll':
        return AppColors.accent;
      case 'comment':
        return AppColors.secondary;
      case 'reaction':
        return const Color(0xFFE11D48);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 센터'),
        automaticallyImplyLeading: !isTab,
        actions: [
          // Push Notification Test Button
          IconButton(
            icon: const Icon(Icons.notification_add_outlined),
            tooltip: '푸시 알림 테스트',
            onPressed: () async {
              await NotificationService().showCustomPush(
                title: '🐟 참치패밀리 실시간 푸시 알림',
                body: '새로운 공지나 가족 소식이 등록되면 스마트폰 상단 알림바로 즉시 알려드립니다!',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('스마트폰 알림바에 푸시 알림이 발송되었습니다 🔔'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () => provider.markAllNotificationsAsRead(),
              child: const Text('모두 읽음'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: '알림 전체 삭제',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('알림 전체 삭제'),
                    content: const Text('모든 알림 내역을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          provider.clearAllNotifications();
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_off_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '새로운 알림이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '새로운 공지가 등록되면 스마트폰 푸시 알림과 함께 여기에 표시됩니다!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await NotificationService().showCustomPush(
                          title: '📢 [중요필독] 참치패밀리 푸시 알림 테스트',
                          body: '새 공지가 등록되면 스마트폰 상단 알림바로 즉시 알려드립니다!',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('스마트폰 알림바에 푸시 알림이 발송되었습니다 🔔'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('푸시 알림 테스트 발송'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final iconColor = _getNotificationColor(notif.type);

                return InkWell(
                  onTap: () {
                    provider.markNotificationAsRead(notif.id);
                    if (notif.noticeId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NoticeDetailScreen(noticeId: notif.noticeId!),
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: notif.isRead
                        ? Colors.transparent
                        : AppColors.primaryLight.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getNotificationIcon(notif.type),
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: notif.isRead
                                            ? FontWeight.w600
                                            : FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatNotificationTime(notif.timestamp),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: notif.isRead
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
