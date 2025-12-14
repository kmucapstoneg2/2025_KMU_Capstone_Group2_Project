package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.service.GoogleCalendarService;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.view.RedirectView;

import java.io.IOException;
import java.security.GeneralSecurityException;

// 구글 인증 컨트롤러
@Controller
public class GoogleAuthController {
    private final GoogleCalendarService calendarService;

    public GoogleAuthController(GoogleCalendarService calendarService) {
        this.calendarService = calendarService;
    }

    @GetMapping("/auth/google/success")
    public RedirectView oauth2SuccessHandler(
            @RegisteredOAuth2AuthorizedClient("google")OAuth2AuthorizedClient authorizedClient,
            Authentication authentication) {
        String userIdString = authentication.getName();

        try {
            calendarService.fetchAndSaveSchedules(userIdString);
        } catch (IllegalArgumentException e) {
            System.err.println("사용자를 찾을 수 없음: " + e.getMessage());
            return new RedirectView("/error?message=USER_NOT_FOUND");
        } catch (GeneralSecurityException | IOException e) {
            e.printStackTrace();
            System.err.println("Google Calendar 동기화 중 오휴 발생: " + e.getMessage());
            return new RedirectView("/error?message=SYNC_FAILED");
        }

        return new RedirectView("/home");
    }
}
