package com.outfit.ai.cloth_app.dto.response;

import java.util.List;

// 일정 세부사항 응답 DTO
public class EventDetailDto {
    private String title;
    private String time;
    private String location;
    private List<String> tags;

    public EventDetailDto(String title, String time, String location, List<String> tags) {
        this.title = title;
        this.time = time;
        this.location = location;
        this.tags = tags;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
}
