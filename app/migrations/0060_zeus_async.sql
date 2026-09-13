-- 0060: ZEUS FAST LOOP — async job queue for snappy command responses.
-- Heavy asks submit a job and return instantly; a poller drains the queue
-- and posts results back to the client without blocking the first paint.
CREATE TABLE IF NOT EXISTS async_jobs (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  kind TEXT NOT NULL DEFAULT 'ask',
  prompt TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'queued',   -- queued | running | done | failed
  result TEXT,
  error TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  finished_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_async_org ON async_jobs(org_id, created_at);