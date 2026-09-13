-- ZEUS site analytics: privacy-light page-view beacon (no IP, no cookies).
-- The client sends path + referrer + a per-browser random session seed + browser family.
CREATE TABLE IF NOT EXISTS zeus_analytics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts TEXT NOT NULL DEFAULT (datetime('now')),
  path TEXT NOT NULL DEFAULT '/',
  ref TEXT NOT NULL DEFAULT '',
  ua TEXT NOT NULL DEFAULT '',
  seed TEXT NOT NULL DEFAULT '',
  bfamily TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_zeus_analytics_ts ON zeus_analytics(ts);
CREATE INDEX IF NOT EXISTS idx_zeus_analytics_path ON zeus_analytics(path);