import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuna_family/main.dart';
import 'package:tuna_family/providers/notice_provider.dart';
import 'package:tuna_family/providers/music_provider.dart';
import 'package:tuna_family/models/notice.dart';
import 'package:tuna_family/models/member.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Tuna Family App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TunaFamilyApp());
    // Pump frames to let providers async init complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Tuna Family widgets appear
    expect(find.text('참치패밀리'), findsWidgets);
    expect(find.text('가족 공지 및 일정 소통방'), findsOneWidget);
    expect(find.text('공지피드'), findsOneWidget);
  });

  test('NoticeProvider CRUD & interaction test', () async {
    final provider = NoticeProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    expect(provider.members.isNotEmpty, isTrue);
    expect(provider.filteredNotices.isNotEmpty, isTrue);

    final initialCount = provider.filteredNotices.length;
    final firstNotice = provider.filteredNotices.first;

    // Test Ack Toggle
    final initialAckCount = firstNotice.readMemberIds.length;
    await provider.toggleAck(firstNotice.id);
    final updatedNotice = provider.getNoticeById(firstNotice.id)!;
    expect(updatedNotice.readMemberIds.length, isNot(initialAckCount));

    // Test Comment Add
    await provider.addComment(firstNotice.id, '테스트 댓글입니다 🐟');
    final noticeWithComment = provider.getNoticeById(firstNotice.id)!;
    expect(noticeWithComment.comments.any((c) => c.content == '테스트 댓글입니다 🐟'), isTrue);

    // Test Create Notice
    final newNotice = Notice(
      id: 'test_notice_999',
      title: '테스트 공지입니다',
      content: '테스트 내용입니다',
      authorId: provider.currentMember.id,
      authorName: provider.currentMember.nickname,
      authorEmoji: provider.currentMember.emoji,
      category: NoticeCategory.general,
      createdAt: DateTime.now(),
    );

    await provider.addNotice(newNotice);
    expect(provider.filteredNotices.length, equals(initialCount + 1));
  });

  test('NoticeProvider Member Add, Update, Delete test', () async {
    final provider = NoticeProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    final initialMemberCount = provider.members.length;

    // 1. Add Member
    const newMember = Member(
      id: 'mem_test_grandma',
      name: '김순자',
      nickname: '할머니참치 👵',
      role: '할머니 / 요리담당',
      emoji: '👵',
      colorValue: 0xFFE11D48,
    );

    await provider.addMember(newMember);
    expect(provider.members.length, equals(initialMemberCount + 1));
    expect(provider.members.any((m) => m.id == 'mem_test_grandma'), isTrue);

    // 2. Update Member
    const updatedMember = Member(
      id: 'mem_test_grandma',
      name: '김순자',
      nickname: '요리왕할머니 👵',
      role: '할머니 / 수석셰프',
      emoji: '👵',
      colorValue: 0xFFE11D48,
    );
    await provider.updateMember(updatedMember);
    expect(provider.members.firstWhere((m) => m.id == 'mem_test_grandma').nickname, equals('요리왕할머니 👵'));

    // 3. Delete Member
    final deleteResult = await provider.deleteMember('mem_test_grandma');
    expect(deleteResult, isTrue);
    expect(provider.members.length, equals(initialMemberCount));
    expect(provider.members.any((m) => m.id == 'mem_test_grandma'), isFalse);
  });

  test('MusicTrack model and preset list test', () {
    expect(MusicProvider.presetTracks.length, equals(4));
    expect(MusicProvider.presetTracks.first.title, contains('바다의 멜로디'));
  });
}
