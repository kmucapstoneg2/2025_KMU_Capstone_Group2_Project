package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.CategoryCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CategoryRepository extends JpaRepository<CategoryCode, Integer> {
    Optional<CategoryCode> findByCategoryName(String name);
}
