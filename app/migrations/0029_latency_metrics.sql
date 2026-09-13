-- 0029: Response latency monitoring. One row per askZeus round-trip, capturing
-- end-to-end time plus a breakdown so slow replies can be diagnosed from the
-- dashboard rather than guessed at.
CREATE TABLE IF NOT EXISTS agent_latency (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  total_ms INTEGER NOT NULL,
  hops INTEGER NOT NULL DEFAULT 0,
  tool_calls INTEGER NOT NULL DEFAULT 0,
  model TEXT,
  error TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_agent_latency_org ON agent_latency(org_id, created_at);