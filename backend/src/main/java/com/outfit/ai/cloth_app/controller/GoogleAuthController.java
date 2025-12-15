package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.service.GoogleCalendarService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

// 구글 인증 컨트롤러
@Controller
public class GoogleAuthController {
    @SuppressWarnings("unused")
    private final GoogleCalendarService calendarService;

    public GoogleAuthController(GoogleCalendarService calendarService) {
        this.calendarService = calendarService;
    }

    @GetMapping("/auth/google/failure")
    public String oauth2FailureHandler() {
        System.err.println("=== 구글 OAuth2 로그인 실패 ===");
        return "<html><body style='font-family: sans-serif; text-align: center; padding: 50px;'>" +
            "<h1 style='color: #f44336;'>✗ 구글 로그인 실패</h1>" +
            "<p>구글 인증에 실패했습니다.</p>" +
            "<p>다시 시도해주세요.</p>" +
            "</body></html>";
    }

    @GetMapping("/auth/google/success")
    public String oauth2SuccessHandler(
            @RegisteredOAuth2AuthorizedClient("google")OAuth2AuthorizedClient authorizedClient,
            Authentication authentication) {
        
        // OAuth2User에서 구글 이메일 가져오기
        OAuth2User oauth2User = (OAuth2User) authentication.getPrincipal();
        String googleEmail = oauth2User.getAttribute("email");
        String googleName = oauth2User.getAttribute("name");
        String accessToken = authorizedClient.getAccessToken().getTokenValue();

        System.out.println("=== 구글 OAuth2 로그인 성공 ===");
        System.out.println("Google Email: " + googleEmail);
        System.out.println("Google Name: " + googleName);
        System.out.println("Access Token: " + accessToken.substring(0, 20) + "...");

        // 일단 성공 페이지만 반환 (구글 이메일 저장은 Flutter에서 처리)
        return String.format(
            "<html><body style='font-family: sans-serif; text-align: center; padding: 50px;'>" +
            "<h1 style='color: #4CAF50;'>✓ 구글 로그인 성공!</h1>" +
            "<p>연동된 계정: <strong>%s</strong></p>" +
            "<p>이제 앱으로 돌아가서 <strong>'연동 확인'</strong> 버튼을 눌러주세요.</p>" +
            "<br><p style='color: #666; font-size: 12px;'>이 창을 닫으셔도 됩니다.</p>" +
            "<script>" +
            "localStorage.setItem('google_email', '%s');" +
            "localStorage.setItem('google_name', '%s');" +
            "localStorage.setItem('google_connected', 'true');" +
            "</script>" +
            "</body></html>",
            googleEmail, googleEmail, googleName
        );
    }
}

// 모바일 앱용 API 컨트롤러
@RestController
class GoogleAuthApiController {
    @GetMapping("/api/v1/auth/google/callback")
    public ResponseEntity<Map<String, String>> mobileCallback(
            @RegisteredOAuth2AuthorizedClient("google") OAuth2AuthorizedClient authorizedClient,
            Authentication authentication) {
        
        OAuth2User oauth2User = (OAuth2User) authentication.getPrincipal();
        String email = oauth2User.getAttribute("email");
        String accessToken = authorizedClient.getAccessToken().getTokenValue();
        
        Map<String, String> response = new HashMap<>();
        response.put("email", email);
        response.put("accessToken", accessToken);
        response.put("success", "true");
        
        return ResponseEntity.ok(response);
    }
}
