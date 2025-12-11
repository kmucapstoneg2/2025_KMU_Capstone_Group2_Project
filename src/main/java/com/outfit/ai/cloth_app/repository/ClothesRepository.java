package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.ClothesTable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ClothesRepository extends JpaRepository<ClothesTable, UUID> {
    List<ClothesTable> findAllByUserTable_UserId(UUID userId);
}
