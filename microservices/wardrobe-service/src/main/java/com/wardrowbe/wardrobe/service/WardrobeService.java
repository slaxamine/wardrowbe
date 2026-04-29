package com.wardrowbe.wardrobe.service;

import com.wardrowbe.common.exception.ResourceNotFoundException;
import com.wardrowbe.wardrobe.entity.ClothingItemEntity;
import com.wardrowbe.wardrobe.repository.ClothingItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class WardrobeService {

    private final ClothingItemRepository itemRepository;
    private final RabbitTemplate rabbitTemplate;

    // --- CRUD ---

    public Page<ClothingItemEntity> getItems(UUID userId, String type, String status,
                                              Boolean favorite, Boolean needsWash,
                                              int page, int size, String sortBy) {
        var pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, sortBy));

        if (type != null && !type.isEmpty()) {
            return itemRepository.findByUserIdAndType(userId, type, pageable);
        }
        return itemRepository.findByUserIdAndIsArchivedFalse(userId, pageable);
    }

    public ClothingItemEntity getItem(UUID userId, UUID itemId) {
        return itemRepository.findById(itemId)
                .filter(item -> item.getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Item", itemId));
    }

    @Transactional
    public ClothingItemEntity createItem(UUID userId, MultipartFile image, String name) throws IOException {
        // Save image to filesystem
        String itemDir = userId + "/" + UUID.randomUUID();
        Path storagePath = Paths.get("/data/wardrobe", itemDir);
        Files.createDirectories(storagePath);

        String originalFilename = image.getOriginalFilename();
        String ext = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf('.'))
                : ".jpg";

        Path imagePath = storagePath.resolve("original" + ext);
        image.transferTo(imagePath.toFile());

        // Create entity
        ClothingItemEntity item = ClothingItemEntity.builder()
                .userId(userId)
                .imagePath(itemDir + "/original" + ext)
                .type("unknown")
                .status("processing")
                .name(name)
                .build();

        item = itemRepository.save(item);
        log.info("Created item {} for user {}", item.getId(), userId);

        // Publish event for AI processing
        Map<String, Object> event = Map.of(
                "eventType", "ITEM_UPLOADED",
                "itemId", item.getId().toString(),
                "userId", userId.toString(),
                "imagePath", item.getImagePath()
        );
        rabbitTemplate.convertAndSend("wardrowbe.events", "item.uploaded", event);
        log.info("Published item.uploaded event for item {}", item.getId());

        return item;
    }

    @Transactional
    public ClothingItemEntity updateItem(UUID userId, UUID itemId, Map<String, Object> updates) {
        ClothingItemEntity item = getItem(userId, itemId);

        if (updates.containsKey("name")) item.setName((String) updates.get("name"));
        if (updates.containsKey("type")) item.setType((String) updates.get("type"));
        if (updates.containsKey("subtype")) item.setSubtype((String) updates.get("subtype"));
        if (updates.containsKey("primaryColor")) item.setPrimaryColor((String) updates.get("primaryColor"));
        if (updates.containsKey("pattern")) item.setPattern((String) updates.get("pattern"));
        if (updates.containsKey("material")) item.setMaterial((String) updates.get("material"));
        if (updates.containsKey("formality")) item.setFormality((String) updates.get("formality"));
        if (updates.containsKey("brand")) item.setBrand((String) updates.get("brand"));
        if (updates.containsKey("notes")) item.setNotes((String) updates.get("notes"));
        if (updates.containsKey("favorite")) item.setFavorite((Boolean) updates.get("favorite"));
        if (updates.containsKey("washInterval")) item.setWashInterval((Integer) updates.get("washInterval"));
        if (updates.containsKey("purchasePrice")) {
            item.setPurchasePrice(new BigDecimal(updates.get("purchasePrice").toString()));
        }
        if (updates.containsKey("colors")) {
            @SuppressWarnings("unchecked")
            List<String> colors = (List<String>) updates.get("colors");
            item.setColors(colors);
        }
        if (updates.containsKey("style")) {
            @SuppressWarnings("unchecked")
            List<String> style = (List<String>) updates.get("style");
            item.setStyle(style);
        }
        if (updates.containsKey("season")) {
            @SuppressWarnings("unchecked")
            List<String> season = (List<String>) updates.get("season");
            item.setSeason(season);
        }

        item = itemRepository.save(item);
        log.info("Updated item {} for user {}", itemId, userId);
        return item;
    }

    @Transactional
    public void deleteItem(UUID userId, UUID itemId) {
        ClothingItemEntity item = getItem(userId, itemId);
        itemRepository.delete(item);
        log.info("Deleted item {} for user {}", itemId, userId);
    }

    // --- Wear & Wash ---

    @Transactional
    public ClothingItemEntity logWear(UUID userId, UUID itemId) {
        ClothingItemEntity item = getItem(userId, itemId);
        item.setWearCount(item.getWearCount() + 1);
        item.setWearsSinceWash(item.getWearsSinceWash() + 1);
        item.setLastWornAt(LocalDate.now());

        if (item.getWashInterval() != null && item.getWearsSinceWash() >= item.getWashInterval()) {
            item.setNeedsWash(true);
        }

        item = itemRepository.save(item);
        log.info("Logged wear for item {} (total: {})", itemId, item.getWearCount());
        return item;
    }

    @Transactional
    public ClothingItemEntity markWashed(UUID userId, UUID itemId) {
        ClothingItemEntity item = getItem(userId, itemId);
        item.setWearsSinceWash(0);
        item.setNeedsWash(false);
        item.setLastWashedAt(LocalDate.now());
        item = itemRepository.save(item);
        log.info("Marked item {} as washed", itemId);
        return item;
    }

    // --- Archive ---

    @Transactional
    public ClothingItemEntity archiveItem(UUID userId, UUID itemId, String reason) {
        ClothingItemEntity item = getItem(userId, itemId);
        item.setIsArchived(true);
        item.setArchiveReason(reason);
        item = itemRepository.save(item);
        log.info("Archived item {} with reason: {}", itemId, reason);
        return item;
    }

    @Transactional
    public ClothingItemEntity restoreItem(UUID userId, UUID itemId) {
        ClothingItemEntity item = itemRepository.findById(itemId)
                .filter(i -> i.getUserId().equals(userId))
                .orElseThrow(() -> new ResourceNotFoundException("Item", itemId));
        item.setIsArchived(false);
        item.setArchiveReason(null);
        item = itemRepository.save(item);
        log.info("Restored item {}", itemId);
        return item;
    }

    // --- Stats ---

    public long countItems(UUID userId) {
        return itemRepository.countByUserId(userId);
    }

    public long countItemsByType(UUID userId, String type) {
        return itemRepository.countByUserIdAndType(userId, type);
    }

    public List<ClothingItemEntity> getNeedsWashItems(UUID userId) {
        return itemRepository.findByUserIdAndNeedsWashTrue(userId);
    }
}
