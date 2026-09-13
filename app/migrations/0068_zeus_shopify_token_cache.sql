-- 0068: Shopify OAuth token cache — supports short-lived client-credentials
-- tokens. The refresh loop mints on demand and stores the token + expiry so
-- Admin API calls reuse it until near-expiry, then re-mint. Live-safe.
CREATE TABLE IF NOT EXISTS shopify_token_cache (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  access_token TEXT NOT NULL,
  minted_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT,
  scope TEXT
);

INSERT OR IGNORE INTO shopify_token_cache (id, access_token, expires_at)
VALUES (1, 'none', NULL);