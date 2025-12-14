package com.outfit.ai.cloth_app;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Bean;

@SpringBootTest
class ClothAppApplicationTests {

	@Test
	void contextLoads() {
	}

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
