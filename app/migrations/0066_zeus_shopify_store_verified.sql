-- 0066: conn_shopify domain verified — store reachable at
-- zeusaiitellegence-store.myshopify.com (password-gated dev storefront).
-- API token still pending; TEST SHOPIFY flips the row to connected once set.
UPDATE connections SET url='https://zeusaiitellegence-store.myshopify.com',
  note='Store domain verified on 2026-08-15 (dev store, password-gated). Awaiting SHOPIFY_ADMIN_TOKEN — run the store check after setting it.'
WHERE provider='shopify';

UPDATE asset_registry SET status='active', notes='Store verified live at zeusaiitellegence-store.myshopify.com'
  WHERE id='ast_shopify_store';