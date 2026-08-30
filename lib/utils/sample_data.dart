import '../models/member.dart';
import '../models/notice.dart';
import '../models/poll.dart';
import '../models/comment.dart';
import '../models/reaction.dart';
import '../models/notification_item.dart';

class SampleData {
  static final List<Member> members = [
    const Member(
      id: 'mem_1',
      name: '김참치',
      nickname: '참치대장 👑',
      role: '아빠 / 모임 총괄',
      emoji: '👑',
      colorValue: 0xFF0F4C81,
    ),
    const Member(
      id: 'mem_2',
      name: '이바다',
      nickname: '참치퀸 🌸',
      role: '엄마 / 회계 총괄',
      emoji: '🌸',
      colorValue: 0xFFE11D48,
    ),
    const Member(
      id: 'mem_3',
      name: '김푸름',
      nickname: '서핑참치 🏄‍♂️',
      role: '첫째 / 일정 매니저',
      emoji: '🏄‍♂️',
      colorValue: 0xFF0284C7,
    ),
    const Member(
      id: 'mem_4',
      name: '김하늘',
      nickname: '그림참치 🎨',
      role: '둘째 / 디자인&사진',
      emoji: '🎨',
      colorValue: 0xFF9333EA,
    ),
    const Member(
      id: 'mem_5',
      name: '김바람',
      nickname: '아기참치 🐣',
      role: '막내 / 마스코트',
      emoji: '🐣',
      colorValue: 0xFFF59E0B,
    ),
    const Member(
      id: 'mem_6',
      name: '김바다삼촌',
      nickname: '삼촌참치 🐟',
      role: '삼촌 / 분위기메이커',
      emoji: '🐟',
      colorValue: 0xFF0D9488,
    ),
  ];

  static List<Notice> getNotices() {
    final now = DateTime.now();

    return [
      Notice(
        id: 'notice_1',
        title: '🍁 2026 참치패밀리 가을 제주도 힐링 가족여행 일정 안내 및 참석 투표',
        content: '''사랑하는 참치패밀리 여러분! 🐟✨

드디어 기다리고 기다리던 2026 가을 정기 가족여행 일정이 확정되었습니다!
선선하고 아름다운 제주에서 온 가족이 함께 힐링하는 시간을 가져봐요.

📍 [여행 개요]
• 일시: 2026년 10월 9일(금) ~ 10월 11일(일) [2박 3일]
• 장소: 제주특별자치도 서귀포시 안덕면 독채 펜션 (오션뷰 & 바비큐장 완비)

📍 [주요 일정 안내]
1일차(금)
- 오전 10:00 김포공항 집결 및 탑승
- 오후 12:30 제주공항 도착 후 흑돼지 & 갈치조림 점심식사
- 오후 15:30 펜션 체크인 및 휴식
- 저녁 18:30 가족 환영 파티

2일차(토)
- 오전 09:30 서귀포 올레길 힐링 산책
- 오후 13:00 바다 배낚시 체험 (월척 잡기 대회!)
- 저녁 18:00 프리미엄 바비큐 & 불멍 타임

3일차(일)
- 오전 10:30 오션뷰 베이커리 카페 투어
- 오후 14:00 특산물 마켓 및 기념품 구매
- 오후 18:00 제주공항 출발 및 귀가

💡 [중요 요청사항]
비행기 단체 할인 예매 및 펜션 확정을 위해 아래 투표에 참석 여부를 꼭 선택해 주세요!
공지를 확인하신 분은 하단의 '확인했어요' 버튼을 눌러주시기 바랍니다.''',
        authorId: 'mem_1',
        authorName: '참치대장 👑',
        authorEmoji: '👑',
        category: NoticeCategory.important,
        isPinned: true,
        views: 34,
        readMemberIds: ['mem_1', 'mem_2', 'mem_3', 'mem_4'],
        createdAt: now.subtract(const Duration(hours: 3)),
        tags: ['가족여행', '제주도', '필독', '투표'],
        poll: Poll(
          id: 'poll_1',
          question: '제주도 가족여행 참석 여부를 알려주세요! ✈️',
          options: [
            PollOption(
              id: 'opt_1',
              text: '무조건 참석합니다! ✈️ (휴가 결재 완료)',
              voterMemberIds: ['mem_1', 'mem_2', 'mem_3'],
            ),
            PollOption(
              id: 'opt_2',
              text: '참석 예정이나 회사 일정 조율 중 🤔',
              voterMemberIds: ['mem_4'],
            ),
            PollOption(
              id: 'opt_3',
              text: '아쉽지만 이번엔 불참합니다 ㅠㅠ 😢',
              voterMemberIds: [],
            ),
          ],
        ),
        comments: [
          Comment(
            id: 'c_1',
            memberId: 'mem_2',
            memberName: '참치퀸 🌸',
            memberEmoji: '🌸',
            content: '숙소 사진 봤는데 정말 너무 예뻐요! 바비큐 고기는 제가 최고급으로 준비해갈게요 🥩',
            createdAt: now.subtract(const Duration(hours: 2, minutes: 20)),
          ),
          Comment(
            id: 'c_2',
            memberId: 'mem_3',
            memberName: '서핑참치 🏄‍♂️',
            memberEmoji: '🏄‍♂️',
            content: '휴가 승인 났습니다! 이번 배낚시 대결에서는 제가 월척 1등 하겠습니다 ㅎㅎ 🎣',
            createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
          ),
        ],
        reactions: [
          Reaction(emoji: '🎉', memberIds: ['mem_1', 'mem_2', 'mem_3', 'mem_5']),
          Reaction(emoji: '❤️', memberIds: ['mem_1', 'mem_2', 'mem_4']),
          Reaction(emoji: '🐟', memberIds: ['mem_1', 'mem_3', 'mem_6']),
          Reaction(emoji: '👍', memberIds: ['mem_2', 'mem_3']),
        ],
      ),
      Notice(
        id: 'notice_2',
        title: '🚨 [긴급] 이번 주 토요일 가족 저녁식사 시간 및 장소 변경 안내',
        content: '''참치패밀리 구성원 여러분 긴급 공지합니다!

기존 토요일 18:00에 예약되어 있던 식당의 예약 누락으로 인해 인근의 더 넓고 쾌적한 룸식당으로 장소를 긴급 변경하였습니다.

⏰ [변경 일시]
• 이번 주 토요일 18:30 (기존보다 30분 늦춰졌습니다)

📍 [새 장소]
• 상호: 참치어가 본점 2층 VIP룸
• 주소: 서울 강남구 테헤란로 123
• 주차: 지하 주차장 2시간 무료 지원 (발렛 가능)

개별 룸으로 예약해 두었으니 편안하게 오시면 됩니다.
늦지 않게 도착 부탁드리며 확인하신 분은 바로 확인 버튼을 눌러주세요!''',
        authorId: 'mem_1',
        authorName: '참치대장 👑',
        authorEmoji: '👑',
        category: NoticeCategory.urgent,
        isPinned: true,
        views: 28,
        readMemberIds: ['mem_1', 'mem_2', 'mem_5'],
        createdAt: now.subtract(const Duration(hours: 8)),
        tags: ['긴급', '식사장소', '시간변경'],
        comments: [
          Comment(
            id: 'c_3',
            memberId: 'mem_5',
            memberName: '아기참치 🐣',
            memberEmoji: '🐣',
            content: '확인했습니다! 맛있는 거 많이 사주세요 아빠 ❤️',
            createdAt: now.subtract(const Duration(hours: 7)),
          ),
        ],
        reactions: [
          Reaction(emoji: '👍', memberIds: ['mem_1', 'mem_2', 'mem_5']),
          Reaction(emoji: '🐟', memberIds: ['mem_1', 'mem_5']),
        ],
      ),
      Notice(
        id: 'notice_3',
        title: '🧾 [정산] 지난 주말 가족 펜션 여행 정산 영수증 및 잔액 보고',
        content: '''지난 주말 가평 펜션 모임 총 정산 내역 및 영수증 결산 내역을 투명하게 공유합니다.

💰 [총 지출 내역]
1. 독채 펜션 숙박비: 450,000원
2. 하나로마트 장보기(한우, 삼겹살, 쌈채소, 음료, 주류): 294,000원
3. 차량 주유비 및 고속도로 통행료: 68,000원
4. 퇴실 후 브런치 베이커리 카페: 98,000원
--------------------------------------------------
• 총 사용 금액: 910,000원

📌 [회비 현황]
• 기존 가족 모임 통장 잔액: 2,150,000원
• 금번 지출액 차감: -910,000원
• 현재 최종 잔액: 1,240,000원

영수증 사진 원본은 가족 앨범 클라우드에 업로드 완료했습니다.
궁금하신 점이 있으시면 댓글 남겨주세요!''',
        authorId: 'mem_2',
        authorName: '참치퀸 🌸',
        authorEmoji: '🌸',
        category: NoticeCategory.accounting,
        isPinned: false,
        views: 42,
        readMemberIds: ['mem_1', 'mem_2', 'mem_3', 'mem_4', 'mem_6'],
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        tags: ['정산', '회비내역', '가평펜션'],
        comments: [
          Comment(
            id: 'c_4',
            memberId: 'mem_6',
            memberName: '삼촌참치 🐟',
            memberEmoji: '🐟',
            content: '엄마 늘 꼼꼼하게 정리해주셔서 감사합니다! 이번 여행 정말 재밌었어요~',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ],
        reactions: [
          Reaction(emoji: '👏', memberIds: ['mem_1', 'mem_3', 'mem_4', 'mem_6']),
          Reaction(emoji: '❤️', memberIds: ['mem_1', 'mem_2']),
        ],
      ),
      Notice(
        id: 'notice_4',
        title: '🎂 9월 막내참치 생일파티 축하 모임 & 저녁 메뉴 선호도 투표',
        content: '''참치패밀리의 귀염둥이 막내참치가 돌아오는 9월 생일을 맞이합니다! 🥳🎉

가족 모두 모여 생일 축하 노래도 부르고 즐거운 저녁식사를 함께하고자 합니다.
막내가 좋아하는 메뉴 중에서 다 같이 맛있게 먹을 메인 메뉴를 투표해 주세요!''',
        authorId: 'mem_3',
        authorName: '서핑참치 🏄‍♂️',
        authorEmoji: '🏄‍♂️',
        category: NoticeCategory.gathering,
        isPinned: false,
        views: 19,
        readMemberIds: ['mem_1', 'mem_3', 'mem_4', 'mem_5'],
        createdAt: now.subtract(const Duration(days: 2)),
        tags: ['생일파티', '막내참치', '축하', '투표'],
        poll: Poll(
          id: 'poll_2',
          question: '생일파티 메인 메뉴는 어떤 걸로 할까요? 🎂',
          options: [
            PollOption(
              id: 'opt_2_1',
              text: '특선 참치회 코스 요리 🍣',
              voterMemberIds: ['mem_1', 'mem_3'],
            ),
            PollOption(
              id: 'opt_2_2',
              text: '스테이크 & 화덕피자 이탈리안 🥩🍕',
              voterMemberIds: ['mem_4', 'mem_5'],
            ),
            PollOption(
              id: 'opt_2_3',
              text: '집에서 푸짐하게 배달 홈파티 🍗🍔',
              voterMemberIds: [],
            ),
          ],
        ),
        reactions: [
          Reaction(emoji: '🎂', memberIds: ['mem_1', 'mem_2', 'mem_3', 'mem_4', 'mem_5', 'mem_6']),
          Reaction(emoji: '🎉', memberIds: ['mem_3', 'mem_5']),
        ],
      ),
      Notice(
        id: 'notice_5',
        title: '💡 [참치꿀팁] 냉동 참치회 집에서 맛있게 해동하고 숙성하는 특급 비법',
        content: '''안녕하세요 참치대장입니다! 🐟

가족 모임 때 집에서 냉동 참치회를 더 맛있고 비린내 없이 드실 수 있는 전문가식 염수 해동법을 정리해 드립니다.

🌊 [염수 해동 3단계]
1. 미온수(약 35~40도) 1리터에 굵은 천일염 2~3스푼을 풀어 바닷물과 비슷한 농도로 만듭니다.
2. 냉동 참치 블록을 소금물에 넣고 겉면의 톱밥과 이물질을 살살 문질러 씻어낸 뒤 3~5분간 담가둡니다. (휘어질 정도가 되면 꺼냅니다)
3. 깨끗한 해동지(미트페이퍼)로 물기를 꼼꼼히 닦아낸 후, 새로운 해동지로 빈틈없이 감싸 냉장실에서 1~2시간 숙성시킵니다.

이렇게 숙성하면 참치 본연의 찰진 식감과 진한 풍미가 살아납니다!
다음에 집에서 다 같이 참치 파티할 때 꼭 써먹어 보세요! 👍''',
        authorId: 'mem_1',
        authorName: '참치대장 👑',
        authorEmoji: '👑',
        category: NoticeCategory.general,
        isPinned: false,
        views: 51,
        readMemberIds: ['mem_1', 'mem_2', 'mem_3', 'mem_4', 'mem_5', 'mem_6'],
        createdAt: now.subtract(const Duration(days: 3)),
        tags: ['참치상식', '요리꿀팁', '가족노하우'],
        reactions: [
          Reaction(emoji: '👍', memberIds: ['mem_2', 'mem_3', 'mem_6']),
          Reaction(emoji: '🐟', memberIds: ['mem_1', 'mem_3', 'mem_4', 'mem_5', 'mem_6']),
        ],
      ),
    ];
  }

  static List<NotificationItem> getNotifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 'notif_1',
        title: '새로운 중요 공지가 등록되었습니다',
        message: '🍁 2026 참치패밀리 가을 제주도 힐링 가족여행 일정 안내 및 참석 투표',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: false,
        noticeId: 'notice_1',
        type: 'new_notice',
      ),
      NotificationItem(
        id: 'notif_2',
        title: '긴급 공지가 업데이트되었습니다',
        message: '🚨 [긴급] 이번 주 토요일 가족 저녁식사 시간 및 장소 변경 안내',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: false,
        noticeId: 'notice_2',
        type: 'new_notice',
      ),
      NotificationItem(
        id: 'notif_3',
        title: '새로운 댓글이 달렸습니다',
        message: '참치퀸 🌸님이 제주도 여행 공지에 댓글을 남겼습니다.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
        isRead: true,
        noticeId: 'notice_1',
        type: 'comment',
      ),
      NotificationItem(
        id: 'notif_4',
        title: '투표 참여 요청',
        message: '막내참치 생일파티 메뉴 투표에 참여해 주세요!',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        noticeId: 'notice_4',
        type: 'poll',
      ),
    ];
  }
}
