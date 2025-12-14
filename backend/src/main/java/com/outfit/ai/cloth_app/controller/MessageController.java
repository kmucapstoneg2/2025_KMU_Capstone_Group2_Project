package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.dto.MessageDto;
import com.outfit.ai.cloth_app.dto.NotificationDto; // NotificationDto 필요
import com.outfit.ai.cloth_app.service.MessageService;
import com.outfit.ai.cloth_app.service.NoticeService; // NoticeService 주입
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

// 쪽지 컨트롤러
@RestController
@RequestMapping("/messages")
public class MessageController {
    private final MessageService messageService;
    private final NoticeService noticeService; // NoticeService 필드 추가

    // 생성자 주입
    public MessageController(MessageService messageService, NoticeService noticeService) {
        this.messageService = messageService;
        this.noticeService = noticeService;
    }

    private UUID getAuthenticatedUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            // 인증되지 않은 요청에 대한 HTTP 401 Unauthorized 에러를 발생시키는 것이 일반적입니다.
            throw new RuntimeException("인증 정보가 없습니다.");
        }

        // UUID.fromString() 전에 null 체크를 추가하는 것이 안전합니다.
        String userIdStr = authentication.getName();
        if (userIdStr == null) {
            throw new RuntimeException("인증된 사용자 ID가 유효하지 않습니다.");
        }
        return UUID.fromString(userIdStr);
    }

    // 메시지 보내기
    @PostMapping
    public ResponseEntity<MessageDto> sendMessage(@RequestBody MessageDto message) {
        UUID senderId = getAuthenticatedUserId();

        // 1. 메시지 저장 및 전송 로직 수행 (MessageService 내부에서 처리)
        MessageDto sentMessage = messageService.sendMessage(senderId, message);

        // 2. 메시지 수신자에게 실시간 알림 전송 (NoticeService 사용)
        // DTO를 생성하여 NoticeService에 전달합니다.
        UUID receiverId = sentMessage.getReceiverId();

        // content는 메시지 내용을 50자 이내로 요약
        String briefContent = sentMessage.getContent().substring(0, Math.min(sentMessage.getContent().length(), 50)) + "...";

        // 알림 DTO 생성 (예시)
        NotificationDto notification = new NotificationDto(
                "MESSAGE",
                briefContent,
                senderId.toString(),
                receiverId.toString()
        );

        // NoticeService의 sendMessageNotice 호출
        noticeService.sendMessageNotice(receiverId, notification);

        return ResponseEntity.ok(sentMessage);
    }

    // 쪽지함 보기
    @GetMapping("/inbox")
    public ResponseEntity<List<MessageDto>> getInbox() {
        UUID receiverId = getAuthenticatedUserId();
        List<MessageDto> inbox = messageService.getInbox(receiverId);
        return ResponseEntity.ok(inbox);
    }

    // 보낸 메시지
    @GetMapping("/sent")
    public ResponseEntity<List<MessageDto>> getSent() {
        UUID senderId = getAuthenticatedUserId();
        List<MessageDto> sent = messageService.getSent(senderId);
        return ResponseEntity.ok(sent);
    }
}