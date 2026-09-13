-- 0041: Milestone event analytics for the Second Brain celebration system.
-- One row per level-up: who, which level, which tier, and the context the
-- milestone happened under (sound, haptics strength, volume) so product
-- decisions about the celebration system are grounded in real usage.
CREATE TABLE IF NOT EXISTS milestone_events (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  level INTEGER NOT NULL,
  tier TEXT NOT NULL,
  event_no INTEGER NOT NULL,
  sound_on INTEGER NOT NULL DEFAULT 1,
  haptics_on INTEGER NOT NULL DEFAULT 1,
  haptic_strength TEXT NOT NULL DEFAULT 'medium',
  volume REAL NOT NULL DEFAULT 0.7,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_milestone_org ON milestone_events (org_id, created_at);