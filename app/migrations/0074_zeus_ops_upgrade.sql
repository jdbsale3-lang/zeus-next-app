-- 0074: ZEUS ops upgrades — product pipeline (money-making), policy engine,
-- cost ledger, tool audit (governance spine), all additive and live-safe.
CREATE TABLE IF NOT EXISTS product_pipeline (
  id TEXT PRIMARY KEY,
  stage TEXT NOT NULL DEFAULT 'ideation',
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'digital',
  price_cents INTEGER,
  currency TEXT NOT NULL DEFAULT 'GBP',
  status TEXT NOT NULL DEFAULT 'pending',
  rationale TEXT,
  launch_url TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO product_pipeline (id, stage, name, type, price_cents, currency, status, rationale) VALUES
('pipe_aegis_starter','launch','AEGIS AI Security Starter (annual)','security',500000,'GBP','launched','Core AI attack-vector protection, 5k per year (verified pricing)'),
('pipe_aegis_pro','launch','AEGIS AI Security Pro (annual)','security',3000000,'GBP','launched','Full 8-module, 37-endpoint, all 24 layers (verified pricing)'),
('pipe_aegis_enterprise','launch','AEGIS AI Security Enterprise (annual)','security',10000000,'GBP','launched','Everything in Pro + dedicated engineer + SLA (verified pricing)'),
('pipe_travel_card','launch','ZEUS Travel Health Card','product',7900,'GBP','launched','GHIC + emergency cover, 79/year (verified pricing)'),
('pipe_cad_tools','build','ZEUS CAD + Engineering Toolkit','saas',4900,'GBP','build','Parametric CAD, engineering calculators, DXF/SVG export'),
('pipe_zeus_os_agent','build','ZEUS Operator Copilot (managed AI OS)','saas',9900,'GBP','build','Voice-closing operator + autopilot sweeps + memory'),
('pipe_exercism_polyglot','build','Polyglot Mastery Course Pack','course',2900,'GBP','build','83-language roadmap pack with exercise tracks'),
('pipe_voice_agent_service','idea','Voice-Closing Operator Service','service',19900,'GBP','idea','AI operator completes workflows by voice end-to-end'),
('pipe_compliance_pack','idea','AEGIS Compliance & Certification Pack','service',49900,'GBP','idea','GDPR/DSPT/Cyber Essentials evidence pack');

CREATE TABLE IF NOT EXISTS policy_rules (
  id TEXT PRIMARY KEY,
  rule TEXT NOT NULL,
  apply_to TEXT NOT NULL DEFAULT 'all',
  limit_value REAL,
  action TEXT NOT NULL DEFAULT 'block',
  enabled INTEGER NOT NULL DEFAULT 1,
  note TEXT
);

INSERT OR IGNORE INTO policy_rules (id, rule, apply_to, limit_value, action, enabled, note) VALUES
('pol_spend_cap','max agent spend per week','zeus',0,'require_approval',1,'Approval gate; enforcement via cost ledger'),
('pol_no_customer_export','Never export customer PII outside ZEUS','gumroad',NULL,'block',1,'PII stays in the store'),
('pol_no_publish_unverified','Never publish outreach with unverified recipients/CTAs','outreach',NULL,'block',1,'JDB verification rule');

CREATE TABLE IF NOT EXISTS cost_ledger (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts TEXT NOT NULL DEFAULT (datetime('now')),
  agent TEXT,
  cost_points REAL DEFAULT 0,
  tool TEXT,
  note TEXT
);

CREATE TABLE IF NOT EXISTS tool_audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts TEXT NOT NULL DEFAULT (datetime('now')),
  tool TEXT,
  args TEXT,
  outcome TEXT,
  note TEXT
);

INSERT OR IGNORE INTO memory (id, org_id, kind, key, body, source, created_at) VALUES
('mem_ops_upgrade_2026', 'org_user_3GJd975B4Ec780O9XOw', 'fact', 'ops_upgrade_2026',
'2026 ops upgrade: product_pipeline (9 ideas from launches to voice agent), policy_rules (spend cap, PII guard, unverified publish block), cost_ledger, tool_audit. Roadmap: autopilot sweeps + revenue attribution next; voice-closing + institutional memory are the signature edges.' ,
'zeus', datetime('now'));