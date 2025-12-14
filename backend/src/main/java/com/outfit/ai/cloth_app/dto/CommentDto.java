package com.outfit.ai.cloth_app.dto;

import com.outfit.ai.cloth_app.entity.CommunityInteractions;

// 댓글 DTO
public class CommentDto {
    private String id;
    private String author;
    private String content;
    private int likes = 0;
    private int dislikes = 0;

    public CommentDto() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getLikes() { return likes; }
    public void setLikes(int likes) { this.likes = likes; }

    public int getDislikes() { return dislikes; }
    public void setDislikes(int dislikes) { this.dislikes = dislikes; }

    public static CommentDto fromEntity(CommunityInteractions interactions, int likes, int dislikes) {
        CommentDto dto = new CommentDto();

        dto.setId(interactions.getInteractionId().toString());
        dto.setContent(interactions.getContent());

        if (interactions.getUserTable() != null) {
            dto.setAuthor(interactions.getUserTable().getUsername());
        }

        dto.setLikes(likes);
        dto.setDislikes(dislikes);

        return dto;
    }
}