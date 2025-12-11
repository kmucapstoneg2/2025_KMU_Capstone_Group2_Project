package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.MessageTable;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface MessageTableRepository extends JpaRepository<MessageTable, UUID> {
    // FIXED: 메시지 조회를 receiver user의 id 기준으로 하도록 메서드명 변경
    List<MessageTable> findByReceiverUserId(UUID userId);
    List<MessageTable> findBySenderUserId(UUID serId);
    List<MessageTable> findByReceiver(UserTable receiver);
    List<MessageTable> findBySender(UserTable sender);
}
