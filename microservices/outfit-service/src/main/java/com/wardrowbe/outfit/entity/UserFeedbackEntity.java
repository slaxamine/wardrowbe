package com.wardrowbe.outfit.entity;

import com.wardrowbe.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "user_feedback")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserFeedbackEntity extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "outfit_id", nullable = false, unique = true)
    private OutfitEntity outfit;

    @Column(name = "accepted")
    private Boolean accepted;

    @Column(name = "rating")
    private Integer rating;

    @Column(name = "comfort_rating")
    private Integer comfortRating;

    @Column(name = "style_rating")
    private Integer styleRating;

    @Column(name = "comment", columnDefinition = "text")
    private String comment;

    @Column(name = "actually_worn")
    private Boolean actuallyWorn;

    @Column(name = "worn_at")
    private LocalDate wornAt;

    @Column(name = "worn_with_modifications")
    private Boolean wornWithModifications;

    @Column(name = "modifications_description", columnDefinition = "text")
    private String modificationsDescription;
}
