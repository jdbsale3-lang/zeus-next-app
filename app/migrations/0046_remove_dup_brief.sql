-- 0046: Remove the duplicate 07:30 Daily AI Brief that lives under the shared
-- seed org (org_zeus_shared) and can never fire for the active user org. The
-- live 08:00 brief (sched_daily_brief_live) remains the single source of truth.
DELETE FROM scheduled_agents WHERE id = 'sched_daily_brief' AND org_id = 'org_zeus_shared';

-- Any orphaned runs of the removed agent are cleaned too.
DELETE FROM scheduled_runs WHERE agent_id = 'sched_daily_brief';