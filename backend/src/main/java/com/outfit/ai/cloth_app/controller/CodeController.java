package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.service.CodeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 코드 테이블 조회 API
 * 
 * 엔드포인트:
 * - GET /api/v1/codes/categories : 카테고리 목록
 * - GET /api/v1/codes/colors     : 색상 목록
 * - GET /api/v1/codes/materials  : 소재 목록
 * - GET /api/v1/codes/seasons    : 계절 목록
 * - GET /api/v1/codes/styles     : 스타일 목록
 * - GET /api/v1/codes/types      : 종류 목록
 */
@RestController
@RequestMapping("/api/v1/codes")
public class CodeController {
    private final CodeService codeService;

    public CodeController(CodeService codeService) {
        this.codeService = codeService;
    }

    @GetMapping("/categories")
    public ResponseEntity<List<Map<String, Object>>> getCategories() {
        System.out.println("[CodeController] getCategories called");
        List<Map<String, Object>> result = codeService.getCategories();
        System.out.println("[CodeController] Returning " + result.size() + " categories");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/colors")
    public ResponseEntity<List<Map<String, Object>>> getColors() {
        System.out.println("[CodeController] getColors called");
        List<Map<String, Object>> result = codeService.getColors();
        System.out.println("[CodeController] Returning " + result.size() + " colors");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/materials")
    public ResponseEntity<List<Map<String, Object>>> getMaterials() {
        return ResponseEntity.ok(codeService.getMaterials());
    }

    @GetMapping("/seasons")
    public ResponseEntity<List<Map<String, Object>>> getSeasons() {
        return ResponseEntity.ok(codeService.getSeasons());
    }

    @GetMapping("/styles")
    public ResponseEntity<List<Map<String, Object>>> getStyles() {
        return ResponseEntity.ok(codeService.getStyles());
    }

    @GetMapping("/types")
    public ResponseEntity<List<Map<String, Object>>> getTypes() {
        return ResponseEntity.ok(codeService.getTypes());
    }
}
