package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.dto.NotificationDto;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * NoticeService
 * - 서버에서 특정 유저에게 1:1 알림을 보낼 때 사용하는 서비스
 * - STOMP & Spring 표준 (convertAndSendToUser) 사용
 *
 * NOTE:
 * - 클라이언트는 "/user/queue/notice"를 구독해야 알림을 받습니다.
 * - targetUserId는 Long으로 사용하고 내부에서 toString()으로 변환합니다.
 */
@Service
@RequiredArgsConstructor
public class NoticeService {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 댓글 알림 전송
     * 경로: /user/{targetUserId}/queue/notice
     */
    public void sendCommentNotice(UUID targetUserId, NotificationDto notification) {
        // Spring은 userDestinationPrefix("/user") + destination => "/user/{id}/queue/notice"
        messagingTemplate.convertAndSendToUser(
                targetUserId.toString(),
                "/queue/notice",
                notification
        );
    }

    /**
     * 쪽지 알림 전송
     */
    public void sendMessageNotice(UUID targetUserId, NotificationDto notification) {
        messagingTemplate.convertAndSendToUser(
                targetUserId.toString(),
                "/queue/notice",
                notification
        );
    }

    // 추가 알림 타입이 필요하면 여기 메서드 추가
}
