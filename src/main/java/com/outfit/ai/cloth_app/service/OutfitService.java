package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.dto.RecentOutfitDto;
import com.outfit.ai.cloth_app.repository.OutfitCombinationRepository;
import com.outfit.ai.cloth_app.repository.UserRepository;
import com.outfit.ai.cloth_app.entity.OutfitCombination;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

// 옷조합 서비스
@Service
public class OutfitService {
    private final OutfitCombinationRepository outfitCombinationRepository;
    private  final UserRepository userRepository;
    private final Logger logger = LoggerFactory.getLogger(OutfitService.class);

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yy.MM.dd");

    private OutfitService(OutfitCombinationRepository outfitCombinationRepository, UserRepository userRepository) {
        this.outfitCombinationRepository = outfitCombinationRepository;
        this.userRepository = userRepository;
    }

    // 최근 옷조합 불러오기
    // limit은 한번에 불러올 옷조합 최대 수치
    public List<RecentOutfitDto> getRecentOutfits(String userIdentifier, int limit) {
        UUID userId;
        try {
            userId = UUID.fromString(userIdentifier);
        } catch (IllegalArgumentException e) {
            logger.error("Invalid user ID format: {}", userIdentifier);
            return List.of();
        }

        Optional<UserTable> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            return List.of();
        }
        UserTable currentUser = userOptional.get();

        Pageable pageable = PageRequest.of(0, limit);

        List<OutfitCombination> recentOutfits = outfitCombinationRepository
                .findByUserTableOrderByCreatedAtDesc(currentUser, pageable);

        return recentOutfits.stream()
                .map(this::convertToDto)
                .toList();
    }

    private RecentOutfitDto convertToDto(OutfitCombination entity) {
        String outfitNamePlaceholder = "나의 조합 " + entity.getOutfitId().toString().substring(0, 4);

        return new RecentOutfitDto(
                entity.getOutfitId(),
                outfitNamePlaceholder,
                entity.getAiGenImageUrl(),
                entity.getCreatedAt().format(DATE_FORMATTER)
        );
    }
}
