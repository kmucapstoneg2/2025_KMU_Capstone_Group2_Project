package com.outfit.ai.cloth_app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class ClothAppApplication {

	public static void main(String[] args) {
		SpringApplication.run(ClothAppApplication.class, args);
	}

}
