-- 0033: Go-live readiness check — daily until the founder stops it.
-- Runs the readiness sweep: email key present and probed, sender verified,
-- letters addressed, pipeline invoice raised, voice key status, and any
-- scheduled agent that is disabled. Reports only grounded facts.
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day) VALUES
('sched_go_live', 'org_zeus_shared', 'Go-live readiness check',
 'Run the go-live readiness sweep. Check each item and report only what the tools actually return: email key configured, sender identity verified, outbox letters addressed and ready, first invoice raised, voice key status, and any scheduled agents disabled. End with a plain-word READY or NOT READY verdict and the single blocking item if any.',
 'daily 08:15', NULL, 1, 1);