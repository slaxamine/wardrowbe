package com.wardrowbe.wardrobe.entity;

import com.wardrowbe.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "clothing_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClothingItemEntity extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    // --- Image paths ---
    @Column(name = "image_path", nullable = false, length = 500)
    private String imagePath;

    @Column(name = "thumbnail_path", length = 500)
    private String thumbnailPath;

    @Column(name = "medium_path", length = 500)
    private String mediumPath;

    @Column(name = "image_hash", length = 16)
    private String imageHash;

    // --- Classification ---
    @Column(name = "type", nullable = false, length = 50)
    private String type;

    @Column(name = "subtype", length = 50)
    private String subtype;

    // --- Tags and attributes ---
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "tags", columnDefinition = "jsonb")
    @Builder.Default
    private Map<String, Object> tags = Map.of();

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "colors", columnDefinition = "text[]")
    private List<String> colors;

    @Column(name = "primary_color", length = 50)
    private String primaryColor;

    @Column(name = "pattern", length = 50)
    private String pattern;

    @Column(name = "material", length = 50)
    private String material;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "style", columnDefinition = "text[]")
    private List<String> style;

    @Column(name = "formality", length = 50)
    private String formality;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "season", columnDefinition = "text[]")
    private List<String> season;

    // --- AI metadata ---
    @Column(name = "status", length = 20)
    @Builder.Default
    private String status = "processing";

    @Column(name = "ai_processed")
    @Builder.Default
    private Boolean aiProcessed = false;

    @Column(name = "ai_confidence", precision = 3, scale = 2)
    private BigDecimal aiConfidence;

    @Column(name = "ai_description", columnDefinition = "text")
    private String aiDescription;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "ai_raw_response", columnDefinition = "jsonb")
    private Map<String, Object> aiRawResponse;

    // --- Usage tracking ---
    @Column(name = "wear_count")
    @Builder.Default
    private Integer wearCount = 0;

    @Column(name = "last_worn_at")
    private LocalDate lastWornAt;

    @Column(name = "wears_since_wash")
    @Builder.Default
    private Integer wearsSinceWash = 0;

    @Column(name = "needs_wash")
    @Builder.Default
    private Boolean needsWash = false;

    @Column(name = "wash_interval")
    private Integer washInterval;

    @Column(name = "last_washed_at")
    private LocalDate lastWashedAt;

    // --- User metadata ---
    @Column(name = "name", length = 100)
    private String name;

    @Column(name = "brand", length = 100)
    private String brand;

    @Column(name = "purchase_price", precision = 10, scale = 2)
    private BigDecimal purchasePrice;

    @Column(name = "purchase_date")
    private LocalDate purchaseDate;

    @Column(name = "notes", columnDefinition = "text")
    private String notes;

    @Column(name = "favorite")
    @Builder.Default
    private Boolean favorite = false;

    // --- Lifecycle ---
    @Column(name = "is_archived")
    @Builder.Default
    private Boolean isArchived = false;

    @Column(name = "archive_reason", length = 50)
    private String archiveReason;
}
