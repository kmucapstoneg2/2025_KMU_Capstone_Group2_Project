package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;

// 쪽지 메시지 테이블
@Entity
@Table(name="message_table")
public class MessageTable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long messageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id", nullable = false)
    private UserTable sender;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_id", nullable = false)
    private UserTable receiver;

    @Column(nullable = false, length = 255)
    private String content;

    @Column(name = "send_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime sentAt;

    @Column(name = "is_read")
    private boolean isRead = false;

    public MessageTable() {}

    public MessageTable(UserTable sender, UserTable receiver, String content) {
        this.sender = sender;
        this.receiver = receiver;
        this.content = content;
        this.sentAt = OffsetDateTime.now(); // 생성 시각을 여기서 설정
        this.isRead = false;
    }

    public long getMessageId() { return messageId; }
    public void setMessageId(long messageId) { this.messageId = messageId; }

    public UserTable getSender() { return sender; }
    public void setSender(UserTable sender) { this.sender = sender; }

    public UserTable getReceiver() { return receiver; }
    public void setReceiver(UserTable receiver) { this.receiver = receiver; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public OffsetDateTime getSentAt() { return sentAt; }
    public void setSentAt(OffsetDateTime sentAt) { this.sentAt = sentAt; }

    public boolean getIsRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }
}
