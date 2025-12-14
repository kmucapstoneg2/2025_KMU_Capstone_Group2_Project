package com.outfit.ai.cloth_app.dto.response;

import java.time.OffsetDateTime;

// 마이페이지 프로필 응답 DTO
public class MyPageProfileResponseDto {
    private String userName;
    private String email;
    private String region;
    private String profileImageUrl;
    private OffsetDateTime createdAt;

    public MyPageProfileResponseDto(String userName, String email, String region, String profileImageUrl, OffsetDateTime createdAt) {
        this.userName = userName;
        this.email = email;
        this.region = region;
        this.profileImageUrl = profileImageUrl;
        this.createdAt = createdAt;
    }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public String getProfileImageUrl() { return profileImageUrl; }
    public void setProfileImageUrl(String profileImageUrl) { this.profileImageUrl = profileImageUrl; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}