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

  test('AuthProvider register, login, password hash, and privacy masking test',
      () async {
    final auth = AuthProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    expect(auth.isLoggedIn, isFalse);

    // 1. Register Account
    final regError = await auth.register(
      name: '홍길동',
      phoneNumber: '010-1234-5678',
      password: 'password123',
      nickname: '골드참치 🌟',
      role: '삼촌 / 요리',
      emoji: '🌟',
      colorValue: 0xFF0F4C81,
    );

    expect(regError, isNull);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser!.nickname, equals('골드참치 🌟'));

    // Privacy Masking Verification (No Leakage)
    expect(auth.currentUser!.maskedPhone, equals('010-****-5678'));
    expect(auth.currentUser!.maskedName, equals('홍*동'));
    expect(auth.currentUser!.passwordHash, isNot(equals('password123')));

    // 2. Logout
    await auth.logout();
    expect(auth.isLoggedIn, isFalse);

    // 3. Failed Login (Wrong Password)
    final wrongPassError =
        await auth.login('010-1234-5678', 'wrong_password');
    expect(wrongPassError, isNotNull);
    expect(wrongPassError, contains('비밀번호가 일치하지 않습니다'));
    expect(auth.isLoggedIn, isFalse);

    // 4. Successful Login
    final loginSuccess = await auth.login('010-1234-5678', 'password123');
    expect(loginSuccess, isNull);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser!.nickname, equals('골드참치 🌟'));
  });

  test(
      'NoticeProvider starts with 0 notices and handles notice creation & notification',
      () async {
    final provider = NoticeProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    expect(provider.members.isNotEmpty, isTrue);
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
    final found =
        provider.members.firstWhere((m) => m.id == 'mem_test_grandma');
    expect(found.nickname, equals('요리왕할머니 👵'));
    expect(found.role, equals('할머니 / 수석셰프'));

    // 3. Delete Member
    final deleteResult = await provider.deleteMember('mem_test_grandma');
    expect(deleteResult, isTrue);
    expect(provider.members.length, equals(initialMemberCount));
    expect(provider.members.any((m) => m.id == 'mem_test_grandma'), isFalse);
  });

  test('MusicTrack model, start modes, and serialization test', () {
    expect(MusicProvider.presetTracks.length, equals(2));
    expect(MusicProvider.presetTracks.first.title, contains('바다의 멜로디'));

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
