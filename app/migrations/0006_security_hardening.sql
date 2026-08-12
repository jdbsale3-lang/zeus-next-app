-- ZEUS COMMAND CENTER — PII + idempotency hardening (12 Aug 2026)

-- 1. Purge already-propagated PII: drop the TikTok Ads advertiser identifier
-- from live connection notes.
UPDATE connections SET note = 'Authorization link sent'
WHERE provider = 'tiktok_ads' AND note LIKE '%7673187170220916737%';

-- 2. Dedupe the contact seed duplicates introduced by the pre-idempotent
-- check-then-insert path (keep the earliest row per org+name).
DELETE FROM contacts
WHERE id NOT IN (
  SELECT MIN(id) FROM contacts GROUP BY org_id, name
);

-- 3. Unique guards so seeding can never re-duplicate.
CREATE UNIQUE INDEX IF NOT EXISTS idx_connections_org_provider
  ON connections(org_id, provider);
CREATE UNIQUE INDEX IF NOT EXISTS idx_contacts_org_name
  ON contacts(org_id, name);