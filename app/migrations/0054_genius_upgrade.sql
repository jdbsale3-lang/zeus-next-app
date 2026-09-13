-- 0054: Apply the video-researched genius-level lessons to ZEUS.
-- 1) Second Brain note: the parallel-coding speed principle (predict the whole
--    structured result at once, not token-by-token) → ZEUS batches parallel
--    tool dispatch, prefers FAST_MARKERS models, and keeps heavy work
--    quantified; channel pattern = modular, versioned action-based system.
-- 2) Build request: genius upgrade of the ZEUS command layer — parallel tool
--    dispatch + fast-model preference, grounded in the measured agent_latency.
INSERT OR IGNORE INTO notes (id, org_id, title, body, source) VALUES
('note_genius_001', 'org_zeus_shared', 'Genius-level upgrade lessons',
 'Research: NVIDIA open-vision model gets ~10x by parallel box coding, predicting the whole structured result at once instead of step by step; a CPU-runnable C++ port with quantized sizes cuts 15GB to 4.7GB. Applied to ZEUS: batch parallel structured work, keep the fast tier, quantify before scaling. Embedded action style: modular, versioned, grown by iteration.', 'genius research 2026-08-23');

INSERT OR IGNORE INTO build_requests (id, org_id, title, build_type, status, spec) VALUES
('bld_genius_001', 'org_zeus_shared', 'ZEUS genius capability pass: parallel dispatch',
 'config',
 'queued',
 'Parallel dispatch of independent tool calls (batch pattern from the vision model speedup); prefer fast model tier for structured lookups; add latency guard on any increase.');