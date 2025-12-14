package com.outfit.ai.cloth_app.dto.response;

import java.util.List;

// 옷 리스트 응답 DTO
public class ClothesListResponseDto {
    private List<ClothesItemDto> clothes;
    private int totalCount;

    public List<ClothesItemDto> getClothes() { return clothes; }
    public void setClothes(List<ClothesItemDto> clothes) { this.clothes = clothes; }

    public int getTotalCount() { return totalCount; }
    public void setTotalCount(int totalCount) { this.totalCount = totalCount; }
}