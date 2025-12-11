package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.SeasonCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface SeasonCodeRepository extends JpaRepository<SeasonCode, UUID> {
    Optional<SeasonCode> findBySeasonName(String name);
}
