import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/notice.dart';
import '../models/poll.dart';
import '../models/comment.dart';
import '../models/reaction.dart';
import '../models/notification_item.dart';
import '../utils/sample_data.dart';

class NoticeProvider with ChangeNotifier {
  static const String _noticesKey = 'tuna_family_notices_v1';
  static const String _membersKey = 'tuna_family_members_v1';
  static const String _currentMemberKey = 'tuna_family_current_member_v1';
  static const String _notificationsKey = 'tuna_family_notifications_v1';

  List<Notice> _notices = [];
  List<Member> _members = [];
  late Member _currentMember;
  List<NotificationItem> _notifications = [];

  NoticeCategory _selectedCategory = NoticeCategory.all;
  String _searchQuery = '';
  bool _isLoading = true;

  NoticeProvider() {
    _initData();
  }

  // Getters
  bool get isLoading => _isLoading;
  List<Member> get members => _members;
  Member get currentMember => _currentMember;
  NoticeCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<NotificationItem> get notifications => _notifications;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  int get unreadNoticeCount =>
      _notices.where((n) => !n.isReadBy(_currentMember.id)).length;

  List<Notice> get pinnedNotices =>
      _notices.where((n) => n.isPinned).toList();

  List<Notice> get filteredNotices {
    return _notices.where((notice) {
      // Category filter
      if (_selectedCategory != NoticeCategory.all &&
          notice.category != _selectedCategory) {
        return false;
      }
      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchTitle = notice.title.toLowerCase().contains(query);
        final matchContent = notice.content.toLowerCase().contains(query);
        final matchAuthor = notice.authorName.toLowerCase().contains(query);
        final matchTags =
            notice.tags.any((tag) => tag.toLowerCase().contains(query));
        if (!matchTitle && !matchContent && !matchAuthor && !matchTags) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) {
        // Pinned first, then date descending
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Members
      final membersJson = prefs.getString(_membersKey);
      if (membersJson != null) {
        final List<dynamic> decoded = jsonDecode(membersJson);
        _members = decoded.map((e) => Member.fromJson(e)).toList();
      } else {
        _members = List.from(SampleData.members);
      }

      // 2. Current Member
      final currentMemberId = prefs.getString(_currentMemberKey);
      if (currentMemberId != null &&
          _members.any((m) => m.id == currentMemberId)) {
        _currentMember = _members.firstWhere((m) => m.id == currentMemberId);
      } else {
        _currentMember = _members.first;
      }

      // 3. Notices
      final noticesJson = prefs.getString(_noticesKey);
      if (noticesJson != null) {
        final List<dynamic> decoded = jsonDecode(noticesJson);
        _notices = decoded.map((e) => Notice.fromJson(e)).toList();
      } else {
        _notices = SampleData.getNotices();
      }

      // 4. Notifications
      final notifsJson = prefs.getString(_notificationsKey);
      if (notifsJson != null) {
        final List<dynamic> decoded = jsonDecode(notifsJson);
        _notifications =
            decoded.map((e) => NotificationItem.fromJson(e)).toList();
      } else {
        _notifications = SampleData.getNotifications();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Tuna Family data: $e');
      }
      _members = List.from(SampleData.members);
      _currentMember = _members.first;
      _notices = SampleData.getNotices();
      _notifications = SampleData.getNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_membersKey,
          jsonEncode(_members.map((m) => m.toJson()).toList()));
      await prefs.setString(_currentMemberKey, _currentMember.id);
      await prefs.setString(_noticesKey,
          jsonEncode(_notices.map((n) => n.toJson()).toList()));
      await prefs.setString(_notificationsKey,
          jsonEncode(_notifications.map((n) => n.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving Tuna Family data: $e');
      }
    }
  }

  // Active user / Member management
  void setCurrentMember(Member member) {
    _currentMember = member;
    _saveData();
    notifyListeners();
  }

  Future<void> addMember(Member member) async {
    _members.add(member);
    await _saveData();
    notifyListeners();
  }

  Future<bool> deleteMember(String memberId) async {
    if (_members.length <= 1) {
      return false; // Cannot delete the last remaining member
    }

    _members.removeWhere((m) => m.id == memberId);

    // If the deleted member was currentMember, switch to first member
    if (_currentMember.id == memberId) {
      _currentMember = _members.first;
    }

    await _saveData();
    notifyListeners();
    return true;
  }

  Future<void> updateMember(Member updatedMember) async {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) {
      _members[index] = updatedMember;
      if (_currentMember.id == updatedMember.id) {
        _currentMember = updatedMember;
      }
      await _saveData();
      notifyListeners();
    }
  }

  void setSelectedCategory(NoticeCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Notice? getNoticeById(String id) {
    try {
      return _notices.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  // Actions
  Future<void> addNotice(Notice notice) async {
    _notices.insert(0, notice);

    // Create a new notification for other members
    final notification = NotificationItem(
      id: const Uuid().v4(),
      title: '새로운 공지가 등록되었습니다 📢',
      message: '[${notice.category.label}] ${notice.title}',
      timestamp: DateTime.now(),
      isRead: false,
      noticeId: notice.id,
      type: 'new_notice',
    );
    _notifications.insert(0, notification);

    await _saveData();
    notifyListeners();
  }

  Future<void> updateNotice(Notice updatedNotice) async {
    final index = _notices.indexWhere((n) => n.id == updatedNotice.id);
    if (index != -1) {
      _notices[index] = updatedNotice;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteNotice(String noticeId) async {
    _notices.removeWhere((n) => n.id == noticeId);
    _notifications.removeWhere((n) => n.noticeId == noticeId);
    await _saveData();
    notifyListeners();
  }

  Future<void> togglePin(String noticeId) async {
    final index = _notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      final notice = _notices[index];
      _notices[index] = notice.copyWith(isPinned: !notice.isPinned);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> incrementViewCount(String noticeId) async {
    final index = _notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      final notice = _notices[index];
      _notices[index] = notice.copyWith(views: notice.views + 1);
      await _saveData();
      notifyListeners();
    }
  }

  // Toggle '확인했어요' (Acknowledge notice receipt)
  Future<void> toggleAck(String noticeId) async {
    final index = _notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      final notice = _notices[index];
      final readList = List<String>.from(notice.readMemberIds);
      if (readList.contains(_currentMember.id)) {
        readList.remove(_currentMember.id);
      } else {
        readList.add(_currentMember.id);
      }
      _notices[index] = notice.copyWith(readMemberIds: readList);
      await _saveData();
      notifyListeners();
    }
  }

  // Vote in Poll
  Future<void> votePoll(String noticeId, String optionId) async {
    final index = _notices.indexWhere((n) => n.id == noticeId);
    if (index != -1 && _notices[index].poll != null) {
      final notice = _notices[index];
      final poll = notice.poll!;
      final currentMemberId = _currentMember.id;

      final updatedOptions = poll.options.map((opt) {
        final voterList = List<String>.from(opt.voterMemberIds);
        if (poll.isMultipleChoice) {
          // Toggle this option
          if (opt.id == optionId) {
            if (voterList.contains(currentMemberId)) {
              voterList.remove(currentMemberId);
            } else {
              voterList.add(currentMemberId);
            }
          }
        } else {
          // Single choice: remove from all other options, toggle this option
          if (opt.id == optionId) {
            if (voterList.contains(currentMemberId)) {
              voterList.remove(currentMemberId);
            } else {
              voterList.add(currentMemberId);
            }
          } else {
            voterList.remove(currentMemberId);
          }
        }
        return PollOption(
          id: opt.id,
          text: opt.text,
          voterMemberIds: voterList,
        );
      }).toList();

      final updatedPoll = Poll(
        id: poll.id,
        question: poll.question,
        options: updatedOptions,
        isMultipleChoice: poll.isMultipleChoice,
        isClosed: poll.isClosed,
      );

      _notices[index] = notice.copyWith(poll: updatedPoll);
      await _saveData();
      notifyListeners();
    }
  }

  // Add or Toggle Emoji Reaction
  Future<void> addReaction(String noticeId, String emoji) async {
    final index = _notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      final notice = _notices[index];
      final currentMemberId = _currentMember.id;
      final existingReactions = List<Reaction>.from(notice.reactions);

      final reactionIndex =
          existingReactions.indexWhere((r) => r.emoji == emoji);
      if (reactionIndex != -1) {
        final voterList =
            List<String>.from(existingReactions[reactionIndex].memberIds);
        if (voterList.contains(currentMemberId)) {
          voterList.remove(currentMemberId);
        } else {
          voterList.add(currentMemberId);
        }
        if (voterList.isEmpty) {
          existingReactions.removeAt(reactionIndex);
        } else {
          existingReactions[reactionIndex] = Reaction(
            emoji: emoji,
            memberIds: voterList,
          );
        }
      } else {
        existingReactions.add(Reaction(
          emoji: emoji,
          memberIds: [currentMemberId],
        ));
      }

      _notices[index] = notice.copyWith(reactions: existingReactions);
      await _saveData();
      notifyListeners();
    }
  }

  // Add Comment
  Future<void> addComment(String noticeId, String content) async {
    if (content.trim().isEmpty) return;

    final index = _notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      final notice = _notices[index];
      final newComment = Comment(
        id: const Uuid().v4(),
        memberId: _currentMember.id,
        memberName: _currentMember.nickname,
        memberEmoji: _currentMember.emoji,
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      final updatedComments = List<Comment>.from(notice.comments)
        ..add(newComment);

      _notices[index] = notice.copyWith(comments: updatedComments);

      // Notification
      if (notice.authorId != _currentMember.id) {
        final notif = NotificationItem(
          id: const Uuid().v4(),
          title: '새로운 가족 댓글 💬',
          message:
              '${_currentMember.nickname}님이 "${notice.title}" 공지에 댓글을 남겼습니다.',
          timestamp: DateTime.now(),
          isRead: false,
          noticeId: notice.id,
          type: 'comment',
        );
        _notifications.insert(0, notif);
      }

      await _saveData();
      notifyListeners();
    }
  }

  // Notifications
  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveData();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveData();
    notifyListeners();
  }

  // Reset to default sample data
  Future<void> resetToSampleData() async {
    _members = List.from(SampleData.members);
    _currentMember = _members.first;
    _notices = SampleData.getNotices();
    _notifications = SampleData.getNotifications();
    _selectedCategory = NoticeCategory.all;
    _searchQuery = '';
    await _saveData();
    notifyListeners();
  }
}
