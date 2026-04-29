package com.wardrowbe.user.repository;

import com.wardrowbe.user.entity.FamilyEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface FamilyRepository extends JpaRepository<FamilyEntity, UUID> {
    Optional<FamilyEntity> findByInviteCode(String inviteCode);
}
