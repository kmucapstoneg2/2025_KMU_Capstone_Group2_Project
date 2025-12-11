package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.StyleCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface StyleCodeRepository extends JpaRepository<StyleCode, UUID> {
    Optional<StyleCode> findByStyleName(String name);
}
