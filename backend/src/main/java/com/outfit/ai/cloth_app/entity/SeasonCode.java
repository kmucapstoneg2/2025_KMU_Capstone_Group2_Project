package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

// 계절(봄, 여름, 가을, 겨울, 사계절 등) 테이블
@Entity
@Table(name = "season_code")
public class SeasonCode {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID seasonId;

    @OneToMany(mappedBy = "seasonCode", cascade = CascadeType.ALL)
    private List<ClothesTable> clothesTableList = new ArrayList<>();

    @Column(name = "season_name", nullable = false, length = 50)
    private String seasonName;

    @Column(name = "created_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime createdAt;

    public UUID getSeasonId() { return seasonId; }
    public List<ClothesTable> getClothesTableList() { return clothesTableList; }
    public String getSeasonName() { return seasonName; }
    public OffsetDateTime getCreatedAt() { return createdAt; }

    public void setSeasonId(UUID seasonId) { this.seasonId = seasonId; }
    public void setClothesTableList(List<ClothesTable> clothesTableList) { this.clothesTableList = clothesTableList; }
    public void setSeasonName(String seasonName) { this.seasonName = seasonName; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
