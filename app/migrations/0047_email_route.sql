-- 0047: Email automation route for scheduled agents. Adds an email_to column
-- so any scheduled agent can declare its delivery address; the live daily
-- brief is pointed at the founder's verified inbox (same address that is the
-- verified SendGrid sender, so delivery is two-way proven).
ALTER TABLE scheduled_agents ADD COLUMN email_to TEXT;

UPDATE scheduled_agents SET email_to = 'jdbsale3@gmail.com' WHERE id = 'sched_daily_brief_live';