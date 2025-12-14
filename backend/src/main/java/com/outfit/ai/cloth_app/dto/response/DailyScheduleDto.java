package com.outfit.ai.cloth_app.dto.response;

import java.time.LocalDate;
import java.util.List;

// 스케쥴 응답 DTO
public class DailyScheduleDto {
    private LocalDate date;
    private String formattedDate;
    private List<EventDetailDto> events;

    public DailyScheduleDto(LocalDate date, String formattedDate, List<EventDetailDto> events) {
        this.date = date;
        this.formattedDate = formattedDate;
        this.events = events;
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public String getFormattedDate() { return formattedDate; }
    public void setFormattedDate(String formattedDate) { this.formattedDate = formattedDate; }

    public List<EventDetailDto> getEvents() { return events; }
    public void setEvents(List<EventDetailDto> events) { this.events = events; }
}
