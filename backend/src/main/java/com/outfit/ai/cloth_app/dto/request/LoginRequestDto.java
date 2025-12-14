package com.outfit.ai.cloth_app.dto.request;

// 로그인 요청 DTO
public class LoginRequestDto {
    private String email;
    private String password;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}