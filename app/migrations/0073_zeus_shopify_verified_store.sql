-- 0073: Correct conn_shopify to the verified store. The OAuth client-credentials
-- trio (JWT aud client id + July-6 secret + store from the install payload) was
-- verified live: mint succeeds and shop.json returns zeusaiintellgence / Basic.
-- Products currently need merchant scope approval (read_products) — connection
-- stays pending until that approval, then the sync runs.
UPDATE connections SET url='https://zeusaiintellgence.myshopify.com',
  note='Verified 2026-08-16 via OAuth mint + live shop.json: store name zeusaiintellgence, plan Basic, owner jdbsale3@gmail.com. Token mints OK (86k s expiry). Needs merchant approval of read_products/read_orders/read_customers scopes before catalog sync.'
WHERE provider='shopify';

UPDATE asset_registry SET status='pending', notes='Verified store zeusaiintellgence.myshopify.com — OAuth mint works, scopes await merchant approval'
  WHERE id='ast_shopify_store';

INSERT OR IGNORE INTO memory (id, org_id, kind, key, body, source, created_at) VALUES
('mem_shopify_verified', 'org_user_3GJd975B4Ec780O9XOw', 'fact', 'shopify_verified',
'Shopify store zeusaiintellgence.myshopify.com is verified: the ZEUS OAuth client-credentials token mints successfully (store plan Basic, owner jdbsale3@gmail.com) and shop.json returns HTTP 200. The products call returns 403 awaiting merchant approval of read_products scope in store admin. Once approved the catalog sync runs and conn_shopify flips to connected.',
'zeus', datetime('now'));