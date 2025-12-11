package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

// 옷 재질 테이블
@Entity
@Table(name="material_code")
public class MaterialCode {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int materialId;

    @Column(name = "material_name", nullable = false, unique = true, length = 255)
    private String materialName;

    public MaterialCode() {}

    public int getMaterialId() { return materialId; }
    public void setMaterialId(int materialId) { this.materialId = materialId; }

    public String getMaterialName() { return materialName; }
    public void setMaterialName(String materialName) { this.materialName = materialName; }
}
