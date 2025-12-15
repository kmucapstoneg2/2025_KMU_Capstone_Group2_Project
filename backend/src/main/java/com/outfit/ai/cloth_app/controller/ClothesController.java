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
            @RequestParam("name") String name,
            @RequestParam("categoryName") String categoryName,
            @RequestParam("colorName") String colorName,
            @RequestParam("materialName") String materialName,
            @RequestParam(value = "seasonName", required = false) String seasonName,
            @RequestParam(value = "styleName", required = false) String styleName,
            @RequestParam(value = "itemTypeName", required = false) String itemTypeName,
            @RequestPart("image") MultipartFile imageFile) {
        UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);
        
        ClothesCreateRequestDto request = new ClothesCreateRequestDto();
        request.setName(name);
        request.setCategoryCode(categoryName);
        request.setColorCode(colorName);
        request.setMaterialCode(materialName);
        request.setSeasonName(seasonName);
        request.setStyleName(styleName);
        request.setItemTypeName(itemTypeName);

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
    
    // 옷 수정
    @PutMapping("/clothes/{clothId}")
    public ResponseEntity<Void> updateClothes(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable UUID clothId,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "categoryName", required = false) String categoryName,
            @RequestParam(value = "colorName", required = false) String colorName,
            @RequestParam(value = "materialName", required = false) String materialName,
            @RequestParam(value = "seasonName", required = false) String seasonName,
            @RequestParam(value = "styleName", required = false) String styleName,
            @RequestParam(value = "itemTypeName", required = false) String itemTypeName) {
        UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);
        
        clothesService.updateClothes(userId, clothId, name, categoryName, colorName, 
                                     materialName, seasonName, styleName, itemTypeName);

        return ResponseEntity.ok().build();
    }
    
    // 옷 삭제
    @DeleteMapping("/clothes/{clothId}")
    public ResponseEntity<Void> deleteClothes(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable UUID clothId) {
        UUID userId = authService.getUserIdFromAuthHeader(authorizationHeader);

        clothesService.deleteClothes(userId, clothId);

        return ResponseEntity.ok().build();
    }
}
