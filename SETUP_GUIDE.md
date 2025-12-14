# Outfit Hub - 개발 환경 설정 및 실행 가이드

## ✅ 테스트 완료 항목

### 백엔드 서버 (Spring Boot)
- ✅ Java 25 환경에서 정상 실행
- ✅ PostgreSQL 연결 성공 (EC2 원격 DB)
- ✅ 포트: 8080

### API 엔드포인트 테스트
#### 회원가입 (POST /api/v1/auth/signup)
```bash
✅ HTTP 200 OK
요청 예시:
{
  "email": "test@example.com",
  "password": "test1234",
  "username": "testuser",
  "region": "서울"
}
```

#### 로그인 (POST /api/v1/auth/login)
```bash
✅ HTTP 200 OK
응답 예시:
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "eyJhbGci...",
  "userId": "826265de-2318-441e-b663-e5a96feb4a87",
  "username": "FlutterTest"
}
```

### Flutter 앱
- ✅ iOS 시뮬레이터 빌드 성공
- ✅ 앱 실행 성공
- ✅ API 연동 코드 구현 완료

## 🚀 실행 방법

### 방법 1: 통합 스크립트 사용 (권장)
```bash
cd /Users/yoleggk/dev/Git/2025_KMU_Capstone_Group2_Project
./run-dev.sh
```

**기능:**
- 백엔드 서버 자동 시작
- Flutter 앱 자동 실행
- Ctrl+C로 한 번에 종료

### 방법 2: 수동 실행

#### 1단계: 백엔드 서버 실행
```bash
cd backend
./start-server.sh
```
또는
```bash
cd backend
export $(grep -v '^#' .env | xargs)
./gradlew bootRun
```

#### 2단계: Flutter 앱 실행
```bash
cd outfit_hub
flutter run
```

## 📱 앱에서 테스트하기

### 1. 회원가입 테스트
1. 앱 실행 시 로그인 화면 표시
2. "회원가입" 버튼 클릭
3. 정보 입력:
   - 사용자명: 테스트용 이름
   - 이메일: test@example.com
   - 비밀번호: test1234 (6자 이상)
   - 지역: 서울 선택
4. "회원가입" 버튼 클릭
5. ✅ 성공 메시지 확인 → 로그인 화면으로 이동

### 2. 로그인 테스트
1. 회원가입한 계정으로 로그인
   - 이메일: test@example.com
   - 비밀번호: test1234
2. "로그인" 버튼 클릭
3. ✅ 메인 화면으로 이동

### 3. 게스트 로그인 테스트
1. 로그인 화면에서 "게스트로 시작하기" 버튼 클릭
2. ✅ 메인 화면으로 즉시 이동
3. 마이페이지 → "로그인 / 회원가입" 버튼으로 정식 로그인 가능

### 4. 로그아웃 테스트
1. 마이페이지 이동
2. "로그아웃" 버튼 클릭
3. 확인 다이얼로그에서 "로그아웃" 선택
4. ✅ 로그인 화면으로 이동

## 🔧 문제 해결

### 서버 연결 오류
```
"서버에 연결할 수 없습니다"
```

**해결 방법:**
1. 백엔드 서버가 실행 중인지 확인:
   ```bash
   curl http://localhost:8080
   ```
2. 8080 포트가 사용 중인지 확인:
   ```bash
   lsof -ti:8080
   ```
3. 기존 프로세스 종료 후 재시작:
   ```bash
   lsof -ti:8080 | xargs kill -9
   cd backend && ./start-server.sh
   ```

### 빌드 오류
```bash
# 캐시 정리 후 재빌드
cd outfit_hub
flutter clean
flutter pub get
flutter build ios --simulator
```

### 환경변수 오류
```bash
# .env 파일 확인
cd backend
cat .env

# 필수 환경변수:
# - DB_URL
# - DB_USERNAME
# - DB_PASSWORD
# - JWT_SECRET_KEY
```

## 📁 프로젝트 구조

```
2025_KMU_Capstone_Group2_Project/
├── run-dev.sh              # 통합 실행 스크립트
├── backend/                # Spring Boot 백엔드
│   ├── .env               # 환경변수 (DB, JWT 등)
│   ├── start-server.sh    # 서버 시작 스크립트
│   └── build.gradle       # Java 25 설정
└── outfit_hub/            # Flutter 앱
    ├── lib/
    │   ├── core/
    │   │   └── services/
    │   │       ├── api_service.dart      # HTTP 클라이언트
    │   │       └── auth_service.dart     # 인증 API
    │   ├── providers/
    │   │   └── auth_provider.dart        # 인증 상태 관리
    │   └── features/
    │       └── auth/
    │           └── pages/
    │               ├── login_page.dart   # 로그인 화면
    │               └── signup_page.dart  # 회원가입 화면
    └── pubspec.yaml
```

## 🌐 API 명세

### Base URL
```
http://localhost:8080/api/v1
```

### 엔드포인트

#### 1. 회원가입
```http
POST /auth/signup
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "password123",
  "username": "홍길동",
  "region": "서울"  // optional
}

Response: 200 OK
```

#### 2. 로그인
```http
POST /auth/login
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "eyJhbGci...",
  "userId": "uuid-string",
  "username": "홍길동"
}
```

## 📝 개발 노트

### 완료된 기능
- ✅ 백엔드 서버 환경 구성
- ✅ Flutter 앱 기본 구조
- ✅ 회원가입/로그인 API 연동
- ✅ 게스트 로그인 기능
- ✅ JWT 토큰 기반 인증
- ✅ SharedPreferences 로컬 저장
- ✅ AuthWrapper를 통한 자동 화면 전환

### 다음 단계
- [ ] 프로필 이미지 업로드
- [ ] 비밀번호 찾기
- [ ] 소셜 로그인 (Google OAuth)
- [ ] 리프레시 토큰 갱신 로직

## 🐛 알려진 이슈

없음 - 모든 테스트 통과 ✅

## 📞 문의

문제가 발생하거나 질문이 있으시면 팀 리더에게 연락해주세요.
