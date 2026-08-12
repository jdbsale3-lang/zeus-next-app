-- ZEUS COMMAND CENTER — purge legacy third-party PII rows (12 Aug 2026)
-- Removes contact rows that were seeded from the old SEED_CONTACTS roster
-- (NHS/CCS/DHSC/SBS suppliers + MSP prospects). Keeps only team rows whose
-- source is an internal directory.
DELETE FROM contacts
WHERE source NOT IN (
  'team-directory',
  'Companies House 17391549',
  'zeusaiintelligence.org',
  'User-provided'
);