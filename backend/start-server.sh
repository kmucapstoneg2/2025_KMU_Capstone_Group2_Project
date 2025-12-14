#!/bin/bash

# 백엔드 서버 실행 스크립트
# Backend Server Start Script

# 현재 디렉토리를 스크립트가 있는 위치로 변경
cd "$(dirname "$0")"

# .env 파일에서 환경변수 로드
if [ -f .env ]; then
    echo "환경변수 로드 중..."
    export $(grep -v '^#' .env | xargs)
    echo "환경변수 로드 완료!"
else
    echo "오류: .env 파일을 찾을 수 없습니다."
    exit 1
fi

# 서버 실행
echo "Spring Boot 서버 시작 중..."
echo "서버 URL: http://localhost:8080"
echo "API 기본 URL: http://localhost:8080/api/v1"
echo ""
echo "서버를 중지하려면 Ctrl+C를 누르세요."
echo ""

./gradlew bootRun
