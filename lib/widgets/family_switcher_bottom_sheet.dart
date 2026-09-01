import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';
import 'member_avatar.dart';

class FamilySwitcherBottomSheet extends StatelessWidget {
  const FamilySwitcherBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const FamilySwitcherBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final members = provider.members;
    final currentMember = provider.currentMember;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const Text(
                  '🐟 참치패밀리 구성원 관리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '현재: ${currentMember.nickname}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '공지 확인 및 투표/댓글을 작성할 가족 프로필을 선택하세요.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: members.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isSelected = member.id == currentMember.id;

                  return InkWell(
                    onTap: () {
                      provider.setCurrentMember(member);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${member.nickname} 프로필로 전환되었습니다! 🐟'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight.withValues(alpha: 0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          MemberAvatar(member: member, size: 42),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.nickname,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Color(member.grade.bgValue),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Color(member.grade.colorValue)
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(member.grade.icon,
                                                style: const TextStyle(
                                                    fontSize: 10)),
                                            const SizedBox(width: 2),
                                            Text(
                                              member.grade.label,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(
                                                    member.grade.colorValue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '현재 접속',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${member.maskedName} • ${member.role}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 24,
                            )
                          else
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await authProvider.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('로그아웃되었습니다.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded,
                    size: 18, color: AppColors.error),
                label: const Text(
                  '참치패밀리 로그아웃',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
