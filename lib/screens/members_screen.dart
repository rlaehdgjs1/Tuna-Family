import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../models/member.dart';
import '../utils/app_theme.dart';
import '../widgets/member_avatar.dart';
import '../widgets/family_switcher_bottom_sheet.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  static const List<String> availableEmojis = [
    '👑',
    '🌸',
    '🏄‍♂️',
    '🎨',
    '🐣',
    '🐟',
    '👵',
    '👴',
    '🐱',
    '🐶',
    '⭐',
    '💖',
    '🍕',
    '🚀',
    '🧸',
    '🕶️'
  ];

  static const List<int> availableColors = [
    0xFF0F4C81, // Ocean Blue
    0xFFE11D48, // Coral Rose
    0xFF0284C7, // Sky Blue
    0xFF9333EA, // Purple
    0xFFF59E0B, // Amber Orange
    0xFF0D9488, // Teal
    0xFF10B981, // Emerald Green
    0xFF4F46E5, // Indigo
  ];

  void _showAddEditMemberDialog(BuildContext context, {Member? memberToEdit}) {
    final provider = context.read<NoticeProvider>();
    final authProvider = context.read<AuthProvider>();
    final isEditing = memberToEdit != null;
    final isCurrentAdmin = authProvider.isCurrentUserAdmin;

    final nameController =
        TextEditingController(text: memberToEdit?.name ?? '');
    final nicknameController =
        TextEditingController(text: memberToEdit?.nickname ?? '');
    final roleController =
        TextEditingController(text: memberToEdit?.role ?? '');

    String selectedEmoji = memberToEdit?.emoji ?? '🐟';
    int selectedColor = memberToEdit?.colorValue ?? 0xFF0F4C81;
    bool isAdmin = memberToEdit?.isAdmin ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          isEditing ? '가족 구성원 정보 수정' : '새 가족 구성원 추가 🐟',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Avatar Preview
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Color(selectedColor).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(selectedColor),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            selectedEmoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emoji Selection
                    const Text(
                      '캐릭터 이모지 선택',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: availableEmojis.map((emoji) {
                          final isSelected = selectedEmoji == emoji;
                          return InkWell(
                            onTap: () {
                              setModalState(() => selectedEmoji = emoji);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color Selection
                    const Text(
                      '프로필 테마 색상',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: availableColors.map((colorVal) {
                          final isSelected = selectedColor == colorVal;
                          return InkWell(
                            onTap: () {
                              setModalState(() => selectedColor = colorVal);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(colorVal),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black87
                                      : Colors.transparent,
                                  width: isSelected ? 3 : 0,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 18, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nickname Input
                    const Text(
                      '가족 닉네임 / 호칭 *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(
                        hintText: '예: 할머니참치 👵, 막내딸 🌸',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Real Name Input
                    const Text(
                      '실제 이름 (외부 비공개)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: '예: 김순자 (내부 인증용)',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Role Input
                    const Text(
                      '가족 내 역할 / 소개',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        hintText: '예: 할머니 / 사랑과 요리 담당',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Admin Privilege Toggle (Only Admin can grant/revoke)
                    if (isCurrentAdmin) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings_rounded,
                                color: Color(0xFFD97706), size: 22),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '관리자 권한 부여',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  Text(
                                    '회원 삭제 및 관리자 기능을 수행할 수 있습니다.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isAdmin,
                              activeThumbColor: const Color(0xFFD97706),
                              activeTrackColor: const Color(0xFFFDE68A),
                              onChanged: (val) {
                                setModalState(() => isAdmin = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final nickname = nicknameController.text.trim();
                          final name = nameController.text.trim();
                          final role = roleController.text.trim();

                          if (nickname.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('가족 닉네임을 입력해 주세요.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (isEditing) {
                            final updated = memberToEdit.copyWith(
                              name: name.isNotEmpty ? name : nickname,
                              nickname: nickname,
                              role: role.isNotEmpty ? role : '가족 구성원',
                              emoji: selectedEmoji,
                              colorValue: selectedColor,
                              isAdmin: isAdmin,
                            );
                            provider.updateMember(updated);
                            authProvider.updateProfile(updated);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$nickname 정보가 수정되었습니다! 🐟'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            final newMember = Member(
                              id: const Uuid().v4(),
                              name: name.isNotEmpty ? name : nickname,
                              nickname: nickname,
                              role: role.isNotEmpty ? role : '가족 구성원',
                              emoji: selectedEmoji,
                              colorValue: selectedColor,
                              isAdmin: isAdmin,
                              createdAt: DateTime.now(),
                            );
                            provider.addMember(newMember);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$nickname님이 참치패밀리에 합류했습니다! 🎉'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isEditing ? '수정 완료' : '가족 구성원 등록하기 🐟',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Admin Member Deletion Handler
  void _confirmDeleteMemberByAdmin(BuildContext context, Member member) {
    final provider = context.read<NoticeProvider>();
    final authProvider = context.read<AuthProvider>();

    // 1. Permission check
    if (!authProvider.isCurrentUserAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원 삭제는 관리자 권한이 필요합니다. 🔒'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Prevent self-deletion
    if (authProvider.currentUser?.id == member.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 로그인 중인 본인 관리자 계정은 삭제할 수 없습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (provider.members.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1명의 가족 구성원은 유지되어야 합니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_remove_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              '회원 계정 강퇴 / 삭제',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\'${member.nickname}\' (${member.maskedName}) 님을 참치패밀리에서 강퇴 및 삭제하시겠습니까?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '삭제된 회원은 즉시 앱 로그인이 차단되며 모든 구성원 목록에서 제거됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              // 1. Delete from AuthProvider accounts
              final err = await authProvider.deleteAccountByAdmin(member.id);
              // 2. Delete from NoticeProvider members
              await provider.deleteMember(member.id);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(err ?? '${member.nickname} 회원이 삭제(강퇴)되었습니다.'),
                  backgroundColor:
                      err == null ? AppColors.textPrimary : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('삭제 및 강퇴'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final members = provider.members;
    final currentMember = provider.currentMember;
    final notices = provider.filteredNotices;
    final isCurrentUserAdmin = authProvider.isCurrentUserAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('참치패밀리 구성원 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: '새 구성원 추가',
            onPressed: () => _showAddEditMemberDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: '프로필 전환',
            onPressed: () => FamilySwitcherBottomSheet.show(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Active Profile Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                MemberAvatar(
                  member: currentMember,
                  size: 56,
                  customBgColor: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              currentMember.nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (currentMember.isAdmin || isCurrentUserAdmin) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield_rounded,
                                      size: 11, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    '관리자',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '현재 나',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentMember.maskedName} • ${currentMember.role}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => FamilySwitcherBottomSheet.show(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Admin Banner
          if (isCurrentUserAdmin) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded,
                      size: 20, color: Color(0xFFD97706)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '👑 관리자 권한 활성화: 회원 계정 삭제(강퇴) 및 권한 설정이 가능합니다.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Family stats summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('가족 구성원', '${members.length}명',
                    Icons.family_restroom_rounded),
                _buildDivider(),
                _buildStatItem(
                    '누적 공지', '${notices.length}개', Icons.campaign_rounded),
                _buildDivider(),
                _buildStatItem('공지 소통방', '100% 활성', Icons.chat_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header with Add Button
          Row(
            children: [
              const Text(
                '가족 명단 및 활동 통계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddEditMemberDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('구성원 추가'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Member Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final member = members[index];
              final isMe = member.id == currentMember.id;

              // Calculate member stats
              final writtenNotices =
                  notices.where((n) => n.authorId == member.id).length;
              final ackNotices = notices
                  .where((n) => n.readMemberIds.contains(member.id))
                  .length;
              final ackRate = notices.isNotEmpty
                  ? (ackNotices / notices.length * 100).toInt()
                  : 0;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isMe
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                    width: isMe ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          MemberAvatar(member: member, size: 48),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        member.nickname,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (member.isAdmin) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: const Color(0xFFFCD34D)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.shield_rounded,
                                                size: 11,
                                                color: Color(0xFFD97706)),
                                            SizedBox(width: 2),
                                            Text(
                                              '관리자',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '나',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${member.maskedName} • ${member.role}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '공지 $writtenNotices회 작성',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '확인율 $ackRate%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: ackRate >= 80
                                            ? AppColors.success
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 6),
                      // Actions row: Switch, Edit, Admin delete/grant
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            TextButton.icon(
                              onPressed: () {
                                provider.setCurrentMember(member);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${member.nickname} 프로필로 전환되었습니다! 🐟'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.login_rounded, size: 16),
                              label: const Text('프로필 전환'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 18, color: AppColors.textSecondary),
                            tooltip: '정보 수정',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _showAddEditMemberDialog(
                              context,
                              memberToEdit: member,
                            ),
                          ),
                          // Admin controls for member management
                          if (isCurrentUserAdmin && !isMe) ...[
                            IconButton(
                              icon: Icon(
                                member.isAdmin
                                    ? Icons.shield_rounded
                                    : Icons.shield_outlined,
                                size: 18,
                                color: member.isAdmin
                                    ? const Color(0xFFD97706)
                                    : Colors.grey,
                              ),
                              tooltip:
                                  member.isAdmin ? '관리자 권한 해제' : '관리자 권한 부여',
                              visualDensity: VisualDensity.compact,
                              onPressed: () async {
                                await authProvider.toggleAdminRole(member.id);
                                provider.updateMember(
                                    member.copyWith(isAdmin: !member.isAdmin));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        !member.isAdmin
                                            ? '${member.nickname}님에게 관리자 권한이 부여되었습니다. 👑'
                                            : '${member.nickname}님의 관리자 권한이 해제되었습니다.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove_rounded,
                                  size: 18, color: AppColors.error),
                              tooltip: '회원 계정 삭제 및 강퇴 (관리자 전용)',
                              visualDensity: VisualDensity.compact,
                              onPressed: () =>
                                 _confirmDeleteMemberByAdmin(context, member),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Add Member dashed button
          InkWell(
            onTap: () => _showAddEditMemberDialog(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '+ 새 가족 구성원 등록하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.divider,
    );
  }
}
