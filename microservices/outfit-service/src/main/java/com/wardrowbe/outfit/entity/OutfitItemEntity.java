package com.wardrowbe.outfit.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "outfit_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OutfitItemEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "outfit_id", nullable = false)
    private OutfitEntity outfit;

    @Column(name = "item_id", nullable = false)
    private UUID itemId;

    @Column(name = "position")
    private Integer position;

    @Column(name = "layer_type", length = 50)
    private String layerType;
}
