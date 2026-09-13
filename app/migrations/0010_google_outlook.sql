-- 0010: Google full-access + Outlook status alignment
-- Docs OAuth link minted -> awaiting user auth
UPDATE connections SET status = 'waiting', note = 'Awaiting Google OAuth (link minted 2026-08-13)'
WHERE provider = 'google_docs' AND status = 'disconnected';

-- Maps: keyless embed already live in Commander; Places API optional (needs_key)
UPDATE connections SET status = 'needs_key', note = 'Embedded in Commander; Places API key optional'
WHERE provider = 'google_maps' AND status = 'connected';

-- Outlook: confirmed connected for ZEUS sync
UPDATE connections SET status = 'connected', note = 'Secondary mail (synced to ZEUS)'
WHERE provider = 'outlook' AND status = 'connected';