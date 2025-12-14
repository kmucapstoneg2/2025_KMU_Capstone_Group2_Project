package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.dto.RecentOutfitDto;
import com.outfit.ai.cloth_app.service.OutfitService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

// 홈화면 컨트롤러
@RestController
@RequestMapping("/api/v1/home")
public class HomeController {
    private final OutfitService outfitService;

    public HomeController(OutfitService outfitService) {
        this.outfitService = outfitService;
    }

    // 최근 옷 조합
    @GetMapping("/recent-outfits")
    public ResponseEntity<List<RecentOutfitDto>> getRecentOutfits(
            @AuthenticationPrincipal Object principal,
            @RequestParam(defaultValue = "4") int limit) {
        String userIdentifier = principal.toString();

        try {
            List<RecentOutfitDto> recentOutfits = outfitService.getRecentOutfits(userIdentifier, limit);
            return ResponseEntity.ok(recentOutfits);
        } catch (Exception e) {
            System.err.println("Error fetching recent outfits: " + e.getMessage());
            return ResponseEntity.status(500).body(null);
        }
    }
}
