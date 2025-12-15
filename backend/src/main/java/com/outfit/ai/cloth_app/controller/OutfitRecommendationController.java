package com.outfit.ai.cloth_app.controller;


import com.outfit.ai.cloth_app.service.AuthService;
import com.outfit.ai.cloth_app.service.OutfitRecommendationService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Mono;

import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class OutfitRecommendationController {
    private final OutfitRecommendationService recommendationService;
    private final AuthService authService;

    public OutfitRecommendationController(
            OutfitRecommendationService recommendationService,
            AuthService authService) {
        this.recommendationService = recommendationService;
        this.authService = authService;
    }

    // 이전 코디 추천 API - 이미지를 업로드하여 AI 추천을 받음
    @PostMapping(value = "/recommend/outfit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Mono<ResponseEntity<String>> recommendOutfit(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestPart("image") MultipartFile image) {

        if(image.isEmpty()) {
            return Mono.just(ResponseEntity.badRequest().body("\"error\": \"Image file is missing.\"}"));
        }

        try {
            UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);

            return recommendationService.requestAndSaveRecommendation(userId, image)
                    .map(ResponseEntity::ok)
                    .onErrorResume(e -> {
                        System.err.println("Service Error during recommendation: " + e.getMessage());
                        return Mono.just(ResponseEntity.internalServerError().body("{\"error\": \"Server processing error occurred: " + e.getMessage() + "\"}"));
                    });
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.status(401).body("{\"error\": \"Authentication failed or invalid user ID.\"}"));
        } catch (Exception e) {
            System.err.println("Unexpected Error in Controller");
            return Mono.just(ResponseEntity.internalServerError().body("{\"error\": \"An unexpected error occurred.\"}"));
        }
    }

    // 일정 기반 코디 추천 API
    @PostMapping("/outfits/recommend")
    public ResponseEntity<?> recommendOutfitBySchedule(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody Map<String, Object> request) {
        try {
            // 인증 검증
            authService.getUserIdFromAuthHeader(authorizationHeader);

            // 요청 데이터 추출 (향후 구현에서 사용)
            @SuppressWarnings("unused")
            String date = (String) request.get("date");
            @SuppressWarnings("unused")
            String time = (String) request.get("time");
            String location = (String) request.get("location");
            @SuppressWarnings({"unchecked", "unused"})
            List<String> tags = (List<String>) request.get("tags");

            // 임시 응답 - 실제 구현 필요
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", Map.of(
                    "recommended_items", Arrays.asList(
                            Map.of("name", "추천 의류 1", "category", "상의"),
                            Map.of("name", "추천 의류 2", "category", "하의")
                    ),
                    "reason", String.format("%s에서 열리는 행사에 어울리는 캐주얼 스타일 코디입니다.", location)
            ));

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", "Authentication failed"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // 가상 피팅 이미지 생성 API
    @PostMapping("/outfits/virtual-fitting")
    public ResponseEntity<?> generateVirtualFitting(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody Map<String, Object> request) {
        try {
            // 인증 검증
            authService.getUserIdFromAuthHeader(authorizationHeader);

            @SuppressWarnings("unchecked")
            List<String> clothIds = (List<String>) request.get("cloth_ids");

            if (clothIds == null || clothIds.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "error", "No clothes selected"));
            }

            // 임시 응답 - 실제 AI 모델 호출 필요
            String generatedImageUrl = "https://via.placeholder.com/500x600?text=Virtual+Fitting";

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", Map.of(
                    "image_url", generatedImageUrl,
                    "clothes_count", clothIds.size()
            ));

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", "Authentication failed"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // 코디를 커뮤니티에 공유 API
    @PostMapping("/outfits/share")
    public ResponseEntity<?> shareOutfitToCommunity(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody Map<String, Object> request) {
        try {
            // 인증 검증
            authService.getUserIdFromAuthHeader(authorizationHeader);

            String imageUrl = (String) request.get("image_url");
            // 향후 구현에서 사용할 데이터
            @SuppressWarnings("unused")
            String description = (String) request.get("description");
            @SuppressWarnings({"unchecked", "unused"})
            List<String> tags = (List<String>) request.get("tags");

            if (imageUrl == null || imageUrl.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "error", "Image URL is required"));
            }

            // 임시 응답 - 실제 DB 저장 필요
            String outfitId = UUID.randomUUID().toString();

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", Map.of(
                    "outfit_id", outfitId,
                    "message", "코디가 커뮤니티에 공유되었습니다."
            ));

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", "Authentication failed"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
