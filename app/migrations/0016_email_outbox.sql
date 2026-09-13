-- 0016: Email outbox for the Commander — draft/write + send + read-back of outbound mail.
CREATE TABLE IF NOT EXISTS email_outbox (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  sender TEXT NOT NULL DEFAULT 'jdbsale3@gmail.com',
  to_email TEXT NOT NULL,
  subject TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft',          -- draft | sent | failed
  message_id TEXT,
  error TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  sent_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_email_outbox_org ON email_outbox(org_id, created_at);