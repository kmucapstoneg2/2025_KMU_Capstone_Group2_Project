package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.service.RoboflowService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Mono;

import java.io.IOException;

@RestController
@RequestMapping("/roboflow")
public class RoboflowController {
    private final RoboflowService roboflowService;

    public RoboflowController(RoboflowService roboflowService) {
        this.roboflowService = roboflowService;
    }

    @PostMapping(value = "/blur_face", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Mono<String> blurFace(@RequestParam("image")MultipartFile image) throws IOException {
        if (image.isEmpty()) {
            return Mono.just("{\"error\": \"Image file is empty.\"}");
        }

        return roboflowService.getBlurFace(image);
    }
}
