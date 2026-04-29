package com.wardrowbe.user.controller;

import com.wardrowbe.user.dto.UserDto;
import com.wardrowbe.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * Get current authenticated user profile.
     * Creates user on first login from JWT claims.
     */
    @GetMapping("/me")
    public ResponseEntity<UserDto> getCurrentUser(@AuthenticationPrincipal Jwt jwt) {
        String externalId = jwt.getSubject();
        String email = jwt.getClaimAsString("email");
        String name = jwt.getClaimAsString("preferred_username");
        if (name == null) name = jwt.getClaimAsString("name");
        if (name == null) name = email;

        UserDto user = userService.getOrCreateUser(externalId, email, name);
        userService.recordLogin(user.getId());
        return ResponseEntity.ok(user);
    }

    /**
     * Update current user profile.
     */
    @PatchMapping("/me")
    public ResponseEntity<UserDto> updateProfile(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> updates) {

        UserDto currentUser = userService.getUserByExternalId(jwt.getSubject());

        UserDto updated = userService.updateProfile(
                currentUser.getId(),
                (String) updates.get("displayName"),
                (String) updates.get("avatarUrl"),
                (String) updates.get("timezone"),
                updates.containsKey("onboardingCompleted")
                        ? (Boolean) updates.get("onboardingCompleted")
                        : null
        );
        return ResponseEntity.ok(updated);
    }

    /**
     * Set user location for weather-based recommendations.
     */
    @PutMapping("/me/location")
    public ResponseEntity<UserDto> updateLocation(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> body) {

        UserDto currentUser = userService.getUserByExternalId(jwt.getSubject());

        BigDecimal lat = new BigDecimal(body.get("lat").toString());
        BigDecimal lon = new BigDecimal(body.get("lon").toString());
        String name = (String) body.get("name");

        UserDto updated = userService.updateLocation(currentUser.getId(), lat, lon, name);
        return ResponseEntity.ok(updated);
    }

    /**
     * Set body measurements for size-aware recommendations.
     */
    @PutMapping("/me/measurements")
    @SuppressWarnings("unchecked")
    public ResponseEntity<UserDto> updateMeasurements(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> body) {

        UserDto currentUser = userService.getUserByExternalId(jwt.getSubject());
        Map<String, Object> measurements = (Map<String, Object>) body.get("measurements");

        UserDto updated = userService.updateMeasurements(currentUser.getId(), measurements);
        return ResponseEntity.ok(updated);
    }
}
