package com.wardrowbe.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private UUID id;
    private String externalId;
    private String email;
    private String displayName;
    private String avatarUrl;
    private String role;
    private String timezone;
    private BigDecimal locationLat;
    private BigDecimal locationLon;
    private String locationName;
    private Boolean isActive;
    private Boolean onboardingCompleted;
    private Map<String, Object> bodyMeasurements;
    private UUID familyId;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

// --- Nested DTOs for requests ---

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class UpdateUserRequest {
    @Size(max = 100)
    private String displayName;

    @Size(max = 500)
    private String avatarUrl;

    @Size(max = 50)
    private String timezone;

    private Boolean onboardingCompleted;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class UpdateLocationRequest {
    private BigDecimal lat;
    private BigDecimal lon;

    @Size(max = 100)
    private String name;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class UpdateMeasurementsRequest {
    private Map<String, Object> measurements;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class CreateFamilyRequest {
    @Size(min = 1, max = 100)
    private String name;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class JoinFamilyRequest {
    private String inviteCode;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class InviteMemberRequest {
    @Email
    private String email;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class FamilyDto {
    private UUID id;
    private String name;
    private String inviteCode;
    private java.util.List<FamilyMemberDto> members;
    private java.util.List<PendingInviteDto> pendingInvites;
    private LocalDateTime createdAt;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class FamilyMemberDto {
    private UUID id;
    private String displayName;
    private String email;
    private String avatarUrl;
    private String role;
    private LocalDateTime createdAt;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class PendingInviteDto {
    private UUID id;
    private String email;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
}
