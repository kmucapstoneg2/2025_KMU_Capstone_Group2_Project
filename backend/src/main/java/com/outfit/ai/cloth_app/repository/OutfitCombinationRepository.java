package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.OutfitCombination;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface OutfitCombinationRepository extends JpaRepository<OutfitCombination, UUID> {
    List<OutfitCombination> findByIsSharedTrueOrderByCreatedAtDesc();
    List<OutfitCombination> findByUserTableOrderByCreatedAtDesc(UserTable userTable, Pageable pageable);
}
