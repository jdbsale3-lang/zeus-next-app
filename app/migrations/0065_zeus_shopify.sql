-- 0065: Shopify connection + asset registry — gated on real store creds.
-- Status stays 'pending' until the store domain + Admin API token are set as
-- secrets and testShopifyConnection passes; only then promoted to 'connected'.
INSERT OR IGNORE INTO connections (id, org_id, provider, account_label, kind, status, url, note) VALUES
('conn_shopify', 'org_user_3GJd975B4Ec780O9XOw', 'shopify', 'Shopify Store', 'saas', 'pending', NULL, 'Needs store domain + Admin API token — set SHOPIFY_STORE_DOMAIN and SHOPIFY_ADMIN_TOKEN secrets, then run the store check');

INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, identifier, status, cost_reference, renewal_date, region, notes) VALUES
('ast_shopify_store','platform','Shopify Store','Shopify','conn_shopify','pending','Shopify plan + app fees',NULL,'global','Paired with conn_shopify — product catalog, orders, revenue'),
('ast_shopify_earnings','subscription','Shopify Earnings & Renewal','Shopify','conn_shopify','pending','Store revenue attribution',NULL,'global','Earnings YTD after billing snapshot'),
('ast_shopify_admin_api','secret','Shopify Admin API','Shopify','SHOPIFY_ADMIN_TOKEN','pending','API access',NULL,'global','Admin API token — set as secret, never in code');