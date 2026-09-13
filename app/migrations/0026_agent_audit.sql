-- 0026: Agent audit trail (was missing after 0020 rewrite).
CREATE TABLE IF NOT EXISTS agent_audit (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  run_id TEXT,
  tool TEXT NOT NULL,
  args TEXT,
  result TEXT,
  error TEXT,
  duration_ms INTEGER DEFAULT 0,
  cost_points REAL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_agent_audit_org ON agent_audit(org_id, created_at);