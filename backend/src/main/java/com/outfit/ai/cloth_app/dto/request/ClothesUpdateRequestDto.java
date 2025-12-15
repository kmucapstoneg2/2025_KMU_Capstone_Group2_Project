package com.outfit.ai.cloth_app.dto.request;

/**
 * 옷 정보 수정 요청 DTO (선택 필드만 업데이트)
 */
public class ClothesUpdateRequestDto {
    private String name;
    private String categoryName;
    private String colorName;
    private String materialName;
    private String styleName;
    private String seasonName;
    private String itemTypeName;
    private String imageUrl; // 이미지 교체 시 사용 (이미지 업로드 별도 처리 필요 시 확장)

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

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

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}
