package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.Weather;
import com.outfit.ai.cloth_app.entity.WeatherId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WeatherRepository extends JpaRepository<Weather, WeatherId> {
    List<Weather> findByLocationKeyOrderByWeatherId_CreatedAtDesc(String locationKey);
    Optional<Weather> findTopByLocationKeyOrderByWeatherId_CreatedAtDesc(String locationKey);
}
