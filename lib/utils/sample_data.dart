import '../models/member.dart';
import '../models/notice.dart';
import '../models/notification_item.dart';

class SampleData {
  /// Default family members list - only includes Administrator '참치대장'
  static final List<Member> members = [
    const Member(
      id: 'mem_1',
      name: '김참치',
      nickname: '참치대장 👑',
      role: '가족 대표 / 총괄 관리자',
      emoji: '👑',
      colorValue: 0xFF0F4C81,
      isAdmin: true,
      grade: MemberGrade.admin,
    ),
  ];

  /// Initial notices list - starts completely clean/empty as requested
  static List<Notice> getNotices() {
    return [];
  }

  /// Initial notifications list - starts clean
  static List<NotificationItem> getNotifications() {
    return [];
  }
}
