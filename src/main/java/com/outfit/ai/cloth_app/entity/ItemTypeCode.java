package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

// 옷 종류(맨투맨, 티셔츠 등) 테이블
@Entity
@Table(name = "item_type_code")
public class ItemTypeCode {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID itemTypeId;

    @OneToMany(mappedBy = "itemTypeCode", cascade = CascadeType.ALL)
    private List<ClothesTable> clothesTableList = new ArrayList<>();

    @Column(name = "type_name", nullable = false, length = 50)
    private String itemTypeName;

    @Column(name = "created_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime createdAt;

    public UUID getItemTypeId() { return itemTypeId; }
    public List<ClothesTable> getClothesTableList() { return clothesTableList; }
    public String getItemTypeName() { return itemTypeName; }
    public OffsetDateTime getCreatedAt() { return createdAt; }

    public void setItemTypeId(UUID itemTypeId) { this.itemTypeId = itemTypeId; }
    public void setClothesTableList(List<ClothesTable> clothesTableList) { this.clothesTableList = clothesTableList; }
    public void setItemTypeName(String itemTypeName) { this.itemTypeName = itemTypeName; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
