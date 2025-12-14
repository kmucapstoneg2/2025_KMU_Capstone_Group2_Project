package com.outfit.ai.cloth_app.dto;

import java.time.OffsetDateTime;

public class NotificationDto {
    private String type;       // COMMENT, MESSAGE 등
    private String content;
    private String senderId;
    private String targetId;
    private OffsetDateTime timestamp;

    // 생성자, getter/setter
    public NotificationDto() {}

    public NotificationDto(String type, String content, String senderId, String targetId) {
        this.type = type;
        this.content = content;
        this.senderId = senderId;
        this.targetId = targetId;
        this.timestamp = OffsetDateTime.now();
    }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }

    public String getTargetId() { return targetId; }
    public void setTargetId(String targetId) { this.targetId = targetId; }

    public OffsetDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(OffsetDateTime timestamp) { this.timestamp = timestamp; }
}