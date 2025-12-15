# Outfit Hub Backend

Spring Boot 기반의 백엔드 서버입니다.

## 기술 스택

- **Framework**: Spring Boot 3.x
- **Security**: Spring Security + JWT
- **Database**: PostgreSQL (JPA/Hibernate)
- **Storage**: AWS S3 (이미지 저장)
- **Build Tool**: Gradle

## 프로젝트 구조

```
src/main/java/com/outfit/ai/cloth_app/
├── ClothAppApplication.java     # Spring Boot 메인 클래스
├── api/
│   └── weather_api/             # 기상청 API 연동
├── config/
│   ├── S3Config.java           # AWS S3 설정
│   ├── SecurityConfig.java     # Spring Security 설정
│   └── WebSocketConfig.java    # WebSocket 설정
├── controller/                  # REST API 컨트롤러
│   ├── AuthController.java     # 인증 (회원가입/로그인)
│   ├── ClothesController.java  # 옷 등록/조회
│   ├── CommunityController.java # 커뮤니티 (게시글/댓글)
│   ├── HomeController.java     # 홈 (최근 코디)
│   ├── MessageController.java  # 쪽지
│   ├── MyPageController.java   # 마이페이지
│   └── OutfitRecommendationController.java # AI 코디 추천
├── dto/                        # 데이터 전송 객체
│   ├── request/               # 요청 DTO
│   └── response/              # 응답 DTO
├── entity/                     # JPA 엔티티 (DB 테이블)
├── exception/                  # 커스텀 예외
├── repository/                 # JPA 리포지토리
├── security/                   # JWT 인증
│   ├── JwtAuthenticationFilter.java
│   └── JwtTokenProvider.java
└── service/                    # 비즈니스 로직
```

## API 엔드포인트

### 인증 (공개 API)

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/auth/signup` | 회원가입 |
| POST | `/api/v1/auth/login` | 로그인 (JWT 토큰 발급) |

### 옷장 (인증 필요)

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/wardrobe/clothes` | 옷 등록 (Multipart) |
| GET | `/api/v1/wardrobe/clothes` | 옷 목록 조회 |

### 커뮤니티 (인증 필요)

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/api/v1/community/posts` | 게시글 목록 |
| POST | `/api/v1/community/posts` | 게시글 작성 |
| POST | `/api/v1/community/posts/{postId}/comments` | 댓글 작성 |
| POST | `/api/v1/community/posts/{postId}/like` | 좋아요 |

### 코디 추천 (인증 필요)

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/recommend/outfit` | AI 코디 추천 요청 |
| GET | `/api/v1/home/recent` | 최근 코디 조회 |

### 날씨 (공개 API)

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/weather` | 날씨 정보 조회 |

## 인증 방식

JWT (JSON Web Token) 기반 인증을 사용합니다.

```
Authorization: Bearer {access_token}
```

### 토큰 구성
- **Access Token**: API 요청 인증용 (만료: 1시간)
- **Refresh Token**: 액세스 토큰 갱신용 (만료: 7일)

## 실행 방법

### 1. 환경 설정

`application.properties` 파일에서 다음 설정을 확인/수정하세요:

```properties
# 데이터베이스
spring.datasource.url=jdbc:postgresql://localhost:5432/outfit_db
spring.datasource.username=your_username
spring.datasource.password=your_password

# JWT
jwt.secret=your_jwt_secret_key

# AWS S3
aws.accessKeyId=your_access_key
aws.secretAccessKey=your_secret_key
aws.s3.bucket=your_bucket_name
```

### 2. 빌드 및 실행

```bash
# Gradle 빌드
./gradlew build

# 실행
./gradlew bootRun

# 또는 JAR 파일 직접 실행
java -jar build/libs/cloth_app-0.0.1-SNAPSHOT.jar
```

### 3. Docker 실행 (선택)

```bash
docker-compose up -d
```

## 주요 수정 사항 (2025-12-15)

### 버그 수정
1. `OutfitService` - private 생성자 → public으로 수정 (Spring Bean 생성 오류)
2. `JwtAuthenticationFilter` - Bearer 토큰 파싱 시 공백 처리 추가
3. `OutfitRecommendationController` - 파라미터 오타 수정 (`imaage` → `image`)
4. `MessageDto.fromEntity()` - senderId, receiverId 설정 누락 수정
5. `CommunityInteractions` - `unique=true` 제약조건 제거 (여러 댓글/좋아요 허용)
6. `MessageController` - null 체크 추가 (NullPointerException 방지)

## Flutter 연동

Flutter 앱에서는 다음 서비스 파일들을 통해 이 백엔드와 통신합니다:

- `lib/core/services/api_service.dart` - HTTP 통신 기본
- `lib/core/services/auth_service.dart` - 인증 관련
- `lib/core/services/clothes_service.dart` - 옷장 관련

```dart
// 사용 예시
final response = await ApiService.post('/auth/login', {
  'email': 'user@example.com',
  'password': 'password123',
});
```
