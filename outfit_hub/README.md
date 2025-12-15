# Outfit Hub - Flutter 앱

AI 기반 옷 코디 추천 앱의 Flutter 클라이언트입니다.

## 기술 스택

- **Framework**: Flutter 3.x
- **상태관리**: Provider
- **로컬 DB**: SQLite (sqflite)
- **HTTP 통신**: http 패키지
- **인증**: JWT 토큰 + SharedPreferences

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── app.dart                  # MyApp + Provider 설정
├── main_tab_view.dart        # 메인 탭 네비게이션
├── core/                     # 공통 기능
│   ├── constants/           # 상수 정의
│   ├── error/               # 예외 처리
│   ├── services/            # API 서비스
│   │   ├── api_service.dart      # HTTP 통신 기본
│   │   ├── auth_service.dart     # 인증 API
│   │   ├── clothes_service.dart  # 옷장 API
│   │   └── weather_service.dart  # 날씨 API
│   ├── theme/               # 앱 테마
│   ├── utils/               # 유틸리티
│   └── widgets/             # 공통 위젯
├── data/                     # 데이터 레이어
│   ├── local_db/            # SQLite 로컬 DB
│   └── storage.dart         # 스토리지 추상화
├── features/                 # 기능별 화면
│   ├── auth/                # 로그인/회원가입
│   ├── calendar/            # 캘린더
│   ├── closet/              # 옷장
│   ├── community/           # 커뮤니티
│   ├── coordi/              # 코디
│   ├── home/                # 홈
│   ├── my_page/             # 마이페이지
│   └── virtual_fitting/     # 가상 피팅
└── providers/                # 상태 관리
    ├── auth_provider.dart   # 인증 상태
    ├── closet_provider.dart # 옷장 상태
    ├── outfit_provider.dart # 코디 상태
    └── ...
```

## 주요 기능

### 1. 인증 (AuthProvider)
- 이메일/비밀번호 로그인
- JWT 토큰 관리 (자동 갱신)
- 게스트 모드 지원

### 2. 옷장 (ClosetProvider)
- 옷 등록 (사진 촬영/갤러리)
- 카테고리별 분류
- 로컬 DB + 백엔드 동기화

### 3. 코디 (OutfitProvider)
- AI 코디 추천
- 코디 저장/삭제
- 커뮤니티 공유

### 4. 커뮤니티 (CommunityProvider)
- 게시글 CRUD
- 댓글/좋아요
- 실시간 알림

## 백엔드 연동

### API 서버 설정

`lib/core/services/api_service.dart`에서 서버 URL 설정:

```dart
// 개발 환경별 URL
// iOS 시뮬레이터: localhost
// Android 에뮬레이터: 10.0.2.2
// 실제 기기: 서버 IP 또는 도메인
static const String baseUrl = 'http://localhost:8080/api/v1';
```

### 인증 헤더
모든 인증 필요 API에는 JWT 토큰이 자동 추가됩니다:
```
Authorization: Bearer {access_token}
```

## 실행 방법

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. iOS 설정 (Mac에서)

```bash
cd ios
pod install
cd ..
```

### 3. 실행

```bash
# iOS 시뮬레이터
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 디버그 모드
flutter run --debug
```

## 주요 수정 사항 (2025-12-15)

### 버그 수정
1. `ClothesItem` - 중복 생성자 파라미터 제거 (`itemTypeName` 중복)
2. `ClosetProvider` - `init()` 메서드에서 토큰 없이 호출하는 문제 수정
   - `loadLocalClothes()` 메서드 추가 (로컬 DB만 로드)
   - `loadClothes(token)` 메서드는 토큰 필수로 변경

### 문서화
- 모든 서비스 클래스에 상세 주석 추가
- API 사용 예시 추가

## 참고

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Provider 패키지](https://pub.dev/packages/provider)
- 백엔드 README: `../backend/README.md`
