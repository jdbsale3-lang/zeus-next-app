-- 0040: Execute the five audit actions.
-- 1. Retire the Twilio credential (unused, pasted in chat, supply surface cut).
-- 3. IONOS renewal date verified live from RDAP: expiry 2027-08-07.
-- 4. Zero-cert policy recorded as a standing registry policy.
-- 5. Registry-first project policy recorded.
UPDATE asset_registry SET status = 'retired', notes = 'Retired by audit action 2026-08-14. Unused legacy credential; supply-chain surface removed. Token was pasted in chat, do not reuse.', updated_at = datetime('now') WHERE id = 'ast_api_twilio';

UPDATE asset_registry SET renewal_date = '2027-08-07', notes = 'Renewal verified live from RDAP 2026-08-14: expiry 2027-08-07, registration 2026-08-07, client transfer/delete/update prohibited. IONOS registrar.', updated_at = datetime('now') WHERE id = 'ast_domain_zeus';

INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, notes, status) VALUES
('ast_policy_cert', 'identity', 'Zero-cert policy', 'ZEUS', 'Standing policy: never buy a paid certificate. Let''s Encrypt and Cloudflare managed certs are live and cost zero. Any project needing a cert must use one of those.', 'active'),
('ast_policy_registry', 'identity', 'Registry-first project policy', 'ZEUS', 'Standing policy: every new project starts from the asset registry. Same platform (Higgsfield), same edge (Cloudflare), no new vendor without a registry entry.', 'active');