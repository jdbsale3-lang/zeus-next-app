-- ZEUS COMMAND CENTER — project fleet, account connections, starter contacts
-- Created 12 Aug 2026. All scoped by org_id.

-- Projects the ZEUS business OS runs (websites, apps, APIs, docs)
CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  name TEXT NOT NULL,
  slug TEXT,
  url TEXT,
  status TEXT DEFAULT 'live',            -- live | standby | development
  kind TEXT DEFAULT 'website',           -- website | app | api | docs
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_projects_org ON projects(org_id);

-- Connected business accounts (email, social, SaaS) with auth state
CREATE TABLE IF NOT EXISTS connections (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  provider TEXT NOT NULL,
  account_label TEXT,
  status TEXT DEFAULT 'connected',       -- connected | needs_auth
  url TEXT,
  sort INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_connections_org ON connections(org_id);

-- Starter contact base so ZEUS can run day-to-day business from day one
INSERT INTO contacts (id, org_id, type, name, email, phone, tags, source) VALUES
  ('c_seed_01', 'org_seed', 'company', 'JDB Sales', 'jdbsale3@gmail.com', '01922 445318', 'own', 'seed'),
  ('c_seed_02', 'org_seed', 'company', 'ZEUS AI Intelligence', NULL, NULL, 'own', 'seed'),
  ('c_seed_03', 'org_seed', 'company', 'ZEUSTRUSTAEGISSECURITY LTD', NULL, NULL, 'own', 'seed'),
  ('c_seed_04', 'org_seed', 'company', 'Skitts Estate Agents', NULL, '01902 631151', 'estate', 'seed'),
  ('c_seed_05', 'org_seed', 'company', 'Webbs Estate Agents', NULL, '01922 929888', 'estate', 'seed'),
  ('c_seed_06', 'org_seed', 'company', 'KST Accountancy', NULL, '01902 639877', 'accountancy', 'seed')
ON CONFLICT (id) DO NOTHING;

-- Seed the project fleet (the sites ZEUS ships and runs)
INSERT INTO projects (id, org_id, name, slug, url, status, kind) VALUES
  ('p_seed_01', 'org_seed', 'ZEUS OS (app)', 'zeus-next-app', 'https://zeus-next-app.higgsfield.app', 'live', 'app'),
  ('p_seed_02', 'org_seed', 'ZEUS AI Intelligence', 'zeusai-intelligence', 'https://zeusai-intelligence.higgsfield.app', 'live', 'website'),
  ('p_seed_03', 'org_seed', 'ZEUS OS Marketing', 'zeus-os-marketing', 'https://zeus-os-marketing.higgsfield.app', 'live', 'website'),
  ('p_seed_04', 'org_seed', 'AEGIS Security', 'aegis-security', 'https://aegis-security.higgsfield.app', 'live', 'website'),
  ('p_seed_05', 'org_seed', 'AEGIS API Docs', 'aegis-api-docs', 'https://aegis-api-docs.higgsfield.app', 'live', 'docs'),
  ('p_seed_06', 'org_seed', 'AEGIS API (external)', 'apiaegissecurity', 'https://apiaegissecurity.tech', 'live', 'api'),
  ('p_seed_07', 'org_seed', 'ZEUS Gantt Docs', 'zeus-gantt-docs', 'https://zeus-gantt-docs.higgsfield.app', 'live', 'docs'),
  ('p_seed_08', 'org_seed', 'ZEUS Gantt Plan', 'zeus-gantt-plan', 'https://zeus-gantt-plan.higgsfield.app', 'live', 'website'),
  ('p_seed_09', 'org_seed', 'ZEUS Travel Health', 'zeus-travel-health', 'https://zeus-travel-health.higgsfield.app', 'live', 'website'),
  ('p_seed_10', 'org_seed', 'ZEUS Mind', 'zeus-mind', 'https://zeus-mind.higgsfield.app', 'live', 'website'),
  ('p_seed_11', 'org_seed', 'Intelligence CRM', 'intelligence-crm', 'https://intelligence-crm.higgsfield.app', 'live', 'website'),
  ('p_seed_12', 'org_seed', 'CalorieLens', 'calorielens', 'https://calorielens.higgsfield.app', 'live', 'website'),
  ('p_seed_13', 'org_seed', 'ZEUS 20-Min Meals', 'zeus-20min-meals', 'https://zeus-20min-meals.higgsfield.app', 'live', 'website'),
  ('p_seed_14', 'org_seed', 'ForgeFit Train', 'forgefit-train', 'https://forgefit-train.higgsfield.app', 'live', 'website'),
  ('p_seed_15', 'org_seed', 'GS Homes', 'gs-homes', 'https://gs-homes.higgsfield.app', 'live', 'website'),
  ('p_seed_16', 'org_seed', 'GS Home Improvements', 'gs-home-improvements', 'https://gs-home-improvements.higgsfield.app', 'live', 'website')
ON CONFLICT (id) DO NOTHING;

-- Seed the account connections ZEUS can drive today
INSERT INTO connections (id, org_id, provider, account_label, status, url, sort) VALUES
  ('conn_seed_01', 'org_seed', 'Gmail', 'jdbsale3@gmail.com', 'connected', NULL, 1),
  ('conn_seed_02', 'org_seed', 'YouTube', 'ZeusAI (@jdbsale)', 'connected', 'https://www.youtube.com/@jdbsale', 2),
  ('conn_seed_03', 'org_seed', 'X / Twitter', '@jdbsales3', 'connected', 'https://x.com/jdbsales3', 3),
  ('conn_seed_04', 'org_seed', 'LinkedIn', 'Darren Birch (JDB Sales)', 'connected', 'https://www.linkedin.com', 4),
  ('conn_seed_05', 'org_seed', 'TikTok', 'JDB Sales', 'connected', 'https://www.tiktok.com', 5),
  ('conn_seed_06', 'org_seed', 'Google Calendar', 'JDB Sales calendar', 'connected', NULL, 6),
  ('conn_seed_07', 'org_seed', 'HubSpot CRM', 'JDB Sales', 'connected', NULL, 7),
  ('conn_seed_08', 'org_seed', 'Slack', 'JDB workspace', 'connected', NULL, 8),
  ('conn_seed_09', 'org_seed', 'Notion', 'JDB workspace', 'connected', NULL, 9),
  ('conn_seed_10', 'org_seed', 'GitHub', 'jdbsale3-lang', 'connected', 'https://github.com/jdbsale3-lang', 10),
  ('conn_seed_11', 'org_seed', 'Discord', 'ZEUS server', 'needs_auth', 'https://pipedream.com/_static/connect.html?token=ctok_89ce2ade07454c7981edb5c0d05dd39f&connectLink=true&app=discord_bot', 11),
  ('conn_seed_12', 'org_seed', 'TikTok Ads', 'Business ads', 'needs_auth', NULL, 12)
ON CONFLICT (id) DO NOTHING;