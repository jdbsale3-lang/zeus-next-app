-- 0049: More scheduled briefs on the LIVE org, filling real gaps in the
-- cadence, each with its verified email route. Plus the failure-alert sweep
-- agent that will surface any failed automation run.
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day, email_to) VALUES
('sched_weekly_cash_fri', 'org_user_3GJd975B4Ec780O9XOw', 'Weekly Cash Position Friday',
 'Produce the weekly cash position brief. Use get_cashflow and get_pipeline to report receivables, paid to date, pipeline by stage, and the top three invoices or deals that move cash this week. End with the one number the founder must know before the weekend. Plain words, no symbols, under two hundred words.',
 'every Friday 16:00', NULL, 1, 2, 'jdbsale3@gmail.com'),
('sched_monthly_board', 'org_user_3GJd975B4Ec780O9XOw', 'Monthly Board Brief',
 'Produce the monthly board brief. Use get_metrics, get_cashflow, get_pipeline, list_tasks and list_invoices to report: month totals, pipeline movement, receivables, task completion, outbox activity, scheduled agents run count, and the three decisions on the table. End with a plain-word summary the board can read in one minute.',
 'monthly on the 1st 08:00', NULL, 1, 1, 'jdbsale3@gmail.com'),
('sched_fail_alert', 'org_user_3GJd975B4Ec780O9XOw', 'Failure Alert Sweep',
 'Call get_failed_agent_runs. If any failed schedules exist in the last day, send one short email to the founder listing each failed agent, its error, and what was lost. If none failed, say nothing and do not email. Only facts from the tool, never invented.',
 'daily 07:50', NULL, 1, 2, 'jdbsale3@gmail.com');