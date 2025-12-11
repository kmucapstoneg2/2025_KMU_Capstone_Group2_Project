package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<UserTable, UUID> {
    boolean existsByEmail(String email);
    Optional<UserTable> findByEmail(String email);
    Optional<UserTable> findByUsername(String username);
}