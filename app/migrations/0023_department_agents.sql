-- 0023: Department agents — role-based sub-agents sharing the Second Brain.
CREATE TABLE IF NOT EXISTS department_agents (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  name TEXT NOT NULL,
  role_prompt TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_department_org ON department_agents(org_id, enabled);