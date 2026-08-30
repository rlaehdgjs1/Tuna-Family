class Member {
  final String id;
  final String name;
  final String nickname;
  final String role;
  final String emoji;
  final int colorValue;

  const Member({
    required this.id,
    required this.name,
    required this.nickname,
    required this.role,
    required this.emoji,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'role': role,
        'emoji': emoji,
        'colorValue': colorValue,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String,
        role: json['role'] as String,
        emoji: json['emoji'] as String,
        colorValue: json['colorValue'] as int? ?? 0xFF1976D2,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
