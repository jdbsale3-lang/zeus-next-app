-- 0037: Central asset registry. One table holds every external service, API
-- key, cert, domain, connector and subscription ZEUS depends on, with honest
-- cost references, renewal dates and status. This is the single control plane
-- for reducing spend: everything visible in one query, retired items
-- removable, and renewals surfaced by the go-live daily sweep.
CREATE TABLE IF NOT EXISTS asset_registry (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL CHECK (category IN ('platform','api_key','cert','domain','connector','subscription','secret','repo','identity')),
  name TEXT NOT NULL,
  vendor TEXT NOT NULL,
  identifier TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','pending','blocked','retired','expiring')),
  cost_reference TEXT,
  renewal_date TEXT,
  region TEXT,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, notes, status, cost_reference) VALUES
('ast_platform_1', 'platform', 'Higgsfield build platform', 'Higgsfield', 'Apps, websites, images, video, audio, branding, deploy, hosting. Single surface for all builds; all apps live here; reduce parallel tools to this surface.', 'active', 'credits 15.45 shown; video pool blocked'),
('ast_cloudflare_1', 'platform', 'Cloudflare Workers + D1 + R2 + KV + certs', 'Cloudflare', 'Runtime for every deployment, edge DNS, managed TLS, D1 database. All higgsfield.app certs are Cloudflare managed and auto-renewing.', 'active', 'free tier plus Worker usage'),
('ast_api_anthropic', 'api_key', 'Anthropic Claude key', 'Anthropic', 'Claude drafting and analysis bridge in Commander. Key verified with claude-sonnet-4-5.', 'active', 'pay as you go'),
('ast_api_openai', 'api_key', 'OpenAI key', 'OpenAI', 'Gateway model resolution and realtime voice.', 'active', 'pay as you go; realtime billed per minute'),
('ast_api_deepgram', 'api_key', 'Deepgram voice engine', 'Deepgram', 'Realtime speech for ZEUS replies.', 'active', 'flux free until 2026-09-12; then metered'),
('ast_api_sendgrid', 'api_key', 'SendGrid email send', 'Twilio SendGrid', 'Outbound email from Commander. Sender jdbsale3@gmail.com verified.', 'active', 'monthly free tier'),
('ast_api_maps', 'api_key', 'Google Maps key', 'Google', 'Location and mapping.', 'active', 'metered credit grant'),
('ast_api_twilio', 'secret', 'Twilio auth token', 'Twilio', 'Legacy account auth; rotation flagged, token was pasted in chat.', 'active', 'unused; rotate or retire'),
('ast_domain_zeus', 'domain', 'zeusaiintelligence.org', 'IONOS', 'Primary company domain; DNS at IONOS; 3 CNAME for domain auth pending.', 'active', 'annual renewal'),
('ast_domain_hf', 'domain', 'higgsfield.app subdomains', 'Higgsfield', 'zeus-next-app, aegis-security, nhs-id-card, zeus-gantt-docs and evidence mirrors.', 'active', 'included in platform'),
('ast_cert_zeus', 'cert', 'TLS for zeusaiintelligence.org', 'Cloudflare', 'Managed edge cert for company domain.', 'active', 'included'),
('ast_conn_gmail', 'connector', 'Gmail jdbsale3', 'Google', 'Email read/write via Commander.', 'active', 'free'),
('ast_conn_gdrive', 'connector', 'Google Drive, Sheets, Calendar, Docs', 'Google', 'Company workspace data for agents and schedulers.', 'active', 'free'),
('ast_conn_pipe6', 'connector', 'Outlook, OneDrive, SendGrid, WhatsApp, Discord, Linear', 'Pipedream', 'Reconnect pending after token expiry; 6 links minted awaiting user action.', 'pending', 'free tier'),
('ast_identity_gmail', 'identity', 'Gmail sender identity', 'Google', 'Send identity for outbound mail; sender verification passed.', 'active', 'free'),
('ast_repo_gh', 'repo', 'Git repos', 'GitHub', 'Source control for zeus-next-app, nhs-id-card-evidence, aegis-evidence.', 'active', 'free tier');