package com.outfit.ai.cloth_app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.outfit.ai.cloth_app.entity.OutfitCombination;
import com.outfit.ai.cloth_app.entity.UserTable;
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
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class OutfitRecommendationService {
    private final String aiApiBaseUrl;
    private final WebClient webClient;
    private final OutfitCombinationRepository combinationRepository;
    private final UserRepository userRepository;
    private final S3FileUploader s3FileUploader;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public OutfitRecommendationService(
            @Value("${ai.api.aiApiBaseUrl}") String aiApiBaseUrl,
            WebClient.Builder webClientBuilder,
            OutfitCombinationRepository combinationRepository,
            UserRepository userRepository,
            S3FileUploader s3FileUploader) {
        this.aiApiBaseUrl = aiApiBaseUrl;
        this.webClient = webClientBuilder.baseUrl(this.aiApiBaseUrl).build();
        this.combinationRepository = combinationRepository;
        this.userRepository = userRepository;
        this.s3FileUploader = s3FileUploader;
    }

    @Transactional
    public Mono<String> requestAndSaveRecommendation(UUID userId, MultipartFile userImageFile) {
        String base64UserImage;
        try {
            base64UserImage = Base64.getEncoder().encodeToString(userImageFile.getBytes());
        } catch (IOException e) {
            return Mono.error(new RuntimeException("Error reading image file.", e));
        }

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

                            OutfitCombination savedCombination = combinationRepository.save(newCombination);

                            return Mono.just("{\"status\": \"success\", \"recommendation_url\": \"" + imageUrl + "\", \"outfit_id\": \"" + savedCombination.getOutfitId().toString() + "\"}");
                        } else {
                            System.err.println("AI Response Missing URL: " + responseJson);
                            return Mono.just("{\"error\": \"AI response did not contain a valid image URL.\"}");
                        }
                    } catch (Exception e) {
                        System.err.println("Processing Error: " + e.getMessage());
                        return Mono.just("{\"error\": \"Error processing recommendation result.\", \"detail\": \"" + e.getMessage() + "\"}");
                    }
                })
                .onErrorResume(e -> {
                    System.err.println("Communication Error with AI API: " + e.getMessage());
                    return Mono.just("{\"error\": \"Failed to communicate with the Render AI Server. URL: " + this.aiApiBaseUrl + "\"}");
                });
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
