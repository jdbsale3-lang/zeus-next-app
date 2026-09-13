-- 0051: Budget alert sweep. Runs on the schedule, reads governance via
-- get_governance, and emails the founder if spend reached or breached the
-- ceiling, and warns at 80%+. Skips silently when no ceiling is set (zero).
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day, email_to) VALUES
('sched_budget_alert', 'org_user_3GJd975B4Ec780O9XOw', 'Budget Alert Sweep',
 'Read governance with get_governance. If the budget ceiling is zero, do nothing and do not email. If spent is at or above the ceiling, email the founder a plain-word alert stating spent, ceiling, and that ZEUS spending is stopped. If spent is between 80 and 100 percent of a positive ceiling, email a warning with the remaining amount. Only report numbers returned by the tool, never invented.',
 'hourly', NULL, 1, 3, 'jdbsale3@gmail.com');