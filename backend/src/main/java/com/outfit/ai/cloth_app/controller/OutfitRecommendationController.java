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
    public Mono<ResponseEntity<Map<String, Object>>> recommendOutfit(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestPart("image") MultipartFile image,
            @RequestPart(value = "cloth_ids", required = false) List<String> clothIds) {

        if (image.isEmpty()) {
            return Mono.just(ResponseEntity.badRequest().body(Map.of("success", false, "error", "Image file is missing.")));
        }

        try {
            UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);
            List<UUID> parsedClothIds = parseClothIds(clothIds);

            return recommendationService.requestAndSaveRecommendation(userId, image, parsedClothIds)
                    .map(data -> ResponseEntity.ok(Map.of("success", true, "data", data)))
                    .onErrorResume(e -> {
                        System.err.println("Service Error during recommendation: " + e.getMessage());
                        return Mono.just(ResponseEntity.internalServerError().body(Map.of("success", false, "error", e.getMessage())));
                    });
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.status(401).body(Map.of("success", false, "error", "Authentication failed or invalid user ID.")));
        } catch (Exception e) {
            System.err.println("Unexpected Error in Controller" + e.getMessage());
            return Mono.just(ResponseEntity.internalServerError().body(Map.of("success", false, "error", "An unexpected error occurred.")));
        }
    }

    // 일정 기반 코디 추천 API
    @PostMapping("/outfits/recommend")
    public ResponseEntity<?> recommendOutfitBySchedule(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody Map<String, Object> request) {
        try {
            UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);

            String date = (String) request.get("date");
            String time = (String) request.get("time");
            String location = (String) request.getOrDefault("location", "");
            @SuppressWarnings("unchecked")
            List<String> tags = (List<String>) request.getOrDefault("tags", List.of());

            Map<String, Object> response = recommendationService.recommendBySchedule(userId, location, tags);
            response.put("requested_date", date);
            response.put("requested_time", time);

            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", "Authentication failed"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // 가상 피팅 이미지 생성 API
    @PostMapping(value = "/outfits/virtual-fitting", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Mono<ResponseEntity<Map<String, Object>>> generateVirtualFitting(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestPart("image") MultipartFile image,
            @RequestPart(value = "cloth_ids", required = false) List<String> clothIds) {
        try {
            UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);
            List<UUID> parsedClothIds = parseClothIds(clothIds);

            return recommendationService.requestAndSaveRecommendation(userId, image, parsedClothIds)
                    .map(data -> ResponseEntity.ok(Map.of(
                            "success", true,
                            "data", data
                    )))
                    .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(Map.of(
                            "success", false,
                            "error", e.getMessage()
                    ))));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.status(401).body(Map.of("success", false, "error", "Authentication failed")));
        } catch (Exception e) {
            return Mono.just(ResponseEntity.internalServerError().body(Map.of("success", false, "error", e.getMessage())));
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

    private List<UUID> parseClothIds(List<String> clothIds) {
        if (clothIds == null) {
            return Collections.emptyList();
        }

        List<UUID> parsed = new ArrayList<>();
        for (String id : clothIds) {
            try {
                if (id != null && id.trim().startsWith("[")) {
                    List<String> jsonIds = Arrays.asList(id
                            .replace("[", "")
                            .replace("]", "")
                            .replace("\"", "")
                            .split(","));
                    jsonIds.stream()
                            .map(String::trim)
                            .filter(s -> !s.isEmpty())
                            .forEach(item -> {
                                try {
                                    parsed.add(UUID.fromString(item));
                                } catch (Exception ignoredInner) {
                                }
                            });
                    continue;
                }
                parsed.add(UUID.fromString(id));
            } catch (Exception ignored) {
            }
        }
        return parsed;
    }
}
