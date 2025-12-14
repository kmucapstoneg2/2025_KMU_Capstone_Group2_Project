package com.outfit.ai.cloth_app.dto.request;

// 회원가입 요청 DTO
public class SignUpRequestDto {
    private String email;
    private String password;
    private String username;
    private String region;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
}