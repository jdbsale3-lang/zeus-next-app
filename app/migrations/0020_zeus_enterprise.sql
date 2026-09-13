-- 0020: ZEUS Enterprise — governance, memory, file store, audit.
CREATE TABLE IF NOT EXISTS org_settings (
  org_id TEXT PRIMARY KEY,
  company_name TEXT,
  currency TEXT NOT NULL DEFAULT 'GBP',
  settings_json TEXT
);

-- Kill switch + budget: explicit columns so the agent can enforce them.
ALTER TABLE org_settings ADD COLUMN kill_switch INTEGER NOT NULL DEFAULT 0;
ALTER TABLE org_settings ADD COLUMN agent_cost_budget REAL NOT NULL DEFAULT 0;
ALTER TABLE org_settings ADD COLUMN agent_cost_spent REAL NOT NULL DEFAULT 0;