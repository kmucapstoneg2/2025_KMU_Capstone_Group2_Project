package com.outfit.ai.cloth_app.dto.response;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

// 옷 정보 응답 DTO
public class ClothesItemDto {
    private UUID clothID;
    private String name;
    private String imageUrl;
    private String categoryName;
    private String colorName;
    private String materialName;
    private String styleName;
    private String seasonName;
    private String itemTypeName;
    private OffsetDateTime createdAt;

    public UUID getClothID() { return clothID; }
    public void setClothID(UUID clothID) { this.clothID = clothID; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getColorName() { return colorName; }
    public void setColorName(String colorName) { this.colorName = colorName; }

    public String getMaterialName() { return materialName; }
    public void setMaterialName(String materialName) { this.materialName = materialName; }

    public String getStyleName() { return styleName; }
    public void setStyleName(String styleName) { this.styleName = styleName; }

    public String getSeasonName() { return seasonName; }
    public void setSeasonName(String seasonName) { this.seasonName = seasonName; }

    public String getItemTypeName() { return itemTypeName; }
    public void setItemTypeName(String itemTypeName) { this.itemTypeName = itemTypeName; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}