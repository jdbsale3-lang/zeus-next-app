-- 0067: Shopify sync tables — additive, live-safe.
CREATE TABLE IF NOT EXISTS shopify_products (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  handle TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  variants_json TEXT,
  created_at TEXT,
  updated_at TEXT,
  synced_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS shopify_sync_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  finished_at TEXT,
  status TEXT NOT NULL DEFAULT 'running',
  products_seen INTEGER NOT NULL DEFAULT 0,
  products_upserted INTEGER NOT NULL DEFAULT 0,
  orders_seen INTEGER NOT NULL DEFAULT 0,
  notes TEXT
);