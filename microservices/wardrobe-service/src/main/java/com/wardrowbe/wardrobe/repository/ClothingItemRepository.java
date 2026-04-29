package com.wardrowbe.wardrobe.repository;

import com.wardrowbe.wardrobe.entity.ClothingItemEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClothingItemRepository extends JpaRepository<ClothingItemEntity, UUID>,
        JpaSpecificationExecutor<ClothingItemEntity> {

    Page<ClothingItemEntity> findByUserIdAndIsArchivedFalse(UUID userId, Pageable pageable);

    Page<ClothingItemEntity> findByUserIdAndType(UUID userId, String type, Pageable pageable);

    List<ClothingItemEntity> findByUserIdAndStatusAndIsArchivedFalse(UUID userId, String status);

    List<ClothingItemEntity> findByUserIdAndNeedsWashTrue(UUID userId);

    List<ClothingItemEntity> findByUserIdAndFavoriteTrue(UUID userId);

    @Modifying
    @Query("UPDATE ClothingItemEntity i SET i.wearCount = i.wearCount + 1, " +
           "i.wearsSinceWash = i.wearsSinceWash + 1, i.lastWornAt = CURRENT_DATE " +
           "WHERE i.id = :id")
    void incrementWearCount(@Param("id") UUID id);

    @Modifying
    @Query("UPDATE ClothingItemEntity i SET i.wearsSinceWash = 0, i.needsWash = false, " +
           "i.lastWashedAt = CURRENT_DATE WHERE i.id = :id")
    void markWashed(@Param("id") UUID id);

    long countByUserId(UUID userId);

    long countByUserIdAndType(UUID userId, String type);
}
