package com.outfit.ai.cloth_app.controller;

import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.outfit.ai.cloth_app.service.GoogleCalendarService;
import com.outfit.ai.cloth_app.entity.UserCalendar;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;

// 캘린더 컨트롤러
@RestController
@RequestMapping("/api/v1/schedules")
public class CalendarController {
    private final GoogleCalendarService calendarService;

    public CalendarController(GoogleCalendarService calendarService) {
        this.calendarService = calendarService;
    }

    // 불러오고 저장
    @GetMapping("/fetch-and-save")
    public ResponseEntity<List<UserCalendar>> fetchAndSaveSchedulesApi(
            @RegisteredOAuth2AuthorizedClient("google") OAuth2AuthorizedClient authorizedClient,
            Authentication authentication) {
        String accessToken = authorizedClient.getAccessToken().getTokenValue();

        String userIdString = authentication.getName();

        try {
            Credential credential = new GoogleCredential.Builder()
                    .setTransport(GoogleNetHttpTransport.newTrustedTransport())
                    .setJsonFactory(GsonFactory.getDefaultInstance())
                    .build()
                    .setAccessToken(accessToken);

            List<UserCalendar> schedules = calendarService.fetchAndSaveSchedules(userIdString);

            return ResponseEntity.ok(schedules);

        } catch (IllegalArgumentException e) {
            System.err.println("User not found: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (GeneralSecurityException | IOException e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}