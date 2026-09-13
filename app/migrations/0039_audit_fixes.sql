-- 0039: Audit corrections from the live cost audit. The company-domain TLS
-- cert is Let's Encrypt (verified live: notBefore 2026-08-07, notAfter
-- 2026-11-05), not Cloudflare as originally seeded. Twilio flagged for
-- retirement, registry notes updated with verified probe facts.
UPDATE asset_registry SET vendor = 'Let''s Encrypt', notes = 'Verified live: valid 2026-08-07 to 2026-11-05, SAN matches zeusaiintelligence.org. Zero cost, auto renewal by ACME.', renewal_date = '2026-11-05', updated_at = datetime('now') WHERE id = 'ast_cert_zeus';
UPDATE asset_registry SET status = 'active', notes = 'Legacy account auth; rotation flagged, token pasted in chat. Audit 2026-08-14: retire this unused credential.', updated_at = datetime('now') WHERE id = 'ast_api_twilio';