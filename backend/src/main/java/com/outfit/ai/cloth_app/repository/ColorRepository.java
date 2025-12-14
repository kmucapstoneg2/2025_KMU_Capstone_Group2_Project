package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.ColorCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ColorRepository extends JpaRepository<ColorCode, Integer> {
    Optional<ColorCode>  findByColorName(String name);
}
