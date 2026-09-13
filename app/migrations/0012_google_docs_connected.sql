-- 0012: Google Docs approved via OAuth -> connected in Commander registry
UPDATE connections SET status = 'connected', note = 'Connected — OAuth approved'
WHERE provider = 'google_docs' AND status IN ('disconnected','waiting');