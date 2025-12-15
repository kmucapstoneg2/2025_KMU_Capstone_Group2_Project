package com.outfit.ai.cloth_app.dto;

import com.outfit.ai.cloth_app.entity.MessageTable;

import java.time.OffsetDateTime;
import java.util.UUID;

// 쪽지 DTO
public class MessageDto {
    private Long messageId;
    private String sender;
    private UUID senderId;
    private String receiver;
    private UUID receiverId;
    private String content;
    private OffsetDateTime sentAt = OffsetDateTime.now();

    public MessageDto() {}

    public MessageDto(Long id, String sender, UUID senderId, String receiver, UUID receiverId, String content) {
        this.messageId = id;
        this.sender = sender;
        this.senderId = senderId;
        this.receiver = receiver;
        this.receiverId = receiverId;
        this.content = content;
        this.sentAt = OffsetDateTime.now();
    }

    /**
     * Entity를 DTO로 변환
     * MessageTable 엔티티에서 MessageDto 객체를 생성
     * @param message 변환할 메시지 엔티티
     * @return 변환된 MessageDto 객체
     */
    public static MessageDto fromEntity(MessageTable message) {
        MessageDto dto = new MessageDto();

        dto.setMessageId(message.getMessageId());
        dto.setContent(message.getContent());
        dto.setSentAt(message.getSentAt());

        // Sender 정보 설정 - null 체크 필수
        if(message.getSender() != null) {
            dto.setSender(message.getSender().getUsername());
            dto.setSenderId(message.getSender().getUserId());  // senderId 설정 추가
        }
        // Receiver 정보 설정 - null 체크 필수
        if(message.getReceiver() != null) {
            dto.setReceiver(message.getReceiver().getUsername());
            dto.setReceiverId(message.getReceiver().getUserId());  // receiverId 설정 추가
        }

        return dto;
    }

    public Long getMessageId() { return messageId; }
    public void setMessageId(Long id) { this.messageId = id; }

    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }

    public UUID getSenderId() { return senderId; }
    public void setSenderId(UUID senderId) { this.senderId = senderId; }

    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }

    public UUID getReceiverId() { return receiverId; }
    public void setReceiverId(UUID receiverId) { this.receiverId = receiverId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public OffsetDateTime getSentAt() { return sentAt; }
    public void setSentAt(OffsetDateTime sentAt) { this.sentAt = sentAt; }
}
