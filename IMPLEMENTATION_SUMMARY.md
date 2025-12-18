# 가상 피팅 및 코디 추천 구현 완료

## 개요
백엔드 API에 맞게 가상 피팅(Virtual Fitting)과 코디 추천(Outfit Recommendation) 기능을 완전히 구현했습니다. 홈 화면의 "코디 추천" 버튼을 누르면 코디 추천 페이지로 이동합니다.

---

## 📦 백엔드 수정사항

### 1. OutfitRecommendationService.java

#### 주요 변경:
- **`requestAndSaveRecommendation()` 메서드 개선**
  - 파라미터: `userId`, `userImageFile`, `clothIds` 추가
  - 반환 타입: `String` → `Mono<Map<String, Object>>`
  - 선택된 의류 ID를 `cloth_ids` 필드에 JSON 형태로 저장
  - 구조화된 응답 반환: `{ image_url, outfit_id, cloth_ids }`

- **`recommendBySchedule()` 메서드 추가** (새 기능)
  - 매개변수: `userId`, `location`, `tags`
  - 사용자 옷장에서 태그 기반 필터링
  - 최신 순 상위 6개 의류 추천
  - 응답: `{ recommended_items, reason }`

#### 클래스 변경:
```java
// 의존성 추가
private final ClothesRepository clothesRepository;

// 추가 메서드
private boolean matchesTags(ClothesTable cloth, List<String> tags)
private Map<String, Object> toClothMap(ClothesTable cloth)
```

---

### 2. OutfitRecommendationController.java

#### POST /api/v1/recommend/outfit (AI 이미지 생성)
```java
// 요청 형식 (Multipart Form-Data)
- image: 사용자 이미지 파일
- cloth_ids: ["uuid1", "uuid2", ...] (선택사항)

// 응답
{
  "success": true,
  "data": {
    "image_url": "...",
    "outfit_id": "...",
    "cloth_ids": ["uuid1", "uuid2"]
  }
}
```

#### POST /api/v1/outfits/recommend (일정 기반 추천)
```java
// 요청 (JSON)
{
  "date": "2025-12-16",
  "time": "14:00",
  "location": "한강공원",
  "tags": ["캐주얼", "봄"]
}

// 응답
{
  "success": true,
  "data": {
    "recommended_items": [
      { "cloth_id": "...", "name": "...", "image_url": "...", ... },
      ...
    ],
    "reason": "한강공원에서 열리는 일정과 어울리는 캐주얼 스타일 코디입니다."
  }
}
```

#### POST /api/v1/outfits/virtual-fitting (가상 피팅)
```java
// 요청 형식 (Multipart Form-Data)
- image: 사용자 이미지 파일
- cloth_ids: 선택 의류 ID 리스트

// 응답 (AI 생성 이미지)
{
  "success": true,
  "data": {
    "image_url": "...",
    "outfit_id": "...",
    "cloth_ids": [...]
  }
}
```

---

## 📱 Flutter UI 구현

### 1. 홈 화면 → 코디 추천 페이지
[home_page.dart](outfit_hub/lib/features/home/pages/home_page.dart)
```dart
// "코디 추천" 버튼 클릭 → OutfitResultPage로 이동
Navigator.push(
  context,
  CupertinoPageRoute(
    builder: (_) => const OutfitResultPage(),
  ),
);
```

### 2. 코디 추천 페이지 (OutfitResultPage)
[outfit_result_page.dart](outfit_hub/lib/features/outfit/pages/outfit_result_page.dart)

#### 주요 기능:
- **자동 데이터 수집**
  - 오늘의 일정 조회 (장소, 시간, 태그)
  - 현재 지역/사용자 지역 정보 사용
  - 기상청 API로 날씨 정보 조회

- **백엔드 API 호출**
  ```dart
  final recommendation = await RecommendationService.getOutfitRecommendation(
    date: todayKey,
    time: time,
    location: location,
    tags: tags,
    token: token,
  );
  ```

- **UI 표시**
  - 날씨 정보 (선택사항)
  - 추천 이유
  - 추천 의류 그리드 (2열)

### 3. 가상 피팅 페이지 (VirtualFittingPage)
[virtual_fitting_page.dart](outfit_hub/lib/features/virtual_fitting/pages/virtual_fitting_page.dart)

#### 주요 기능:
- **사용자 이미지 선택**
  - 갤러리에서 사진 선택 (`image_picker`)
  - 선택한 이미지 미리보기

- **의류 선택**
  - 옷장 의류 그리드에서 다중 선택
  - 선택된 의류 가로 스크롤로 표시

- **가상 피팅 생성**
  ```dart
  final imageUrl = await VirtualFittingLogic.generateFitting(
    selectedClothes,
    userImageFile: userImageFile,
    token: token,
  );
  ```

- **커뮤니티 공유**
  - 생성된 이미지 미리보기
  - 설명 추가 및 태그 자동 생성
  - 공유 후 선택 의류 자동 초기화

### 4. 서비스 레이어

#### RecommendationService
[recommendation_service.dart](outfit_hub/lib/core/services/recommendation_service.dart)
- `getOutfitRecommendation()` - 일정 기반 추천
- `generateVirtualFitting()` - 가상 피팅 생성 (Multipart)
- `uploadOutfitToCommunity()` - 커뮤니티 공유

#### 로직 레이어
- [outfit_result_page.dart](outfit_hub/lib/features/outfit/pages/outfit_result_page.dart) - 직접 호출
- [virtual_fitting_logic.dart](outfit_hub/lib/features/virtual_fitting/logic/virtual_fitting_logic.dart)
- [recommendation_logic.dart](outfit_hub/lib/features/calendar/logic/recommendation_logic.dart)

---

## 🔄 데이터 흐름

### 코디 추천 흐름
```
홈 화면 (코디 추천 버튼)
    ↓
OutfitResultPage 진입
    ↓
1. 오늘 일정 조회 (Storage)
2. 날씨 정보 조회 (WeatherService)
3. 백엔드 추천 API 호출 (RecommendationService)
    - POST /api/v1/outfits/recommend
    - Request: date, time, location, tags
    - Response: recommended_items[], reason
4. UI에 의류 그리드 표시
```

### 가상 피팅 흐름
```
가상 피팅 페이지 진입
    ↓
1. 사용자 이미지 선택 (image_picker)
2. 옷장에서 의류 다중 선택
3. "가상 피팅 시작" 버튼 클릭
    ↓
확인 다이얼로그 표시
    ↓
4. 백엔드 API 호출 (Multipart)
    - POST /api/v1/outfits/virtual-fitting
    - body: image (사용자 사진)
    - body: cloth_ids (선택 의류)
5. 생성된 이미지 표시
    ↓
6. 커뮤니티 공유 (선택)
    - POST /api/v1/outfits/share
    - Description + Tags 전송
7. 완료 후 UI 초기화
```

---

## 🔐 인증 처리

모든 API 호출에서 자동으로 JWT 토큰을 포함합니다:

```dart
final authProvider = context.read<AuthProvider>();
await authProvider.checkAndHandleToken(); // 토큰 만료 확인 및 갱신
final token = authProvider.accessToken;

// 모든 RecommendationService 메서드에 token 전달
final response = await RecommendationService.getOutfitRecommendation(
  ...,
  token: token,
);
```

---

## 📝 주요 수정 사항 요약

### 백엔드
1. ✅ `OutfitRecommendationService` 리팩토링
   - 구조화된 응답 반환
   - Cloth ID 저장 기능
   - 일정 기반 추천 로직 추가

2. ✅ `OutfitRecommendationController` 업데이트
   - Multipart 파일 업로드 지원
   - 토큰 기반 인증 적용
   - 일정 기반 추천 엔드포인트 구현

### Flutter
1. ✅ 홈 화면 - 코디 추천 네비게이션 구현
2. ✅ `OutfitResultPage` - 자동 추천 로직
3. ✅ `VirtualFittingPage` - 사진 선택 및 가상 피팅
4. ✅ `RecommendationService` - 백엔드 API 통합
5. ✅ 이미지 렌더링 - 네트워크/로컬 파일 지원

---

## 🧪 테스트 방법

### 1. 코디 추천 테스트
1. 홈 화면 → "코디 추천" 버튼 클릭
2. OutfitResultPage 로드 확인
3. 추천 의류 목록 표시 확인

### 2. 가상 피팅 테스트
1. 홈 화면 → "가상 피팅" 버튼 클릭
2. 갤러리에서 사진 선택
3. 옷장 의류 다중 선택
4. "가상 피팅 시작" → AI 생성 이미지 확인
5. "커뮤니티에 공유" → 완료

---

## 🚀 다음 단계

### 추가 개선 사항
- [ ] 특정 일정을 선택하여 추천 (현재는 오늘만)
- [ ] 추천 이유 텍스트 기반으로 확장
- [ ] 가상 피팅 히스토리 관리
- [ ] 선호 스타일 학습 알고리즘
- [ ] 날씨 기반 필터링 강화

---

## 📞 API 문서

### 인증 헤더
```
Authorization: Bearer {access_token}
Content-Type: application/json (JSON) / multipart/form-data (파일)
```

### 엔드포인트 목록
| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/api/v1/recommend/outfit` | AI 코디 추천 |
| POST | `/api/v1/outfits/recommend` | 일정 기반 코디 추천 |
| POST | `/api/v1/outfits/virtual-fitting` | 가상 피팅 생성 |
| POST | `/api/v1/outfits/share` | 커뮤니티 공유 |

---

**구현 완료일**: 2025년 12월 16일
**상태**: ✅ 완료 및 테스트 준비
