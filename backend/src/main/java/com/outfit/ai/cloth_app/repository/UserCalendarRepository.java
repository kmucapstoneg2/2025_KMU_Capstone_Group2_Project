package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.UserCalendar;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserCalendarRepository extends JpaRepository<UserCalendar, UUID> {
    boolean existsByGoogleEventId(String googleEventId);
    List<UserCalendar> findByUserTable(UserTable userTable);
}
