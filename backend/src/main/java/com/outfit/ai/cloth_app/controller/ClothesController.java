package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.dto.request.ClothesCreateRequestDto;
import com.outfit.ai.cloth_app.dto.response.ClothesListResponseDto;
import com.outfit.ai.cloth_app.service.AuthService;
import com.outfit.ai.cloth_app.service.ClothesService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

/**
 * 옷장 컨트롤러 - 옷 등록/조회 API
 * 
 * 엔드포인트:
 * - POST /api/v1/wardrobe/clothes : 옷 등록 (이미지 업로드 포함)
 * - GET  /api/v1/wardrobe/clothes : 사용자의 옷 목록 조회
 * 
 * 인증: Bearer Token 필수 (Authorization 헤더)
 * Flutter에서 ClothesService를 통해 호출됨
 * @see ClothesService
 */
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
