package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

// 옷 색깔 테이블
@Entity
@Table(name="color_code")
public class ColorCode {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int colorId;

    @Column(name = "color_name", nullable = false, unique = true, length = 255)
    private String colorName;

    @Column(name = "hex_code", unique = true, length = 255)
    private String hexCode;

    public ColorCode() {}

    public int getColorId() { return colorId; }
    public void setColorId(int colorId) { this.colorId = colorId; }

    public String getColorName() { return colorName; }
    public void setColorName(String colorName) { this.colorName = colorName; }

    public String getHexCode() { return hexCode; }
    public void setHexCode(String hexCode) { this.hexCode = hexCode; }
}
