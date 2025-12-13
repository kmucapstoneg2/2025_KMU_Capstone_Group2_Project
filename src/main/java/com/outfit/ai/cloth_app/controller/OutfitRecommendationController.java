package com.outfit.ai.cloth_app.controller;


import com.outfit.ai.cloth_app.service.AuthService;
import com.outfit.ai.cloth_app.service.OutfitRecommendationService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/recommend")
public class OutfitRecommendationController {
    private final OutfitRecommendationService recommendationService;
    private final AuthService authService;

    public OutfitRecommendationController(
            OutfitRecommendationService recommendationService,
            AuthService authService) {
        this.recommendationService = recommendationService;
        this.authService = authService;
    }

    @PostMapping(value = "/outfit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Mono<ResponseEntity<String>> recommendOutfit(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestPart("imaage")MultipartFile image) {

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
}
