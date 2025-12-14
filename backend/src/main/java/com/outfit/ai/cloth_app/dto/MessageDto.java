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

    public static MessageDto fromEntity(MessageTable message) {
        MessageDto dto = new MessageDto();

        dto.setMessageId(message.getMessageId());
        dto.setContent(message.getContent());
        dto.setSentAt(message.getSentAt());

        if(message.getSender() != null) {
            dto.setSender(message.getSender().getUsername());
        }
        if(message.getReceiver() != null) {
            dto.setReceiver(message.getReceiver().getUsername());
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
