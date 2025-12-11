package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.MaterialCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MaterialRepository extends JpaRepository<MaterialCode, Integer> {
    Optional<MaterialCode> findByMaterialName(String name);
}
