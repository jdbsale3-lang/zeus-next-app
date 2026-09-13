-- 0071: Gumroad connection + registry + brain state. Honest pending until the
-- real GUMROAD_API_TOKEN secret is set and the live check passes.
INSERT OR IGNORE INTO connections (id, org_id, provider, account_label, kind, status, url, note) VALUES
('conn_gumroad', 'org_user_3GJd975B4Ec780O9XOw', 'gumroad', 'Gumroad', 'saas', 'pending', 'https://gumroad.com/dashboard', 'Needs GUMROAD_API_TOKEN — Settings → Advanced → API in the Gumroad dashboard, then run the store check');

INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, identifier, status, cost_reference, renewal_date, region, notes) VALUES
('ast_gumroad_store','platform','Gumroad Store','Gumroad','conn_gumroad','pending','Gumroad fee on sales',NULL,'global','Paired with conn_gumroad — digital products, sales, payouts'),
('ast_gumroad_earnings','subscription','Gumroad Earnings & Payouts','Gumroad','conn_gumroad','pending','Sales attribution + payout tracking',NULL,'global','Earnings YTD after billing snapshot');

INSERT OR IGNORE INTO memory (id, org_id, kind, key, body, source, created_at) VALUES
('mem_gumroad_status', 'org_user_3GJd975B4Ec780O9XOw', 'fact', 'gumroad_status',
'Gumroad is registered in ZEUS as conn_gumroad with status pending. The token-based v2 API is the integration surface (no OAuth connector exists). Awaiting a real GUMROAD_API_TOKEN from Settings to Advanced to API in the Gumroad dashboard. Once set and deployed, test the connection, list products, and pull the sales summary; nothing is invented or guessed.',
'zeus', datetime('now'));