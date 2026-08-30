class PollOption {
  final String id;
  final String text;
  final List<String> voterMemberIds;

  PollOption({
    required this.id,
    required this.text,
    List<String>? voterMemberIds,
  }) : voterMemberIds = voterMemberIds ?? [];

  int get voteCount => voterMemberIds.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'voterMemberIds': voterMemberIds,
      };

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
        id: json['id'] as String,
        text: json['text'] as String,
        voterMemberIds: (json['voterMemberIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool isMultipleChoice;
  final bool isClosed;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    this.isMultipleChoice = false,
    this.isClosed = false,
  });

  int get totalVotes =>
      options.fold(0, (sum, option) => sum + option.voteCount);

  bool hasVoted(String memberId) {
    return options.any((opt) => opt.voterMemberIds.contains(memberId));
  }

  List<String> getSelectedOptionIds(String memberId) {
    return options
        .where((opt) => opt.voterMemberIds.contains(memberId))
        .map((opt) => opt.id)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options.map((e) => e.toJson()).toList(),
        'isMultipleChoice': isMultipleChoice,
        'isClosed': isClosed,
      };

  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
        id: json['id'] as String,
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => PollOption.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isMultipleChoice: json['isMultipleChoice'] as bool? ?? false,
        isClosed: json['isClosed'] as bool? ?? false,
      );
}
