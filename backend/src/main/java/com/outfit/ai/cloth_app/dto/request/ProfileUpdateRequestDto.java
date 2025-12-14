package com.outfit.ai.cloth_app.dto.request;

// 프로필 수정 요청 DTO
public class ProfileUpdateRequestDto {
    private String username;
    private String region;
    private String profileImageUrl;

    public ProfileUpdateRequestDto() {}

    public ProfileUpdateRequestDto(String username, String region, String profileImageUrl) {
        this.username = username;
        this.region = region;
        this.profileImageUrl = profileImageUrl;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public String getProfileImageUrl() { return profileImageUrl; }
    public void setProfileImageUrl(String profileImageUrl) { this.profileImageUrl = profileImageUrl; }
}
