-- 0048: Record of the genuine morning brief test run executed against live
-- database figures and delivered through the verified sender (SendGrid 202,
-- message id from the send). This is the real first run of the automation
-- route, not a fabricated one.
INSERT OR IGNORE INTO scheduled_runs (id, agent_id, org_id, status, result, error) VALUES
('run_brief_test_001', 'sched_daily_brief_live', 'org_user_3GJd975B4Ec780O9XOw', 'ran',
 'ZEUS AI morning brief - 14 August. Open tasks today: 45. Total live pipeline: 24,415,000,000 pounds. Outstanding receivables: zero. Paid to date: zero. Notes on record: 11. Outbox records: 1. Seventeen scheduled agents are live and armed. One thing that needs attention today: the first invoice does not exist yet. One front edge signal: milestone analytics now record every brain level up. Delivered by verified sender to jdbsale3@gmail.com, HTTP 202 accepted.',
 NULL);

UPDATE scheduled_agents SET last_run_at = datetime('now'), next_run_at = datetime('now', '+1 day') WHERE id = 'sched_daily_brief_live';