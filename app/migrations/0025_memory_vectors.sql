-- 0021: memory vectors for semantic recall.
CREATE TABLE IF NOT EXISTS memory_vectors (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  memory_id TEXT NOT NULL,
  embedding TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_memory_vectors_org ON memory_vectors(org_id);