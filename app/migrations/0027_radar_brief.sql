-- 0026: Weekly AI tool radar + daily AI brief scheduled agents.
-- Idempotent: INSERT OR IGNORE on fixed ids. Both agents run inside the
-- Commander scheduler; results land in scheduled_runs and can be pushed to
-- memory via the remember tool by the agent itself.
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day) VALUES
('sched_ai_radar_weekly', 'org_zeus_shared', 'Weekly AI Tool Radar',
 'You are the ZEUS market radar. Every week scan the AI frontier: new agent platforms, voice engines, governance and observability tools, web automation, and models. For each find, state the tool name, what it replaces or upgrades inside ZEUS, whether it is worth a probe, and the risk if we ignore it. Keep it to plain words, no symbols, max 2000 characters. Use the tools you have; if you cannot verify a tool live, say so and do not guess.',
 'weekly Monday 08:00', NULL, 1, 1),
('sched_daily_brief', 'org_zeus_shared', 'Daily AI Brief',
 'You are ZEUS daily brief. Produce the company morning brief: open pipeline, open tasks, AR, one thing that needs attention today, and one front-edge AI signal you noticed. Ground every number in your tools. Plain words, no symbols, under 250 words. Save the brief as a note.',
 'daily 07:30', NULL, 1, 1);