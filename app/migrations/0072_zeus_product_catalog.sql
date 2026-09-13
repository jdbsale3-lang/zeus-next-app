-- 0072: ZEUS product catalog + gumroad launch tasks — feeds the Commander so
-- ZEUS can act on the catalog itself. Prices are the verified figures from
-- zeusaiintelligence.org (AEGIS tiers, Travel Health Card) — real data.
CREATE TABLE IF NOT EXISTS zeus_products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'digital',
  price_cents INTEGER,
  currency TEXT NOT NULL DEFAULT 'GBP',
  channel TEXT NOT NULL DEFAULT 'zeus-store',
  status TEXT NOT NULL DEFAULT 'listed',
  url TEXT,
  gumroad_id TEXT,
  notes TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO zeus_products (id, name, category, price_cents, currency, channel, status, url, notes) VALUES
('prod_aegis_starter','AEGIS AI Security — Starter','security',500000,'GBP','zeusaiintelligence.org','listed','https://buy.stripe.com/cNieVd6kJ5ot5wQent7kc06','AEGIS Starter tier, 5k per year, verified from the live pricing page'),
('prod_aegis_pro','AEGIS AI Security — Pro','security',3000000,'GBP','zeusaiintelligence.org','listed','https://buy.stripe.com/9B614ncJ73gl0cw4MT7kc07','AEGIS Pro tier, 30k per year, verified from the live pricing page'),
('prod_aegis_enterprise','AEGIS AI Security — Enterprise','security',10000000,'GBP','zeusaiintelligence.org','listed','https://buy.stripe.com/6oU8wP6kJbMR1gA5QX7kc08','AEGIS Enterprise tier, 100k per year, verified from the live pricing page'),
('prod_travel_card','ZEUS Travel Health Card','product',7900,'GBP','zeusaiintelligence.org','listed','https://zeusaiintelligence.org/#products','79 pounds per year, pairs with UK GHIC, verified from the live pricing page'),
('prod_ghz_wallet','NHS Health ID Wallet','identity',NULL,'GBP','zeusaiintelligence.org','pilot','https://zeusaiintelligence.org/#products','Patient-owned identity, pilot first, contact for onboarding');

-- Gumroad launch tasks: the commander reads these to complete them.
CREATE TABLE IF NOT EXISTS gumroad_launch_tasks (
  id TEXT PRIMARY KEY,
  task TEXT NOT NULL,
  gate TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  detail TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO gumroad_launch_tasks (id, task, gate, status, detail) VALUES
('t1','Obtain the Gumroad API token','GUMROAD_API_TOKEN secret','pending','Generate at Settings → Advanced → API; paste to ZEUS'),
('t2','Test the Gumroad connection','t1 done','pending','test_gumroad_connection returns the account name'),
('t3','Create the three AEGIS products on Gumroad','t2 done','pending','gumroad_create_product for each tier using catalog prices'),
('t4','Create the Travel Health Card product on Gumroad','t2 done','pending','gumroad_create_product at 79 pounds'),
('t5','Verify the products appear in gumroad_list_products','t3 done','pending','list contains the created ids'),
('t6','Set up the payout destination','t5 done','pending','Settings → Payments → Payouts in Gumroad; PayPal or Stripe Connect'),
('t7','Complete a real test purchase','t6 done','pending','Buy one tier from checkout; confirm sale in gumroad_sales_summary'),
('t8','Report launch: catalog live + payout configured','t7 done','pending','Summarise for the founder with URLs and payout pointer');

INSERT OR IGNORE INTO memory (id, org_id, kind, key, body, source, created_at) VALUES
('mem_product_catalog', 'org_user_3GJd975B4Ec780O9XOw', 'fact', 'product_catalog',
'ZEUS product catalog is in the zeus_products table: AEGIS Starter 5000 GBP, AEGIS Pro 30000 GBP, AEGIS Enterprise 100000 GBP, ZEUS Travel Health Card 79 GBP per year, NHS Health ID Wallet pilot. Gumroad launch tasks are tracked in gumroad_launch_tasks with an explicit gate per step; execution starts with the GUMROAD_API_TOKEN secret. Nothing outside the verified catalog is offered.',
'zeus', datetime('now'));