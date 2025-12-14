package com.outfit.ai.cloth_app.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
public class RoboflowService {
    private final String pythonServerUrl;

    private final WebClient webClient;

    public RoboflowService(WebClient.Builder webClientBuilder,
                           @Value("${AI_GATEWAY_UTL:http://localhost:5000}") String pythonServerUrl) {
        this.pythonServerUrl = pythonServerUrl;
        this.webClient = webClientBuilder.baseUrl(this.pythonServerUrl).build();
    }

    public Mono<String> getBlurFace(MultipartFile imageFile) throws IOException {
        byte[] imageBytes = imageFile.getBytes();
        String base64Image = Base64.getEncoder().encodeToString(imageBytes);

        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("image_base64", base64Image);

        return webClient.post()
                .uri("/api/blur_faces")
                .header("Content-Type", "application/json")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .doOnSuccess(result -> System.out.println("AI Server Response Success."))
                .onErrorResume(e -> {
                    System.err.println("Error calling Python inference service: " + e.getMessage());
                    return Mono.just("{\"error\": \"AI 서버와 통신에 실패했습니다.\"}");
                });
    }
}
