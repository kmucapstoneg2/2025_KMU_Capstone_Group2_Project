package com.outfit.ai.cloth_app.entity;

import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import org.hibernate.annotations.Type;

import java.util.ArrayList;
import java.util.List;

// 날씨 테이블
@Entity
@Table(name="weather")
public class Weather {
    @EmbeddedId
    private WeatherId weatherId;

    @OneToMany(mappedBy = "weather", cascade = CascadeType.ALL)
    private List<OutfitCombination> outfitCombinations = new ArrayList<>();

    @Type(JsonType.class)
    @Column(name = "weather_data", columnDefinition = "jsonb", nullable = false)
    private String weatherData;

    @Column(name = "location_key", length = 255)
    private String locationKey;

    public Weather() {}

    public WeatherId getId() { return weatherId; }
    public void setId(WeatherId weatherId) { this.weatherId = weatherId; }

    public List<OutfitCombination> getOutfitCombinations() { return outfitCombinations; }
    public void setOutfitCombinations(List<OutfitCombination> outfitCombinations) { this.outfitCombinations = outfitCombinations; }

    public String getWeatherData() { return weatherData; }
    public void setWeatherData(String weatherData) { this.weatherData = weatherData; }

    public String getLocationKey() { return locationKey; }
    public void setLocationKey(String locationKey) { this.locationKey = locationKey; }
}
