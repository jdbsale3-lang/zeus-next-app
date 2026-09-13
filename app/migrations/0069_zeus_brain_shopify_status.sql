-- 0069: Store Shopify integration state into the ZEUS Second Brain (memory).
-- Honest snapshot: connection pending, token not yet configured. This fact is
-- readable by brain agents and the Commander so ZEUS always knows the status.
INSERT OR IGNORE INTO memory (id, org_id, kind, key, body, source, created_at) VALUES
('mem_shopify_status', 'org_user_3GJd975B4Ec780O9XOw', 'fact', 'shopify_connection_status',
'Shopify store zeusaiitellegence-store.myshopify.com is registered in ZEUS as conn_shopify with status pending. The store domain is verified and the Admin API endpoint answers 401 without a token. Awaiting a real credential: either the ADMIN API access token starting with shpat_ from the Dev Dashboard, or the custom app client id and client secret for OAuth client-credentials. Once a real secret is set and deployed, run the store check, sync the catalog, and flip the connection to connected. The token is never invented or guessed.',
'zeus', datetime('now'));