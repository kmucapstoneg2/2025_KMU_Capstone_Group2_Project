package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.dto.request.ClothesCreateRequestDto;
import com.outfit.ai.cloth_app.dto.response.ClothesListResponseDto;
import com.outfit.ai.cloth_app.service.AuthService;
import com.outfit.ai.cloth_app.service.ClothesService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

// 옷 컨트롤러
@RestController
@RequestMapping("/api/v1/wardrobe")
public class ClothesController {
    private final ClothesService clothesService;
    private final AuthService authService;

    public ClothesController(ClothesService clothesService, AuthService authService) {
        this.clothesService = clothesService;
        this.authService = authService;
    }

    // 옷 등록
    @PostMapping("/clothes")
    public ResponseEntity<Void> createClothes(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestPart("data") ClothesCreateRequestDto request,
            @RequestPart("image") MultipartFile imageFile) {
        UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);

        clothesService.createClothes(userId, request, imageFile);

        return ResponseEntity.ok().build();
    }

    // 옷 리스트 불러오가
    @GetMapping("/clothes")
    public ResponseEntity<ClothesListResponseDto> getClothesList(
            @RequestHeader("Authorization") String authorizationHeader) {
        UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);

        ClothesListResponseDto response = clothesService.getClothesList(userId);

        return ResponseEntity.ok(response);
    }
}
