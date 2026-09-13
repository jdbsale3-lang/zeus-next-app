-- 0022: Web research tool — fetched pages cache.
CREATE TABLE IF NOT EXISTS web_pages (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  url TEXT NOT NULL,
  title TEXT,
  content TEXT,
  fetched_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_web_pages_org ON web_pages(org_id, fetched_at);