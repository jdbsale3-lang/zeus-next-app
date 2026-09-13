-- 0038: Renewal alert system. Sets real renewal dates on registry rows that
-- have one (Deepgram flux free tier ends 2026-09-12 per provider) and seeds
-- the daily renewal sweep scheduler that reports what is due inside the
-- Commander. Domain renewal date left unset until the IONOS invoice date is
-- confirmed by the owner; a guessed date would false-alarm the sweep.
UPDATE asset_registry SET renewal_date = '2026-09-12', updated_at = datetime('now') WHERE id = 'ast_api_deepgram';

INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day) VALUES
('sched_renewals', 'org_zeus_shared', 'Renewal alert sweep',
 'Run the asset renewal sweep using get_asset_registry. List every asset with a renewal date within 30 days, say how many days remain, flag anything due within 14 days as action needed. End with a plain-word verdict on what the founder must renew this week.',
 'daily 07:45', NULL, 1, 1);