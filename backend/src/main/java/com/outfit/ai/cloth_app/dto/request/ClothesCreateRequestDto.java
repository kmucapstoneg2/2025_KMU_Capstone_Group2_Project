package com.outfit.ai.cloth_app.dto.request;

// 옷 생성 요청 DTO
public class ClothesCreateRequestDto {
    private String name;
    private String categoryName;
    private String materialName;
    private String colorName;
    private String styleName;
    private String seasonName;
    private String itemTypeName;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryCode(String categoryName) { this.categoryName = categoryName; }

    public String getMaterialName() { return materialName; }
    public void setMaterialCode(String materialName) { this.materialName = materialName; }

    public String getColorName() { return colorName; }
    public void setColorCode(String colorName) { this.colorName = colorName; }

    public String getStyleName() { return styleName; }
    public void setStyleName(String styleName) { this.styleName = styleName; }

    public String getSeasonName() { return seasonName; }
    public void setSeasonName(String seasonName) { this.seasonName = seasonName; }

    public String getItemTypeName() { return itemTypeName; }
    public void setItemTypeName(String itemTypeName) { this.itemTypeName = itemTypeName; }
}