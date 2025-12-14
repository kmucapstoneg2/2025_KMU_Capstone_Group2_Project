#!/bin/bash

# ===========================================
# 개발 환경 통합 실행 스크립트
# 백엔드 서버 + Flutter 앱 동시 실행
# ===========================================

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FLUTTER_DIR="$PROJECT_ROOT/outfit_hub"
SERVER_PID_FILE="$PROJECT_ROOT/.server.pid"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 서버 종료 함수
cleanup() {
    echo -e "\n${YELLOW}🛑 종료 중...${NC}"
    
    if [ -f "$SERVER_PID_FILE" ]; then
        SERVER_PID=$(cat "$SERVER_PID_FILE")
        if ps -p $SERVER_PID > /dev/null 2>&1; then
            echo -e "${YELLOW}백엔드 서버 종료 중... (PID: $SERVER_PID)${NC}"
            kill $SERVER_PID 2>/dev/null
            # gradle 관련 프로세스도 종료
            pkill -f "gradle.*bootRun" 2>/dev/null
            sleep 2
            # 강제 종료
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                kill -9 $SERVER_PID 2>/dev/null
            fi
        fi
        rm -f "$SERVER_PID_FILE"
    fi
    
    # 8080 포트 사용 프로세스 종료
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    
    echo -e "${GREEN}✅ 모든 프로세스가 종료되었습니다.${NC}"
    exit 0
}

# Ctrl+C 시그널 처리
trap cleanup SIGINT SIGTERM

# 메인 함수
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   Outfit Hub 개발 환경 실행${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # 1. 기존 서버 프로세스 정리
    echo -e "${YELLOW}🧹 기존 프로세스 정리 중...${NC}"
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    pkill -f "gradle.*bootRun" 2>/dev/null
    sleep 1

    # 2. 백엔드 서버 시작
    echo -e "${GREEN}🚀 백엔드 서버 시작 중...${NC}"
    cd "$BACKEND_DIR"
    
    if [ ! -f ".env" ]; then
        echo -e "${RED}❌ 오류: backend/.env 파일이 없습니다.${NC}"
        exit 1
    fi
    
    # 환경변수 로드 후 백그라운드에서 서버 실행
    (
        export $(grep -v '^#' .env | xargs)
        ./gradlew bootRun > /dev/null 2>&1
    ) &
    
    SERVER_PID=$!
    echo $SERVER_PID > "$SERVER_PID_FILE"
    
    # 서버 시작 대기
    echo -e "${YELLOW}⏳ 서버 시작 대기 중...${NC}"
    MAX_WAIT=60
    WAITED=0
    while [ $WAITED -lt $MAX_WAIT ]; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 백엔드 서버 시작 완료! (http://localhost:8080)${NC}"
            break
        fi
        sleep 2
        WAITED=$((WAITED + 2))
        echo -ne "${YELLOW}.${NC}"
    done
    echo ""
    
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo -e "${RED}❌ 서버 시작 시간 초과. 로그를 확인하세요.${NC}"
        cleanup
        exit 1
    fi

    # 3. Flutter 앱 실행
    echo -e "${GREEN}📱 Flutter 앱 실행 중...${NC}"
    cd "$FLUTTER_DIR"
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}🎉 개발 환경 준비 완료!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "  백엔드 API: ${GREEN}http://localhost:8080/api/v1${NC}"
    echo -e "  종료하려면: ${YELLOW}Ctrl+C${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Flutter 앱 실행 (foreground)
    flutter run
    
    # Flutter 종료 시 서버도 종료
    cleanup
}

# 스크립트 실행
main "$@"
