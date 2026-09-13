-- 0045: Clear the emergency kill switch on the live org so ZEUS tool calls
-- resume, and schedule the 08:00 daily morning brief under the LIVE org
-- (the seed org copy lives under org_zeus_shared and is out of scope for
-- the active user org).
UPDATE org_settings SET kill_switch = 0, updated_at = datetime('now') WHERE org_id = 'org_user_3GJd975B4Ec780O9XOw';

INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day) VALUES
('sched_daily_brief_live', 'org_user_3GJd975B4Ec780O9XOw', 'Daily AI Brief 08:00',
 'Run the daily morning brief. Use get_metrics, get_cashflow, get_pipeline and list_outbox to give the founder: open tasks, pipeline value, unpaid invoices, recent activity, outbox status and any blockers. End with the top three things to focus on today in plain words, no symbols.',
 'daily 08:00', NULL, 1, 1);