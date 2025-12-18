package com.outfit.ai.cloth_app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.outfit.ai.cloth_app.entity.ClothesTable;
import com.outfit.ai.cloth_app.entity.OutfitCombination;
import com.outfit.ai.cloth_app.entity.UserTable;
import com.outfit.ai.cloth_app.repository.ClothesRepository;
import com.outfit.ai.cloth_app.repository.OutfitCombinationRepository;
import com.outfit.ai.cloth_app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class OutfitRecommendationService {
    private final String aiApiBaseUrl;
    private final WebClient webClient;
    private final OutfitCombinationRepository combinationRepository;
    private final UserRepository userRepository;
    private final ClothesRepository clothesRepository;
    private final S3FileUploader s3FileUploader;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public OutfitRecommendationService(
            @Value("${ai.api.aiApiBaseUrl}") String aiApiBaseUrl,
            WebClient.Builder webClientBuilder,
            OutfitCombinationRepository combinationRepository,
            UserRepository userRepository,
            ClothesRepository clothesRepository,
            S3FileUploader s3FileUploader) {
        this.aiApiBaseUrl = aiApiBaseUrl;
        this.webClient = webClientBuilder.baseUrl(this.aiApiBaseUrl).build();
        this.combinationRepository = combinationRepository;
        this.userRepository = userRepository;
        this.clothesRepository = clothesRepository;
        this.s3FileUploader = s3FileUploader;
    }

    @Transactional
    public Mono<Map<String, Object>> requestAndSaveRecommendation(
            UUID userId,
            MultipartFile userImageFile,
            List<UUID> clothIds) {
        String base64UserImage;
        try {
            base64UserImage = Base64.getEncoder().encodeToString(userImageFile.getBytes());
        } catch (IOException e) {
            return Mono.error(new RuntimeException("Error reading image file.", e));
        }

        List<UUID> safeClothIds = clothIds == null ? Collections.emptyList() : clothIds;

        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("image_base64", base64UserImage);

        return webClient.post()
                .uri("/api/recommend")
                .header("Content-Type", "application/json")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .flatMap(responseJson -> {
                    try {
                        JsonNode root = objectMapper.readTree(responseJson);
                        JsonNode base64ImageNode = root.get("aiGenImageUrl");

                        if (base64ImageNode != null && base64ImageNode.isTextual()) {
                            String base64Image = base64ImageNode.asText();

                            byte[] imageBytes = Base64.getDecoder().decode(base64Image);

                            MultipartFile generatedImageWrapper = new ByteArrayMultipartFile(
                                    imageBytes,
                                    "ai_recommendation.jpeg",
                                    "image/jpeg"
                            );

                            String imageUrl = s3FileUploader.upload(generatedImageWrapper, userId);

                            UserTable user = userRepository.findById(userId)
                                    .orElseThrow(() -> new IllegalArgumentException("User ID not found."));

                            OutfitCombination newCombination = new OutfitCombination();
                            newCombination.setUserTable(user);
                            newCombination.setAiGenImageUrl(imageUrl);
                            newCombination.setShared(false);
                            newCombination.setClothIds(objectMapper.writeValueAsString(safeClothIds));

                            OutfitCombination savedCombination = combinationRepository.save(newCombination);

                            Map<String, Object> data = new HashMap<>();
                            data.put("image_url", imageUrl);
                            data.put("outfit_id", savedCombination.getOutfitId());
                            data.put("cloth_ids", safeClothIds);

                            return Mono.just(data);
                        }

                        System.err.println("AI Response Missing URL: " + responseJson);
                        return Mono.error(new IllegalStateException("AI response did not contain a valid image URL."));
                    } catch (Exception e) {
                        System.err.println("Processing Error: " + e.getMessage());
                        return Mono.error(new RuntimeException("Error processing recommendation result.", e));
                    }
                })
                .onErrorResume(e -> {
                    System.err.println("Communication Error with AI API: " + e.getMessage());
                    return Mono.error(new RuntimeException("Failed to communicate with the Render AI Server. URL: " + this.aiApiBaseUrl, e));
                });
    }

    @Transactional(readOnly = true)
    public Map<String, Object> recommendBySchedule(UUID userId, String location, List<String> tags) {
        List<ClothesTable> clothes = clothesRepository.findAllByUserTable_UserId(userId);

        if (clothes.isEmpty()) {
            throw new IllegalStateException("사용자의 옷장에 등록된 옷이 없습니다.");
        }

        List<String> safeTags = tags == null ? Collections.emptyList() : tags;

        // 1단계: 의류 정보를 AI 서버로 전송할 형태로 변환
        List<Map<String, Object>> clothDataList = clothes.stream()
                .map(cloth -> {
                    Map<String, Object> clothData = new HashMap<>();
                    clothData.put("cloth_id", cloth.getClothId().toString());
                    clothData.put("name", cloth.getClothName());
                    clothData.put("category", cloth.getCategoryCode() != null ? cloth.getCategoryCode().getCategoryName() : "");
                    clothData.put("color", cloth.getColorCode() != null ? cloth.getColorCode().getColorName() : "");
                    clothData.put("style", cloth.getStyleCode() != null ? cloth.getStyleCode().getStyleName() : "");
                    clothData.put("season", cloth.getSeasonCode() != null ? cloth.getSeasonCode().getSeasonName() : "");
                    clothData.put("material", cloth.getMaterialCode() != null ? cloth.getMaterialCode().getMaterialName() : "");
                    return clothData;
                })
                .toList();

        // 2단계: AI 서버에 코디 추천 요청
        Map<String, Object> aiRequest = new HashMap<>();
        aiRequest.put("clothes", clothDataList);
        aiRequest.put("location", location != null ? location : "");
        aiRequest.put("tags", safeTags);
        aiRequest.put("user_id", userId.toString());

        try {
            System.out.println("[OutfitRecommendationService] AI 서버에 코디 추천 요청: " + location);
            
            String aiResponse = webClient.post()
                    .uri("/api/recommend/outfit")
                    .header("Content-Type", "application/json")
                    .bodyValue(aiRequest)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            System.out.println("[OutfitRecommendationService] AI 서버 응답: " + aiResponse);

            // 3단계: AI 응답 파싱
            JsonNode responseNode = objectMapper.readTree(aiResponse);
            JsonNode recommendedClothIdsNode = responseNode.get("recommended_cloth_ids");

            List<Map<String, Object>> recommendedItems = new ArrayList<>();

            if (recommendedClothIdsNode != null && recommendedClothIdsNode.isArray()) {
                for (JsonNode clothIdNode : recommendedClothIdsNode) {
                    try {
                        String clothIdStr = clothIdNode.asText();
                        UUID clothId = UUID.fromString(clothIdStr);
                        
                        ClothesTable cloth = clothesRepository.findById(clothId).orElse(null);
                        if (cloth != null) {
                            recommendedItems.add(toClothMap(cloth));
                        }
                    } catch (IllegalArgumentException e) {
                        System.err.println("[OutfitRecommendationService] 잘못된 cloth_id 형식: " + clothIdNode.asText());
                    }
                }
            }

            // 4단계: AI에서 추천이 없으면 기본 추천으로 대체
            if (recommendedItems.isEmpty()) {
                System.out.println("[OutfitRecommendationService] AI 추천이 없음, 기본 추천으로 대체");
                
                List<ClothesTable> filtered = clothes.stream()
                        .filter(item -> matchesTags(item, safeTags))
                        .toList();

                List<ClothesTable> targetClothes = filtered.isEmpty() ? clothes : filtered;

                Map<String, List<ClothesTable>> byCategory = targetClothes.stream()
                        .collect(Collectors.groupingBy(cloth -> 
                            cloth.getCategoryCode() != null ? cloth.getCategoryCode().getCategoryName() : "기타"));

                List<String> categoryOrder = List.of("상의", "하의", "아우터", "신발", "액세서리");
                
                for (String category : categoryOrder) {
                    if (byCategory.containsKey(category)) {
                        List<ClothesTable> categoryClothes = byCategory.get(category).stream()
                                .sorted(Comparator.comparing(ClothesTable::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                                .limit(1)
                                .toList();
                        
                        recommendedItems.addAll(categoryClothes.stream()
                                .map(this::toClothMap)
                                .toList());
                    }
                }
            }

            String reason = String.format("%s에서 예정된 일정과 어울리는 코디를 AI가 추천했어요.", location == null ? "선택한 장소" : location);

            Map<String, Object> data = new HashMap<>();
            data.put("recommended_items", recommendedItems);
            data.put("reason", reason);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", data);

            return response;

        } catch (Exception e) {
            System.err.println("[OutfitRecommendationService] AI 서버 통신 실패: " + e.getMessage());
            e.printStackTrace();

            // AI 서버 실패 시 기본 추천으로 대체
            List<ClothesTable> filtered = clothes.stream()
                    .filter(item -> matchesTags(item, safeTags))
                    .toList();

            List<ClothesTable> targetClothes = filtered.isEmpty() ? clothes : filtered;

            Map<String, List<ClothesTable>> byCategory = targetClothes.stream()
                    .collect(Collectors.groupingBy(cloth -> 
                        cloth.getCategoryCode() != null ? cloth.getCategoryCode().getCategoryName() : "기타"));

            List<Map<String, Object>> recommendedItems = new ArrayList<>();

            List<String> categoryOrder = List.of("상의", "하의", "아우터", "신발", "액세서리");
            
            for (String category : categoryOrder) {
                if (byCategory.containsKey(category)) {
                    List<ClothesTable> categoryClothes = byCategory.get(category).stream()
                            .sorted(Comparator.comparing(ClothesTable::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                            .limit(1)
                            .toList();
                    
                    recommendedItems.addAll(categoryClothes.stream()
                            .map(this::toClothMap)
                            .toList());
                }
            }

            String reason = String.format("%s에서 예정된 일정과 어울리는 코디를 추천했어요.", location == null ? "선택한 장소" : location);

            Map<String, Object> data = new HashMap<>();
            data.put("recommended_items", recommendedItems);
            data.put("reason", reason);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", data);

            return response;
        }
    }

    private boolean matchesTags(ClothesTable cloth, List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return true;
        }

        String style = cloth.getStyleCode() != null ? cloth.getStyleCode().getStyleName() : null;
        String category = cloth.getCategoryCode() != null ? cloth.getCategoryCode().getCategoryName() : null;

        return tags.stream().anyMatch(tag -> {
            String lowered = tag.toLowerCase();
            return (style != null && style.toLowerCase().contains(lowered)) ||
                    (category != null && category.toLowerCase().contains(lowered));
        });
    }

    private Map<String, Object> toClothMap(ClothesTable cloth) {
        Map<String, Object> map = new HashMap<>();
        map.put("cloth_id", cloth.getClothId());
        map.put("name", cloth.getClothName());
        map.put("image_url", cloth.getImageUrl());
        map.put("category_name", cloth.getCategoryCode() != null ? cloth.getCategoryCode().getCategoryName() : null);
        map.put("style_name", cloth.getStyleCode() != null ? cloth.getStyleCode().getStyleName() : null);
        map.put("season_name", cloth.getSeasonCode() != null ? cloth.getSeasonCode().getSeasonName() : null);
        map.put("color_name", cloth.getColorCode() != null ? cloth.getColorCode().getColorName() : null);
        map.put("material_name", cloth.getMaterialCode() != null ? cloth.getMaterialCode().getMaterialName() : null);
        return map;
    }

    private static class  ByteArrayMultipartFile implements MultipartFile {
        private final byte[] content;
        private final String name;
        private final String originalFilename;
        private final String contentType;

        public ByteArrayMultipartFile(byte[] content, String originalFilename, String contentType) {
            this.content = content;
            this.name = "file";
            this.originalFilename = originalFilename;
            this.contentType = contentType;
        }

        @Override public String getName() { return name; }
        @Override public String getOriginalFilename() { return originalFilename; }
        @Override public String getContentType() { return contentType; }
        @Override public boolean isEmpty() { return content == null || content.length == 0; }
        @Override public long getSize() { return content.length; }
        @Override public byte[] getBytes() throws IOException { return content; }
        @Override public InputStream getInputStream() throws IOException { return new ByteArrayInputStream(content); }
        @Override public void transferTo(File dest) throws IOException, IllegalStateException { throw new UnsupportedOperationException("Not supported for in-memory file."); }
    }
}
