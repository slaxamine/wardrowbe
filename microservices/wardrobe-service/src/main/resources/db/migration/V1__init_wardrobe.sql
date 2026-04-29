-- Flyway migration: Create wardrobe schema
-- V1__init_wardrobe.sql

CREATE TABLE IF NOT EXISTS clothing_items (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL,
    
    -- Images
    image_path        VARCHAR(500) NOT NULL,
    thumbnail_path    VARCHAR(500),
    medium_path       VARCHAR(500),
    image_hash        VARCHAR(16),
    
    -- Classification
    type              VARCHAR(50) NOT NULL DEFAULT 'unknown',
    subtype           VARCHAR(50),
    tags              JSONB DEFAULT '{}',
    colors            TEXT[],
    primary_color     VARCHAR(50),
    pattern           VARCHAR(50),
    material          VARCHAR(50),
    style             TEXT[],
    formality         VARCHAR(50),
    season            TEXT[],
    
    -- AI metadata
    status            VARCHAR(20) DEFAULT 'processing',
    ai_processed      BOOLEAN DEFAULT FALSE,
    ai_confidence     NUMERIC(3, 2),
    ai_description    TEXT,
    ai_raw_response   JSONB,
    
    -- Usage tracking
    wear_count        INTEGER DEFAULT 0,
    last_worn_at      DATE,
    wears_since_wash  INTEGER DEFAULT 0,
    needs_wash        BOOLEAN DEFAULT FALSE,
    wash_interval     INTEGER,
    last_washed_at    DATE,
    
    -- User metadata
    name              VARCHAR(100),
    brand             VARCHAR(100),
    purchase_price    NUMERIC(10, 2),
    purchase_date     DATE,
    notes             TEXT,
    favorite          BOOLEAN DEFAULT FALSE,
    
    -- Lifecycle
    is_archived       BOOLEAN DEFAULT FALSE,
    archive_reason    VARCHAR(50),
    
    -- Timestamps
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS item_history (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id    UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    outfit_id  UUID,
    worn_at    DATE NOT NULL,
    occasion   VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wash_history (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id    UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    washed_at  DATE NOT NULL,
    method     VARCHAR(50),
    notes      TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_items_user_id ON clothing_items(user_id);
CREATE INDEX idx_items_user_status ON clothing_items(user_id, status);
CREATE INDEX idx_items_user_type ON clothing_items(user_id, type);
CREATE INDEX idx_items_user_archived ON clothing_items(user_id, is_archived);
CREATE INDEX idx_items_needs_wash ON clothing_items(user_id, needs_wash) WHERE needs_wash = TRUE;
CREATE INDEX idx_item_history_item ON item_history(item_id);
CREATE INDEX idx_wash_history_item ON wash_history(item_id);
