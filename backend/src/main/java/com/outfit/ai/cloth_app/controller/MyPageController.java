package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.dto.response.MyPageProfileResponseDto;
import com.outfit.ai.cloth_app.service.MyPageService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

// 마이페이지 컨트롤러
@RestController
@RequestMapping("/api/v1/mypage")
public class MyPageController {
    private final MyPageService myPageService;

    public MyPageController(MyPageService myPageService) {
        this.myPageService = myPageService;
    }

    // 프로필 정보 불러오기
    @GetMapping("/profile")
    public ResponseEntity<MyPageProfileResponseDto> getMyProfile(@AuthenticationPrincipal String userIdString) {
        UUID userId = UUID.fromString(userIdString);

        MyPageProfileResponseDto response = myPageService.getMyProfile(userId);

        return ResponseEntity.ok(response);
    }
}
