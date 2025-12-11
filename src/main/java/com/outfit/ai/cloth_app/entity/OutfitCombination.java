package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.UUID;

// 옷 조합 테이블
@Entity
@Table(name="outfit_combination")
public class OutfitCombination {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID outfitId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserTable userTable;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns({
            @JoinColumn(name = "weather_id", referencedColumnName = "weather_id"),
            @JoinColumn(name = "weather_created_at", referencedColumnName = "created_at")
    })
    private Weather weather;

    @Column(name = "is_shared", columnDefinition = "boolean default false")
    private Boolean isShared;

    @Column(name = "ai_gen_image_url", columnDefinition = "text")
    private String aiGenImageUrl;

    @Column(name = "like_count", columnDefinition = "int default 0")
    private int likeCount;

    //@Type(JsonType.class)
    @Column(name = "cloth_ids", nullable = false, columnDefinition = "jsonb")
    String clothIds;

    //@Type(JsonType.class)
    @Column(name = "jsonb_data", columnDefinition = "jsonb")
    private String jsonbData;

    @Column(name = "created_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime createdAt;

    public UUID getOutfitId() { return outfitId; }
    public void setOutfitId(UUID outfitId) { this.outfitId = outfitId; }

    public UserTable getUserTable() { return userTable; }
    public void setUserTable(UserTable userTable) { this.userTable = userTable; }

    public Weather getWeather() { return weather; }
    public void setWeather(Weather weather) { this.weather = weather; }

    public Boolean getShared() { return isShared; }
    public void setShared(Boolean shared) { isShared = shared; }

    public String getAiGenImageUrl() { return aiGenImageUrl; }
    public void setAiGenImageUrl(String aiGenImageUrl) { this.aiGenImageUrl = aiGenImageUrl; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public String getClothIds() {return clothIds; }
    public void setClothIds(String clothIds) { this.clothIds = clothIds; }

    public String getJsonbData() { return jsonbData; }
    public void setJsonbData(String jsonbData) { this.jsonbData = jsonbData; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

}
