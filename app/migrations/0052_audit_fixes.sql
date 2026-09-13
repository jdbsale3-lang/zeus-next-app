-- 0052: Audit fixes.
-- 1. Duplicate Payroll scheduler on the live org: two agents run payroll
--    (20th and 25th). Keep the original monthly 20th run (per the company OS
--    calendar), disable the duplicate 25th run.
-- 2. Three drafts hold addresses that were never verified and look guessed:
--    england.ceo@nhs.net, dhsc.hub@dhsc.gov.uk, number10@gov.uk. Standing rule:
--    never send to an unverified address. Re-flag them as blocked-review so
--    nothing can ever send them until the founder supplies verified routes.
-- 3. The failed test email row documents the guard working (key was absent at
--    send time); it stays failed as evidence, untouched.
UPDATE scheduled_agents SET enabled = 0
WHERE id='a760b8f5-35f0-4b14-bdec-a6e1178d9c9d' AND org_id='org_user_3GJd975B4Ec780O9XOw';

UPDATE email_outbox SET status = 'blocked', error = 'Unverified guessed address — never send. Founder must supply a verified official route.',
  body = body
WHERE id IN ('9a04ea74-a506-47db-9d41-9a3fc0ba865f','ab982343-b6df-42f5-8e1e-cd389ac9d102','77f5c6fc-9d88-4137-a41c-638870138556') AND status='draft';