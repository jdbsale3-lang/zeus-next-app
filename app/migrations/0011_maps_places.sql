-- 0011: Google Maps Places API key wired -> connected
UPDATE connections SET status = 'connected', note = 'Places API key set — server-side lookups'
WHERE provider = 'google_maps';

-- Google Sheets awaiting the freshly-minted OAuth authorization
UPDATE connections SET status = 'waiting', note = 'Awaiting Google OAuth (link minted 2026-08-13)'
WHERE provider = 'google_sheets' AND status = 'disconnected';