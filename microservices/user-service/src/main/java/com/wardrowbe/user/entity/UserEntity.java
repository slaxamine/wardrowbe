package com.wardrowbe.user.entity;

import com.wardrowbe.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserEntity extends BaseEntity {

    @Column(name = "external_id", unique = true, nullable = false)
    private String externalId;

    @Column(name = "email", unique = true, nullable = false)
    private String email;

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Column(name = "role", length = 20)
    @Builder.Default
    private String role = "member";

    @Column(name = "timezone", length = 50)
    @Builder.Default
    private String timezone = "UTC";

    @Column(name = "location_lat", precision = 10, scale = 8)
    private BigDecimal locationLat;

    @Column(name = "location_lon", precision = 11, scale = 8)
    private BigDecimal locationLon;

    @Column(name = "location_name", length = 100)
    private String locationName;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    @Column(name = "onboarding_completed")
    @Builder.Default
    private Boolean onboardingCompleted = false;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "body_measurements", columnDefinition = "jsonb")
    private Map<String, Object> bodyMeasurements;

    @Column(name = "family_id")
    private UUID familyId;
}
