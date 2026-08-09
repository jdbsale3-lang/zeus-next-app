-- ZEUS AI COMMAND CENTER — core business tables
-- All scoped by org_id (the owner's company workspace). Created 9 Aug 2026.

-- Contacts (people + companies)
CREATE TABLE IF NOT EXISTS contacts (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'person',          -- person | company
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  company_id TEXT,
  tags TEXT,
  hubspot_id TEXT,
  source TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_contacts_org ON contacts(org_id);

-- Deals / pipeline
CREATE TABLE IF NOT EXISTS deals (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  title TEXT NOT NULL,
  contact_id TEXT,
  stage TEXT NOT NULL DEFAULT 'lead',          -- lead|qualified|proposal|won|lost
  amount REAL DEFAULT 0,
  probability INTEGER DEFAULT 0,
  expected_close TEXT,
  next_action TEXT,
  owner_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_deals_org ON deals(org_id);

-- Tasks
CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'todo',         -- todo|in_progress|done
  priority TEXT DEFAULT 'medium',
  assignee_id TEXT,
  deal_id TEXT,
  due_at TEXT,
  workspace_id TEXT,
  completed_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_tasks_org ON tasks(org_id);

-- Invoices
CREATE TABLE IF NOT EXISTS invoices (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  number TEXT,
  contact_id TEXT,
  workspace_id TEXT,
  status TEXT NOT NULL DEFAULT 'draft',        -- draft|sent|paid|overdue
  amount REAL DEFAULT 0,
  currency TEXT DEFAULT 'GBP',
  due_at TEXT,
  stripe_invoice_id TEXT,
  paid_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_invoices_org ON invoices(org_id);

-- Notes / Second Brain
CREATE TABLE IF NOT EXISTS notes (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  title TEXT,
  body TEXT,
  tags TEXT,
  source TEXT DEFAULT 'capture',              -- capture|ai|import
  workspace_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_notes_org ON notes(org_id);

-- AI assistant conversation log
CREATE TABLE IF NOT EXISTS assistant_messages (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  channel TEXT DEFAULT 'chat',                -- chat|voice
  role TEXT NOT NULL,                          -- user|assistant
  text TEXT NOT NULL,
  intent TEXT,
  session_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msgs_org ON assistant_messages(org_id);

-- Org settings
CREATE TABLE IF NOT EXISTS org_settings (
  org_id TEXT PRIMARY KEY,
  company_name TEXT,
  currency TEXT DEFAULT 'GBP',
  settings_json TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);