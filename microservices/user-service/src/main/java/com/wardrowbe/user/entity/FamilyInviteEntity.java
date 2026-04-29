package com.wardrowbe.user.entity;

import com.wardrowbe.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "family_invites")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FamilyInviteEntity extends BaseEntity {

    @Column(name = "family_id", nullable = false)
    private UUID familyId;

    @Column(name = "email", nullable = false)
    private String email;

    @Column(name = "token", unique = true, nullable = false, length = 100)
    private String token;

    @Column(name = "invited_by", nullable = false)
    private UUID invitedBy;

    @Column(name = "role", length = 20)
    @Builder.Default
    private String role = "member";

    @Column(name = "accepted_at")
    private LocalDateTime acceptedAt;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;
}
