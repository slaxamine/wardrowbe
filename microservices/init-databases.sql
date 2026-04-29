-- Initialize multiple databases for microservices
-- This script runs on first PostgreSQL startup

CREATE DATABASE wardrowbe_wardrobe;
CREATE DATABASE wardrowbe_outfits;
CREATE DATABASE wardrowbe_notifications;
CREATE DATABASE wardrowbe_learning;
CREATE DATABASE wardrowbe_keycloak;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE wardrowbe_wardrobe TO wardrobe;
GRANT ALL PRIVILEGES ON DATABASE wardrowbe_outfits TO wardrobe;
GRANT ALL PRIVILEGES ON DATABASE wardrowbe_notifications TO wardrobe;
GRANT ALL PRIVILEGES ON DATABASE wardrowbe_learning TO wardrobe;
GRANT ALL PRIVILEGES ON DATABASE wardrowbe_keycloak TO wardrobe;
