-- 0054: SEO Task Force batch state — lets the live board run the 50 SEO agents
-- in visible waves and remember where the batch is across polls.
CREATE TABLE IF NOT EXISTS seo_batch_state (
  id TEXT PRIMARY KEY,              -- fixed key 'current'
  org_id TEXT NOT NULL,
  cursor INTEGER NOT NULL DEFAULT 0,
  total INTEGER NOT NULL DEFAULT 50,
  status TEXT NOT NULL DEFAULT 'idle',   -- idle | running | done
  keyword TEXT NOT NULL DEFAULT '',
  started_at TEXT,
  finished_at TEXT
);
INSERT OR IGNORE INTO seo_batch_state (id, org_id, cursor, total, status, keyword) VALUES ('current', 'org_zeus_shared', 0, 50, 'idle', '');