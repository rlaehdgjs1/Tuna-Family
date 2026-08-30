class Reaction {
  final String emoji;
  final List<String> memberIds;

  Reaction({
    required this.emoji,
    List<String>? memberIds,
  }) : memberIds = memberIds ?? [];

  int get count => memberIds.length;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'memberIds': memberIds,
      };

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        emoji: json['emoji'] as String,
        memberIds: (json['memberIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}
