package com.wardrowbe.outfit.entity;

import com.wardrowbe.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "outfits")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OutfitEntity extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "occasion", length = 50)
    private String occasion;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "weather_data", columnDefinition = "jsonb")
    private Map<String, Object> weatherData;

    @Column(name = "scheduled_for")
    private LocalDate scheduledFor;

    @Column(name = "reasoning", columnDefinition = "text")
    private String reasoning;

    @Column(name = "style_notes", columnDefinition = "text")
    private String styleNotes;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "ai_raw_response", columnDefinition = "jsonb")
    private Map<String, Object> aiRawResponse;

    @Column(name = "source", length = 20)
    @Builder.Default
    private String source = "on_demand";

    @Column(name = "status", length = 20)
    @Builder.Default
    private String status = "pending";

    @Column(name = "source_item_id")
    private UUID sourceItemId;

    @Column(name = "name", length = 200)
    private String name;

    @OneToMany(mappedBy = "outfit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<OutfitItemEntity> items = new ArrayList<>();

    @OneToOne(mappedBy = "outfit", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private UserFeedbackEntity feedback;
}
