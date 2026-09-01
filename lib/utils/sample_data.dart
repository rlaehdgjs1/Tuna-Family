import '../models/member.dart';
import '../models/notice.dart';
import '../models/notification_item.dart';

class SampleData {
  static final List<Member> members = [
    const Member(
      id: 'mem_1',
      name: '김참치',
      nickname: '참치대장 👑',
      role: '아빠 / 모임 총괄',
      emoji: '👑',
      colorValue: 0xFF0F4C81,
      isAdmin: true,
    ),
    const Member(
      id: 'mem_2',
      name: '이바다',
      nickname: '참치퀸 🌸',
      role: '엄마 / 회계 총괄',
      emoji: '🌸',
      colorValue: 0xFFE11D48,
      isAdmin: true,
    ),
    const Member(
      id: 'mem_3',
      name: '김푸름',
      nickname: '서핑참치 🏄‍♂️',
      role: '첫째 / 일정 매니저',
      emoji: '🏄‍♂️',
      colorValue: 0xFF0284C7,
      isAdmin: false,
    ),
    const Member(
      id: 'mem_4',
      name: '김하늘',
      nickname: '그림참치 🎨',
      role: '둘째 / 디자인&사진',
      emoji: '🎨',
      colorValue: 0xFF9333EA,
      isAdmin: false,
    ),
    const Member(
      id: 'mem_5',
      name: '김바람',
      nickname: '아기참치 🐣',
      role: '막내 / 마스코트',
      emoji: '🐣',
      colorValue: 0xFFF59E0B,
      isAdmin: false,
    ),
    const Member(
      id: 'mem_6',
      name: '김바다삼촌',
      nickname: '삼촌참치 🐟',
      role: '삼촌 / 분위기메이커',
      emoji: '🐟',
      colorValue: 0xFF0D9488,
      isAdmin: false,
    ),
  ];

  /// Initial notices list - starts completely clean/empty as requested by user
  static List<Notice> getNotices() {
    return [];
  }

  /// Initial notifications list - starts clean
  static List<NotificationItem> getNotifications() {
    return [];
  }
}
