-- 0017: ZEUS memory (Second Brain) + file store for built assets.
-- The Commander can now remember standing facts and store/retrieve files
-- (R2 objects referenced by URL), so it can save notes, documents and the
-- artifacts it helps produce (videos, images, builds, exports).

-- Memory / Second Brain: durable facts + standing instructions.
CREATE TABLE IF NOT EXISTS memory (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  kind TEXT NOT NULL DEFAULT 'fact',           -- fact | preference | standing_instruction | learning
  key TEXT,
  body TEXT NOT NULL,
  source TEXT DEFAULT 'zeus',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_memory_org ON memory(org_id, kind);

-- File store: metadata rows for R2 objects (name, kind, url, size).
CREATE TABLE IF NOT EXISTS files (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  name TEXT NOT NULL,
  kind TEXT NOT NULL DEFAULT 'file',           -- file | image | video | document | export
  url TEXT,
  size_bytes INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_files_org ON files(org_id, created_at);

-- Build requests: app / website / video production requests tracked as work.
CREATE TABLE IF NOT EXISTS build_requests (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  title TEXT NOT NULL,
  build_type TEXT NOT NULL,                    -- app | website | video | brand | file
  spec TEXT,
  status TEXT NOT NULL DEFAULT 'queued',       -- queued | building | done | blocked
  output_url TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_build_org ON build_requests(org_id, status);
