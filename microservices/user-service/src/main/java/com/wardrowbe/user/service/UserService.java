package com.wardrowbe.user.service;

import com.wardrowbe.common.exception.ResourceNotFoundException;
import com.wardrowbe.user.dto.UserDto;
import com.wardrowbe.user.entity.UserEntity;
import com.wardrowbe.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;

    /**
     * Get or create user from JWT claims (called on first login).
     */
    @Transactional
    public UserDto getOrCreateUser(String externalId, String email, String displayName) {
        return userRepository.findByExternalId(externalId)
                .map(this::toDto)
                .orElseGet(() -> {
                    log.info("Creating new user: {} ({})", displayName, email);
                    UserEntity user = UserEntity.builder()
                            .externalId(externalId)
                            .email(email)
                            .displayName(displayName)
                            .build();
                    user = userRepository.save(user);
                    return toDto(user);
                });
    }

    public UserDto getUserById(UUID id) {
        return userRepository.findById(id)
                .map(this::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }

    public UserDto getUserByExternalId(String externalId) {
        return userRepository.findByExternalId(externalId)
                .map(this::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Transactional
    public UserDto updateProfile(UUID userId, String displayName, String avatarUrl,
                                  String timezone, Boolean onboardingCompleted) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        if (displayName != null) user.setDisplayName(displayName);
        if (avatarUrl != null) user.setAvatarUrl(avatarUrl);
        if (timezone != null) user.setTimezone(timezone);
        if (onboardingCompleted != null) user.setOnboardingCompleted(onboardingCompleted);

        user = userRepository.save(user);
        log.info("Updated profile for user {}", userId);
        return toDto(user);
    }

    @Transactional
    public UserDto updateLocation(UUID userId, BigDecimal lat, BigDecimal lon, String name) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        user.setLocationLat(lat);
        user.setLocationLon(lon);
        user.setLocationName(name);
        user = userRepository.save(user);
        log.info("Updated location for user {}: {}", userId, name);
        return toDto(user);
    }

    @Transactional
    public UserDto updateMeasurements(UUID userId, Map<String, Object> measurements) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        user.setBodyMeasurements(measurements);
        user = userRepository.save(user);
        log.info("Updated body measurements for user {}", userId);
        return toDto(user);
    }

    @Transactional
    public void recordLogin(UUID userId) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setLastLoginAt(LocalDateTime.now());
            userRepository.save(user);
        });
    }

    // --- Mapping ---

    private UserDto toDto(UserEntity entity) {
        return UserDto.builder()
                .id(entity.getId())
                .externalId(entity.getExternalId())
                .email(entity.getEmail())
                .displayName(entity.getDisplayName())
                .avatarUrl(entity.getAvatarUrl())
                .role(entity.getRole())
                .timezone(entity.getTimezone())
                .locationLat(entity.getLocationLat())
                .locationLon(entity.getLocationLon())
                .locationName(entity.getLocationName())
                .isActive(entity.getIsActive())
                .onboardingCompleted(entity.getOnboardingCompleted())
                .bodyMeasurements(entity.getBodyMeasurements())
                .familyId(entity.getFamilyId())
                .lastLoginAt(entity.getLastLoginAt())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
