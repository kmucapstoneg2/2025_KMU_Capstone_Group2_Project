package com.outfit.ai.cloth_app.dto;

import com.outfit.ai.cloth_app.entity.OutfitCombination;

import java.util.ArrayList;
import java.util.List;

// 게시글 DTO
public class CommunityDto {
    private String id;
    private String author;
    private String content;
    private String imageUrl;
    private int likeCount;
    private Boolean isShared;
    private List<CommentDto> comments = new ArrayList<>();

    public CommunityDto() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Boolean getIsShared() { return isShared; }
    public void setShared(Boolean shared) { isShared = shared; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public void setComments(List<CommentDto> comments) { this.comments = comments; }
    public List<CommentDto> getComments() { return comments; }

    public static CommunityDto fromEntity(OutfitCombination outfit) {
        CommunityDto dto = new CommunityDto();

        dto.setId(outfit.getOutfitId().toString());

        if (outfit.getUserTable() != null) {
            dto.setAuthor(outfit.getUserTable().getUsername());
        }

        dto.setImageUrl(outfit.getAiGenImageUrl());
        dto.setLikeCount(outfit.getLikeCount());

        return dto;
    }
}