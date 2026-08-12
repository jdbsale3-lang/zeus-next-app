-- ZEUS AI COMMAND CENTER — portfolio & account connectivity (12 Aug 2026)
-- All rows scoped by org_id (the owner's company workspace).

-- Projects / products under the business
CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  name TEXT NOT NULL,
  slug TEXT,
  url TEXT,
  category TEXT DEFAULT 'product',          -- product|app|site|security|client|holding|nhs
  status TEXT NOT NULL DEFAULT 'live',       -- live|planning|build|paused
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_projects_org ON projects(org_id);

-- Connected accounts / integrations registry (mirrors the real connector catalog)
CREATE TABLE IF NOT EXISTS connections (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  provider TEXT NOT NULL,                    -- platform slug, e.g. gmail, x, linkedin
  account_label TEXT NOT NULL,               -- display name, e.g. Gmail, X (Twitter)
  kind TEXT NOT NULL DEFAULT 'saas',         -- platform|saas|api|external
  status TEXT NOT NULL DEFAULT 'disconnected', -- connected|waiting|disconnected|needs_key|unavailable
  url TEXT,
  note TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_connections_org ON connections(org_id);
