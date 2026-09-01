import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuna_family/main.dart';
import 'package:tuna_family/providers/auth_provider.dart';
import 'package:tuna_family/providers/notice_provider.dart';
import 'package:tuna_family/providers/music_provider.dart';
import 'package:tuna_family/models/notice.dart';
import 'package:tuna_family/models/member.dart';
import 'package:tuna_family/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Tuna Family App renders LoginScreen when logged out',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TunaFamilyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Login Screen appears as gateway
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('로그인'), findsWidgets);
    expect(find.text('참치패밀리 로그인'), findsOneWidget);
    expect(find.text('휴대폰 번호와 비밀번호로 로그인하세요.'), findsOneWidget);
    expect(find.text('휴대폰 번호'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('새 계정 만들기 (회원가입)'), findsOneWidget);
  });

  test(
      'AuthProvider grade system (일반 default, 관리자, 등급 조절) and member deletion test',
      () async {
    final auth = AuthProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    expect(auth.isLoggedIn, isFalse);

    // 1. First registered user automatically becomes ADMIN (MemberGrade.admin)
    final adminRegError = await auth.register(
      name: '김참치',
      phoneNumber: '010-1111-2222',
      password: 'adminPass123',
      nickname: '참치대장 👑',
      role: '아빠 / 모임 총괄',
      emoji: '👑',
      colorValue: 0xFF0F4C81,
    );

    expect(adminRegError, isNull);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser!.isAdmin, isTrue);
    expect(auth.currentUser!.grade, equals(MemberGrade.admin));
    expect(auth.isCurrentUserAdmin, isTrue);

    // 2. Second registered user gets DEFAULT grade: MemberGrade.general (일반)
    await auth.logout();
    final userRegError = await auth.register(
      name: '김푸름',
      phoneNumber: '010-9999-8888',
      password: 'userPass123',
      emoji: '🏄‍♂️',
      colorValue: 0xFF0284C7,
    );

    expect(userRegError, isNull);
    expect(auth.currentUser!.isAdmin, isFalse);
    expect(auth.currentUser!.grade, equals(MemberGrade.general)); // 일반 등급
    expect(auth.isCurrentUserAdmin, isFalse);

    final regularUserId = auth.currentUser!.id;

    // 3. Normal user attempts to adjust grade or delete -> REJECTED
    final nonAdminGradeError =
        await auth.updateMemberGrade(regularUserId, MemberGrade.vip);
    expect(nonAdminGradeError, contains('관리자 권한'));

    // 4. Log back in as ADMIN and adjust regular user's grade to VIP (우수회원)
    await auth.logout();
    await auth.login('010-1111-2222', 'adminPass123');
    expect(auth.isCurrentUserAdmin, isTrue);

    final gradeChangeSuccess =
        await auth.updateMemberGrade(regularUserId, MemberGrade.vip);
    expect(gradeChangeSuccess, isNull);

    final updatedUser = auth.accounts.firstWhere((a) => a.id == regularUserId);
    expect(updatedUser.grade, equals(MemberGrade.vip));
    expect(updatedUser.isAdmin, isFalse);

    // 5. Admin deletes member -> SUCCESS
    final adminDeleteSuccess = await auth.deleteAccountByAdmin(regularUserId);
    expect(adminDeleteSuccess, isNull);
    expect(auth.accounts.any((a) => a.id == regularUserId), isFalse);
  });

  test(
      'NoticeProvider starts with only 1 admin member (참치대장) and 0 notices',
      () async {
    final provider = NoticeProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    // Only 1 admin member (참치대장) exists initially
    expect(provider.members.length, equals(1));
    expect(provider.members.first.nickname, contains('참치대장'));
    expect(provider.members.first.isAdmin, isTrue);
    expect(provider.members.first.grade, equals(MemberGrade.admin));

    // Verified 0 initial notices
    expect(provider.filteredNotices.isEmpty, isTrue);

    // Test Create Notice
    final newNotice = Notice(
      id: 'test_notice_999',
      title: '테스트 공지입니다',
      content: '테스트 내용입니다',
      authorId: provider.currentMember.id,
      authorName: provider.currentMember.nickname,
      authorEmoji: provider.currentMember.emoji,
      category: NoticeCategory.notice,
      createdAt: DateTime.now(),
    );

    await provider.addNotice(newNotice);
    expect(provider.filteredNotices.length, equals(1));
    expect(provider.getNoticeById('test_notice_999'), isNotNull);
    expect(provider.notifications.isNotEmpty, isTrue);

    // Test Ack Toggle
    final firstNotice = provider.filteredNotices.first;
    final initialAckCount = firstNotice.readMemberIds.length;
    await provider.toggleAck(firstNotice.id);
    final updatedNotice = provider.getNoticeById(firstNotice.id)!;
    expect(updatedNotice.readMemberIds.length, isNot(initialAckCount));

    // Test Comment Add
    await provider.addComment(firstNotice.id, '테스트 댓글입니다 🐟');
    final noticeWithComment = provider.getNoticeById(firstNotice.id)!;
    expect(noticeWithComment.comments.any((c) => c.content == '테스트 댓글입니다 🐟'),
        isTrue);

    // Test Delete Notice
    await provider.deleteNotice('test_notice_999');
    expect(provider.filteredNotices.isEmpty, isTrue);
    expect(provider.getNoticeById('test_notice_999'), isNull);
  });

  test('NoticeProvider Member Add, Update Grade, Delete test', () async {
    final provider = NoticeProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    final initialMemberCount = provider.members.length;

    // 1. Add Member with General Grade (일반)
    const newMember = Member(
      id: 'mem_test_grandma',
      name: '김순자',
      nickname: '할머니참치 👵',
      role: '할머니 / 요리담당',
      emoji: '👵',
      colorValue: 0xFFE11D48,
      isAdmin: false,
      grade: MemberGrade.general,
    );

    await provider.addMember(newMember);
    expect(provider.members.length, equals(initialMemberCount + 1));
    expect(provider.members.any((m) => m.id == 'mem_test_grandma'), isTrue);

    // 2. Update Member Grade to Regular (정회원)
    await provider.updateMemberGrade('mem_test_grandma', MemberGrade.regular);
    final found =
        provider.members.firstWhere((m) => m.id == 'mem_test_grandma');
    expect(found.grade, equals(MemberGrade.regular));

    // 3. Delete Member
    final deleteResult = await provider.deleteMember('mem_test_grandma');
    expect(deleteResult, isTrue);
    expect(provider.members.length, equals(initialMemberCount));
    expect(provider.members.any((m) => m.id == 'mem_test_grandma'), isFalse);
  });

  test('MusicTrack model, start modes, and serialization test', () {
    // Preset tracks removed as requested
    expect(MusicProvider.presetTracks.isEmpty, isTrue);

    final track = const MusicTrack(
      id: 'custom_1',
      title: '내 노래.mp3',
      artist: '아티스트',
      icon: '🎧',
      url: 'https://example.com/audio.mp3',
      isCustom: true,
    );

    final json = track.toJson();
    final restored = MusicTrack.fromJson(json);
    expect(restored.id, equals('custom_1'));
    expect(restored.title, equals('내 노래.mp3'));
    expect(restored.isCustom, isTrue);

    // YouTube link ID extraction tests
    expect(MusicTrack.extractYouTubeId('https://youtu.be/dQw4w9WgXcQ'),
        equals('dQw4w9WgXcQ'));
    expect(
        MusicTrack.extractYouTubeId(
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        equals('dQw4w9WgXcQ'));
    expect(
        MusicTrack.extractYouTubeId(
            'https://music.youtube.com/watch?v=dQw4w9WgXcQ'),
        equals('dQw4w9WgXcQ'));

    final ytTrack = const MusicTrack(
      id: 'yt_1',
      title: '힐링 피아노',
      artist: 'YouTube',
      icon: '🎬',
      url: 'https://youtu.be/dQw4w9WgXcQ',
      isCustom: true,
      isYouTube: true,
      youtubeVideoId: 'dQw4w9WgXcQ',
    );

    expect(ytTrack.isYouTube, isTrue);
    expect(ytTrack.youtubeThumbnailUrl, contains('dQw4w9WgXcQ'));

    final ytJson = ytTrack.toJson();
    final restoredYt = MusicTrack.fromJson(ytJson);
    expect(restoredYt.isYouTube, isTrue);
    expect(restoredYt.youtubeVideoId, equals('dQw4w9WgXcQ'));

    expect(MusicStartMode.values.length, equals(3));
  });

  test('Notice model imageUrls and videoUrl serialization test', () {
    final notice = Notice(
      id: 'media_notice_1',
      title: '미디어 공지',
      content: '사진과 영상이 첨부된 공지입니다',
      authorId: 'mem_1',
      authorName: '참치대장',
      authorEmoji: '👑',
      category: NoticeCategory.notice,
      createdAt: DateTime.now(),
      imageUrls: [
        'https://example.com/photo1.jpg',
        'https://example.com/photo2.jpg'
      ],
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );

    final json = notice.toJson();
    final restored = Notice.fromJson(json);

    expect(restored.id, equals('media_notice_1'));
    expect(restored.imageUrls.length, equals(2));
    expect(restored.imageUrls.first, equals('https://example.com/photo1.jpg'));
    expect(restored.videoUrl,
        equals('https://www.youtube.com/watch?v=dQw4w9WgXcQ'));
  });
}
