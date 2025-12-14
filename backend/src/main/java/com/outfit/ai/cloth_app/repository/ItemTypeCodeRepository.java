package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.ItemTypeCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ItemTypeCodeRepository extends JpaRepository<ItemTypeCode, UUID> {
    Optional<ItemTypeCode> findByItemTypeName(String name);
}
