package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

// 옷 스타일(캐주얼, 데일리 등) 테이블
@Entity
@Table(name = "style_code")
public class StyleCode {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID styleId;

    @OneToMany(mappedBy = "styleCode", cascade = CascadeType.ALL)
    private List<ClothesTable> clothesTableList = new ArrayList<>();

    @Column(name = "style_name", nullable = false, length = 50)
    private String styleName;

    @Column(name = "created_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime createdAt;

    public UUID getStyleId() { return styleId; }
    public List<ClothesTable> getClothesTableList() { return clothesTableList; }
    public String getStyleName() { return styleName; }
    public OffsetDateTime getCreatedAt() { return createdAt; }

    public void setStyleId(UUID styleId) { this.styleId = styleId; }
    public void setClothesTableList(List<ClothesTable> clothesTableList) { this.clothesTableList = clothesTableList; }
    public void setStyleName(String styleName) { this.styleName = styleName; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
