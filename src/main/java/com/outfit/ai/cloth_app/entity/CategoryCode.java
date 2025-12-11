package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

// 옷 카테고리(상하의, 아우터, 신발) 테이블
@Entity
@Table(name="category_code")
public class CategoryCode {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int categoryId;

    @Column(name = "category_name", nullable = false, unique = true, length = 255)
    private String categoryName;

    public CategoryCode() {}

    public int getCategoryId() {
        return categoryId;
    }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() {
        return categoryName;
    }
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
}
