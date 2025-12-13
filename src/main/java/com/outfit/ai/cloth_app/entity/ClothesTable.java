package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.UUID;

// 옷 테이블
@Entity
@Table(name="clothes_table")
public class ClothesTable {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID clothId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserTable userTable;

    // 옷 카테고리
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private CategoryCode categoryCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "color_id")
    private ColorCode colorCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "material_id")
    private MaterialCode materialCode;

    // 옷 스타일
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "style_id")
    private StyleCode styleCode;

    // 계절
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "season_id")
    private SeasonCode seasonCode;

    // 옷 종류
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_type_id")
    private ItemTypeCode itemTypeCode;

    // 옷 별명
    @Column(name = "name", nullable = false, length = 255)
    private String clothName;

    @Column(name = "image_url", columnDefinition = "text")
    private String imageUrl;

    @Column(name = "created_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime createdAt;

    public ClothesTable() {}

    public UUID getClothId() { return clothId; }
    public void setClothId(UUID clothId) { this.clothId = clothId; }

    public UserTable getUserTable() { return userTable; }
    public void setUserTable(UserTable userTable) { this.userTable = userTable; }

    public CategoryCode getCategoryCode() { return categoryCode; }
    public void setCategoryCode(CategoryCode categoryCode) { this.categoryCode = categoryCode; }

    public ColorCode getColorCode() { return colorCode; }
    public void setColorCode(ColorCode colorCode) { this.colorCode = colorCode; }

    public MaterialCode getMaterialCode() { return materialCode; }
    public void setMaterialCode(MaterialCode materialCode) { this.materialCode = materialCode; }

    public StyleCode getStyleCode() { return styleCode; }
    public void setStyleCode(StyleCode styleCode) { this.styleCode = styleCode; }

    public SeasonCode getSeasonCode() { return seasonCode; }
    public void setSeasonCode(SeasonCode seasonCode) { this.seasonCode = seasonCode; }

    public ItemTypeCode getItemTypeCode() { return itemTypeCode; }
    public void setItemTypeCode(ItemTypeCode itemTypeCode) { this.itemTypeCode = itemTypeCode; }

    public String getClothName() { return clothName; }
    public void setClothName(String clothName) { this.clothName = clothName; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
}
