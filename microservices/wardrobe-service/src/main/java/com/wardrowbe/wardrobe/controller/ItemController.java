package com.wardrowbe.wardrobe.controller;

import com.wardrowbe.common.dto.PageResponse;
import com.wardrowbe.wardrobe.entity.ClothingItemEntity;
import com.wardrowbe.wardrobe.service.WardrobeService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/items")
@RequiredArgsConstructor
public class ItemController {

    private final WardrobeService wardrobeService;

    /**
     * List wardrobe items with filtering and pagination.
     */
    @GetMapping
    public ResponseEntity<PageResponse<ClothingItemEntity>> getItems(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Boolean favorite,
            @RequestParam(required = false) Boolean needsWash,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "30") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy) {

        UUID userId = getUserId(jwt);
        Page<ClothingItemEntity> result = wardrobeService.getItems(
                userId, type, status, favorite, needsWash, page, size, sortBy);

        PageResponse<ClothingItemEntity> response = PageResponse.<ClothingItemEntity>builder()
                .items(result.getContent())
                .total(result.getTotalElements())
                .page(page)
                .pageSize(size)
                .hasMore(result.hasNext())
                .build();

        return ResponseEntity.ok(response);
    }

    /**
     * Get a single item by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ClothingItemEntity> getItem(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id) {
        return ResponseEntity.ok(wardrobeService.getItem(getUserId(jwt), id));
    }

    /**
     * Upload a new clothing item with image.
     */
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ClothingItemEntity> createItem(
            @AuthenticationPrincipal Jwt jwt,
            @RequestPart("image") MultipartFile image,
            @RequestPart(value = "name", required = false) String name) throws Exception {

        ClothingItemEntity item = wardrobeService.createItem(getUserId(jwt), image, name);
        return ResponseEntity.status(HttpStatus.CREATED).body(item);
    }

    /**
     * Update an item's details.
     */
    @PatchMapping("/{id}")
    public ResponseEntity<ClothingItemEntity> updateItem(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @RequestBody Map<String, Object> updates) {
        return ResponseEntity.ok(wardrobeService.updateItem(getUserId(jwt), id, updates));
    }

    /**
     * Delete an item.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id) {
        wardrobeService.deleteItem(getUserId(jwt), id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Log that an item was worn.
     */
    @PostMapping("/{id}/wear")
    public ResponseEntity<ClothingItemEntity> logWear(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id) {
        return ResponseEntity.ok(wardrobeService.logWear(getUserId(jwt), id));
    }

    /**
     * Mark an item as washed.
     */
    @PostMapping("/{id}/wash")
    public ResponseEntity<ClothingItemEntity> markWashed(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id) {
        return ResponseEntity.ok(wardrobeService.markWashed(getUserId(jwt), id));
    }

    /**
     * Archive an item.
     */
    @PostMapping("/{id}/archive")
    public ResponseEntity<ClothingItemEntity> archiveItem(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        String reason = body != null ? body.get("reason") : null;
        return ResponseEntity.ok(wardrobeService.archiveItem(getUserId(jwt), id, reason));
    }

    /**
     * Restore an archived item.
     */
    @PostMapping("/{id}/restore")
    public ResponseEntity<ClothingItemEntity> restoreItem(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id) {
        return ResponseEntity.ok(wardrobeService.restoreItem(getUserId(jwt), id));
    }

    /**
     * Get items that need washing.
     */
    @GetMapping("/needs-wash")
    public ResponseEntity<List<ClothingItemEntity>> getNeedsWash(
            @AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(wardrobeService.getNeedsWashItems(getUserId(jwt)));
    }

    // --- Helper to extract user ID from JWT ---
    // In production, you'd resolve this through the user-service
    private UUID getUserId(Jwt jwt) {
        // The JWT subject from Keycloak is the user's external ID
        // For now we use it directly; in production, call user-service to get internal UUID
        return UUID.fromString(jwt.getSubject());
    }
}
