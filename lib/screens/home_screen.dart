import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/notice.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../providers/music_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/family_switcher_bottom_sheet.dart';
import '../widgets/member_avatar.dart';
import '../widgets/notice_card.dart';
import '../widgets/pinned_banner.dart';
import '../widgets/mini_music_bar.dart';
import '../widgets/music_player_sheet.dart';
import 'notice_form_screen.dart';
import 'members_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildNoticeFeedTab(BuildContext context) {
    final provider = context.watch<NoticeProvider>();
    final currentMember = provider.currentMember;
    final notices = provider.filteredNotices;
    final pinnedNotices = provider.pinnedNotices;
    final unreadCount = provider.unreadNoticeCount;
    final musicProvider = context.watch<MusicProvider>();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          pinned: false,
          snap: true,
          elevation: 0,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              // Tuna App Icon Image
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/tuna_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryLight,
                      child: const Center(
                        child: Text('🐟', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '참치패밀리',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '가족 공지 및 일정 소통방',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Music Player Button in AppBar
            IconButton(
              icon: Icon(
                musicProvider.isPlaying
                    ? Icons.music_note_rounded
                    : Icons.music_off_outlined,
                color: musicProvider.isPlaying
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
              tooltip: '배경음악 플레이어',
              onPressed: () => MusicPlayerSheet.show(context),
            ),

            // Family Profile Switcher Button
            InkWell(
              onTap: () => FamilySwitcherBottomSheet.show(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    MemberAvatar(member: currentMember, size: 24),
                    const SizedBox(width: 5),
                    Text(
                      currentMember.nickname.split(' ').first,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Notification Bell with Badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.textPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (provider.unreadNotificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${provider.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6),
          ],
        ),

        // Search Bar & Stats Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                // Status summary chip bar
                Row(
                  children: [
                    Text(
                      '공지 ${notices.length}개',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '내가 안 읽은 공지 $unreadCount개',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Quick Reset Menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          size: 18, color: AppColors.textMuted),
                      onSelected: (value) {
                        if (value == 'reset') {
                          provider.resetToSampleData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('참치패밀리 기본 데이터로 초기화되었습니다 🐟'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (value == 'music') {
                          MusicPlayerSheet.show(context);
                        } else if (value == 'logout') {
                          context.read<AuthProvider>().logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('로그아웃되었습니다.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'music',
                          child: Row(
                            children: [
                              Icon(Icons.music_note_rounded,
                                  size: 18, color: AppColors.secondary),
                              SizedBox(width: 8),
                              Text('배경음악 설정'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: [
                              Icon(Icons.refresh_rounded,
                                  size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Text('기본 샘플 데이터로 복원'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('참치패밀리 로그아웃',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Category Filter Chips
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: NoticeCategory.values.map((cat) {
                final isSelected = provider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 14,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => provider.setSelectedCategory(cat),
                    backgroundColor: Colors.white,
                    selectedColor: cat == NoticeCategory.all
                        ? AppColors.primary
                        : cat.color,
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.border,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Pinned Notices Banner (Only show when on "all" category and no active search)
        if (provider.selectedCategory == NoticeCategory.all &&
            provider.searchQuery.isEmpty &&
            pinnedNotices.isNotEmpty)
          SliverToBoxAdapter(
            child: PinnedBanner(pinnedNotices: pinnedNotices),
          ),

        // Notices Feed List
        if (notices.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🐟', style: TextStyle(fontSize: 42)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '등록된 공지사항이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '새로운 가족 소식이나 일정을 공지해 보세요!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NoticeFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('첫 공지 작성하기'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notice = notices[index];
                return NoticeCard(notice: notice);
              },
              childCount: notices.length,
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100), // Spacing for floating action button & mini player
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final musicProvider = context.watch<MusicProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Embedded YouTube player for continuous in-app background music streaming
          if (musicProvider.currentTrack.isYouTube &&
              musicProvider.currentTrack.youtubeVideoId != null)
            Positioned(
              left: -9999,
              top: -9999,
              width: 1,
              height: 1,
              child: YoutubePlayer(
                controller: musicProvider.ytController,
              ),
            ),
          IndexedStack(
            index: _currentNavIndex,
            children: [
              _buildNoticeFeedTab(context),
              const MembersScreen(),
              const NotificationsScreen(isTab: true),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NoticeFormScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.edit_note_rounded, size: 22),
              label: const Text(
                '공지 작성',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            )
          : null,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Music Bar above bottom nav
          const MiniMusicBar(),

          // Bottom Nav Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentNavIndex,
              onTap: (index) => setState(() => _currentNavIndex = index),
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: '공지피드',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: '참치패밀리',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_none_rounded),
                      if (provider.unreadNotificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: const Icon(Icons.notifications_rounded),
                  label: '알림',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
