class Comment {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmoji;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmoji,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'memberName': memberName,
        'memberEmoji': memberEmoji,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        memberName: json['memberName'] as String,
        memberEmoji: json['memberEmoji'] as String? ?? '🐟',
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
