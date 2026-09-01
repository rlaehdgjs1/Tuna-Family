# 🐟 참치패밀리 (Tuna Family)

> **'참치패밀리' 구성원들을 위한 맞춤형 가족 공지 및 일정 소통 애플리케이션** 📱✨  
> Flutter 기반으로 제작되어 Web, Mobile, Desktop 어디서나 동작합니다.

---

## 🌟 주요 기능 (Key Features)

### 1. 📋 스마트 공지사항 보드 & 피드
- **📌 중요 필독 공지 상단 고정 (Pinned Banner)**: 가족 여행, 긴급 일정 등 꼭 확인해야 하는 공지 상단 노출
- **🏷️ 카테고리별 탭 필터링**: `전체`, `공지` 📢
- **📸 미디어 첨부**: 사진 업로드(갤러리/URL) & 동영상 링크(YouTube) 지원
- **🔔 실시간 시스템 푸시 알림**: 공지 작성 시 기기 상단 알림 배너 & 소리/진동 발송

### 2. 📩 공지 수신 확인 ('확인했어요') & 상호작용
- **가족 확인율 실시간 통계**: 공지를 읽은 가족 멤버 목록과 확인율(%) 시각화
- **🗳️ 일정 참석 & 메뉴 투표 (`PollWidget`)**: 가족 여행 참석 여부, 식사 메뉴 선택 등 투표 참여
- **❤️ 다채로운 이모지 리액션 (`ReactionBar`)**: 🐟, ❤️, 👍, 🎉, 👏, 🎂 반응
- **💬 가족 댓글**: 공지별 따뜻한 댓글 소통

### 3. 👥 가족 구성원 관리 (CRUD)
- **➕ 새 가족 구성원 등록**: 16종 캐릭터 이모지, 8종 테마 색상, 닉네임, 역할 설정
- **✏️ 가족 정보 수정**: 언제든 닉네임, 역할, 이모지, 테마 색상 변경
- **🗑️ 가족 삭제**: 안전한 확인 팝업 및 자동 프로필 승계
- **🔄 원클릭 프로필 전환**: 다른 가족 시점에서 공지 확인 및 소통 테스트 가능

### 4. 🎵 배경음악 플레이어 & 음악 파일 선택
- **앱 실행 시 BGM 자동 재생**: 어플 접속 시 편안한 배경음악 재생 (항상 이전 선택 곡 유지 / 랜덤 재생)
- **📁 내 음악 파일 선택하기**: 기기에 저장된 MP3, WAV, OGG, M4A 파일 직접 추가 및 재생
- **추천 BGM 프리셋 탑재**: 바다의 멜로디 🌊, 따뜻한 가족 카페 ☕
- **하단 미니 플레이어 바 & 볼륨 조절**

---

## 🛠️ 기술 스택 (Tech Stack)

- **Framework**: Flutter (Dart 3.x)
- **State Management**: `provider`
- **Local Storage**: `shared_preferences`
- **Audio & Media**: `audioplayers`, `file_picker`
- **Styling**: Material 3 Design (Ocean Blue & Coral Palette)

---

## 🚀 실행 방법 (Getting Started)

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 실행
```bash
# Chrome 웹 브라우저로 실행
flutter run -d chrome

# Windows 데스크톱 앱으로 실행
flutter run -d windows
```

### 3. 테스트
```bash
flutter test
```

---

## 📄 라이선스
MIT License
