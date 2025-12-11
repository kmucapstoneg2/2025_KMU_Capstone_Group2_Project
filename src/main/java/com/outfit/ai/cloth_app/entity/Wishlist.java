package com.outfit.ai.cloth_app.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.UUID;

// 위시리스트 테이블
@Entity
@Table(name="wishlist")
public class Wishlist {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID wishlistId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserTable userTable;

    @Column(name = "product_link", nullable = false, columnDefinition = "text")
    private String productLink;

    @Column(name = "added_at", columnDefinition = "timestamptz default current_timestamp")
    private OffsetDateTime addedAt;

    public UUID getWishlistId() { return wishlistId; }
    public void setWishlistId(UUID wishlistId) { this.wishlistId = wishlistId; }

    public UserTable getUserTable() { return userTable; }
    public void setUserTable(UserTable userTable) { this.userTable = userTable; }

    public String getProductLink() { return productLink; }
    public void setProductLink(String productLink) { this.productLink = productLink; }

    public OffsetDateTime getAddedAt() { return addedAt; }
    public void setAddedAt(OffsetDateTime addedAt) { this.addedAt = addedAt; }
}
