package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.UUID;

// 캘린더 테이블
@Entity
@Table(name="user_calendar")
public class UserCalendar {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID eventId;

    @Column(name = "google_event_id", nullable = false, unique = true)
    private String googleEventId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserTable userTable;

    @Column(name = "start_time", nullable = false, columnDefinition = "timestamptz")
    private OffsetDateTime startTime;

    @Column(name = "end_time", nullable = false, columnDefinition = "timestamptz")
    private OffsetDateTime endTime;

    @Column(name = "event_summary", nullable = false, length = 255)
    private String eventSummary;

    @Column(name = "dress_code_tag", length = 255)
    private String dressCodeTag;

    @Column(name = "location", length = 255)
    private String location;

    @Column(name = "json_data", columnDefinition = "jsonb")
    private String jsonData;

    @Column(name = "is_all_day", columnDefinition = "boolean default false")
    private Boolean isAllDay;

    @Column(name = "created_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime createdAt;

    public UUID getEventId() { return eventId; }
    public void setEventId(UUID eventId) { this.eventId = eventId; }

    public String getGoogleEventId() { return googleEventId; }
    public void setGoogleEventId(String googleEventId) { this.googleEventId = googleEventId; }

    public UserTable getUserTable() { return userTable; }
    public void setUserTable(UserTable userTable) { this.userTable = userTable; }

    public OffsetDateTime getStartTime() { return startTime; }
    public void setStartTime(OffsetDateTime startTime) { this.startTime = startTime; }

    public OffsetDateTime getEndTime() { return endTime; }
    public void setEndTime(OffsetDateTime endTime) { this.endTime = endTime; }

    public String getEventSummary() { return eventSummary; }
    public void setEventSummary(String eventSummary) { this.eventSummary = eventSummary; }

    public String getDressCodeTag() { return dressCodeTag; }
    public void setDressCodeTag(String dressCodeTag) { this.dressCodeTag = dressCodeTag; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getJsonData() { return jsonData; }
    public void setJsonData(String jsonData) { this.jsonData = jsonData; }

    public Boolean getAllDay() { return isAllDay; }
    public void setIsAllDay(Boolean allDay) { isAllDay = allDay; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

}
