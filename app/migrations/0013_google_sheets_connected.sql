-- 0013: Google Sheets approved -> connected in Commander registry
UPDATE connections SET status = 'connected', note = 'Connected — OAuth approved'
WHERE provider = 'google_sheets' AND status IN ('waiting','disconnected','needs_key');