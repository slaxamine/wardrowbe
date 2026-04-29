-- Flyway migration: Create outfits schema
-- V1__init_outfits.sql

CREATE TABLE IF NOT EXISTS outfits (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    occasion        VARCHAR(50),
    weather_data    JSONB,
    scheduled_for   DATE,
    reasoning       TEXT,
    style_notes     TEXT,
    ai_raw_response JSONB,
    source          VARCHAR(20) DEFAULT 'on_demand',
    status          VARCHAR(20) DEFAULT 'pending',
    source_item_id  UUID,
    name            VARCHAR(200),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS outfit_items (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id  UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    item_id    UUID NOT NULL,
    position   INTEGER,
    layer_type VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS user_feedback (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id                 UUID NOT NULL UNIQUE REFERENCES outfits(id) ON DELETE CASCADE,
    accepted                  BOOLEAN,
    rating                    INTEGER CHECK (rating BETWEEN 1 AND 5),
    comfort_rating            INTEGER CHECK (comfort_rating BETWEEN 1 AND 5),
    style_rating              INTEGER CHECK (style_rating BETWEEN 1 AND 5),
    comment                   TEXT,
    actually_worn             BOOLEAN,
    worn_at                   DATE,
    worn_with_modifications   BOOLEAN,
    modifications_description TEXT,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS family_outfit_ratings (
    id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    user_id   UUID NOT NULL,
    rating    INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment   TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (outfit_id, user_id)
);

-- Indexes
CREATE INDEX idx_outfits_user_id ON outfits(user_id);
CREATE INDEX idx_outfits_user_occasion ON outfits(user_id, occasion);
CREATE INDEX idx_outfits_user_date ON outfits(user_id, scheduled_for);
CREATE INDEX idx_outfits_status ON outfits(user_id, status);
CREATE INDEX idx_outfit_items_outfit ON outfit_items(outfit_id);
CREATE INDEX idx_outfit_items_item ON outfit_items(item_id);
CREATE INDEX idx_feedback_outfit ON user_feedback(outfit_id);
