-- 0075: pipeline progress tracking — per-product stage progress + notes.
CREATE TABLE IF NOT EXISTS pipeline_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pipe_id TEXT NOT NULL,
  progress_pct INTEGER NOT NULL DEFAULT 0,
  note TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO pipeline_progress (pipe_id, progress_pct, note) VALUES
('pipe_aegis_starter', 100, 'Launched'),
('pipe_aegis_pro', 100, 'Launched'),
('pipe_aegis_enterprise', 100, 'Launched'),
('pipe_travel_card', 100, 'Launched'),
('pipe_cad_tools', 35, 'Calculators live; parametric UI next'),
('pipe_zeus_os_agent', 25, 'Commander + sweeps live; autopilot next'),
('pipe_exercism_polyglot', 40, '83-language lookup live; course pack drafting'),
('pipe_voice_agent_service', 5, 'Idea validated'),
('pipe_compliance_pack', 10, 'Evidence assembled; packaging');