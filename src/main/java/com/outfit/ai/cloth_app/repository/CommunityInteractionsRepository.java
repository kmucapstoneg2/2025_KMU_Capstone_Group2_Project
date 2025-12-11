package com.outfit.ai.cloth_app.repository;

import com.outfit.ai.cloth_app.entity.CommunityInteractions;
import com.outfit.ai.cloth_app.entity.OutfitCombination;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface CommunityInteractionsRepository extends JpaRepository<CommunityInteractions, UUID> {
    Optional<CommunityInteractions> findByOutfitCombinationAndInteractionTypeOrderByCreatedAtAsc(
            OutfitCombination outfitCombination, String interactionType);

    long countByParentAndInteractionType(CommunityInteractions parent, String interactionType);
}
