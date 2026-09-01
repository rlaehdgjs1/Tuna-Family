import 'package:flutter/material.dart';
import 'poll.dart';
import 'comment.dart';
import 'reaction.dart';

enum NoticeCategory {
  all('전체', Icons.grid_view_rounded, Color(0xFF64748B)),
  notice('공지', Icons.campaign_rounded, Color(0xFFE53935));

  final String label;
  final IconData icon;
  final Color color;

  const NoticeCategory(this.label, this.icon, this.color);

  static NoticeCategory fromString(String value) {
    if (value == 'all' || value == '전체') return NoticeCategory.all;
    return NoticeCategory.notice;
  }
}

class Notice {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorEmoji;
  final NoticeCategory category;
  final bool isPinned;
  final int views;
  final List<String> readMemberIds;
  final DateTime createdAt;
  final Poll? poll;
  final List<Comment> comments;
  final List<Reaction> reactions;
  final List<String> tags;

  const Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorEmoji,
    required this.category,
    this.isPinned = false,
    this.views = 0,
    this.readMemberIds = const [],
    required this.createdAt,
    this.poll,
    this.comments = const [],
    this.reactions = const [],
    this.tags = const [],
  });

  bool isReadBy(String memberId) => readMemberIds.contains(memberId);

  int get ackCount => readMemberIds.length;

  int get commentCount => comments.length;

  Notice copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorEmoji,
    NoticeCategory? category,
    bool? isPinned,
    int? views,
    List<String>? readMemberIds,
    DateTime? createdAt,
    Poll? poll,
    List<Comment>? comments,
    List<Reaction>? reactions,
    List<String>? tags,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmoji: authorEmoji ?? this.authorEmoji,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      views: views ?? this.views,
      readMemberIds: readMemberIds ?? this.readMemberIds,
      createdAt: createdAt ?? this.createdAt,
      poll: poll ?? this.poll,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorEmoji': authorEmoji,
      'category': category.name,
      'isPinned': isPinned,
      'views': views,
      'readMemberIds': readMemberIds,
      'createdAt': createdAt.toIso8601String(),
      'poll': poll?.toJson(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'tags': tags,
    };
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorEmoji: json['authorEmoji'] as String? ?? '🐟',
      category: NoticeCategory.fromString(json['category'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      readMemberIds: (json['readMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      poll: json['poll'] != null
          ? Poll.fromJson(json['poll'] as Map<String, dynamic>)
          : null,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((r) => Reaction.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
    );
  }
}
