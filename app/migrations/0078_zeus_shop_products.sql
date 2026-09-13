-- 0078: ZEUS digital shop products — full costing + information for both
-- stores (Shopify catalog when API live; the storefronts read this too).
CREATE TABLE IF NOT EXISTS shop_products (
  id TEXT PRIMARY KEY,
  store TEXT NOT NULL DEFAULT 'shopify',
  name TEXT NOT NULL,
  sku TEXT,
  price_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'GBP',
  cost_cents INTEGER,
  margin_pct REAL,
  status TEXT NOT NULL DEFAULT 'draft',
  description TEXT,
  category TEXT,
  published_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO shop_products (id, store, name, sku, price_cents, currency, cost_cents, margin_pct, status, description, category) VALUES
('zp_aegis_starter','shopify','AEGIS AI Security — Starter (annual)','AEGIS-STARTER',500000,'GBP',50000,90,'live','Enterprise-grade AI attack-vector protection: 8 modules, core coverage, email + chat support.','security'),
('zp_aegis_pro','shopify','AEGIS AI Security — Pro (annual)','AEGIS-PRO',3000000,'GBP',150000,95,'live','Full 8-module / 37-endpoint protection, all 24 defensive layers, priority support and onboarding.','security'),
('zp_aegis_enterprise','shopify','AEGIS AI Security — Enterprise (annual)','AEGIS-ENT',10000000,'GBP',400000,96,'live','Everything in Pro plus a dedicated security engineer, custom integrations and SLA.','security'),
('zp_travel_card','shopify','ZEUS Travel Health Card (annual)','TRAVEL-CARD',7900,'GBP',1500,81,'live','Free UK GHIC paired with private emergency travel cover. No underwriting, high margin.','travel'),
('zp_cad_toolkit','shopify','ZEUS CAD + Engineering Toolkit','CAD-TOOLKIT',4900,'GBP',500,90,'live','Parametric CAD, engineering calculators, DXF/SVG/PNG/JSON export for professionals.','design'),
('zp_operator_copilot','shopify','ZEUS Operator Copilot (managed AI OS)','ZEUS-COPILOT',9900,'GBP',1500,85,'live','Voice-closing operator, autopilot sweeps and institutional memory for your company.','saas'),
('zp_polyglot_pack','shopify','Polyglot Mastery Course Pack','POLY63',2900,'GBP',400,92,'live','83-language roadmap with exercise tracks — the ZEUS polyglot curriculum.','course'),
('zp_voice_operator','shopify','Voice-Closing Operator (setup)','VOICE-OP',19900,'GBP',2500,87,'live','One call: authenticate, retrieve, execute, confirm. Complete workflows by voice.','service'),
('zp_compliance_pack','shopify','AEGIS Compliance & Certification Pack','COMPLY-PACK',49900,'GBP',8000,84,'live','GDPR / DSPT / Cyber Essentials evidence pack with certification roadmap.','compliance');