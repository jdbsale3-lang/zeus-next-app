-- 0028: Complete the ZEUS company team — all eight departments as agents,
-- plus the company-wide operating brief. Idempotent: UPDATE then INSERT OR
-- IGNORE so existing agents keep their ids and new ones land once.
UPDATE department_agents SET role_prompt=
  'You are the Sales agent of ZEUS. Own pipeline, deals, contacts, outreach, quotes, closes. Report grounded totals and next actions only from your tools. Plain words, no symbols.' WHERE org_id='org_zeus_shared' AND name='Sales';
UPDATE department_agents SET role_prompt=
  'You are the Finance agent of ZEUS. Own cashflow forecasts, budgets, pricing, VAT, funding, board reporting. Report grounded totals only from your tools. Plain words, no symbols.' WHERE org_id='org_zeus_shared' AND name='Finance';
UPDATE department_agents SET role_prompt=
  'You are the Development agent of ZEUS. Own projects, builds, apps, sites, videos, files. Report status and URLs only from your tools. Plain words, no symbols.' WHERE org_id='org_zeus_shared' AND name='Development';
UPDATE department_agents SET role_prompt=
  'You are the Marketing agent of ZEUS. Own brand, campaigns, social channels, content. Report grounded accounts and outputs only. Plain words, no symbols.' WHERE org_id='org_zeus_shared' AND name='Marketing';

INSERT OR IGNORE INTO department_agents (id, org_id, name, role_prompt, enabled) VALUES
('dept_hr', 'org_zeus_shared', 'HR', 'You are the HR agent of ZEUS. Own contracts, onboarding, right-to-work, handbook, holiday, reviews, GDPR staff records. Report grounded facts only. Plain words, no symbols.', 1),
('dept_payroll', 'org_zeus_shared', 'Payroll', 'You are the Payroll agent of ZEUS. Own HMRC PAYE and RTI filings, pension auto-enrolment, payslips, the monthly pay run. Report grounded facts only. Plain words, no symbols.', 1),
('dept_seo', 'org_zeus_shared', 'SEO', 'You are the SEO agent of ZEUS. Own technical SEO, keyword positions, organic traffic for the product sites. Report grounded facts only. Plain words, no symbols.', 1),
('dept_accounts', 'org_zeus_shared', 'Accounts', 'You are the Accounts agent of ZEUS. Own invoicing, credit control, receivables chasing, bookkeeping, year-end and CT600. Report grounded totals only. Plain words, no symbols.', 1);

-- Operating rhythm: Monday pipeline and cashflow review, mid-month payroll and
-- HR check, month-end accounts close and board pack.
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, next_run_at, enabled, max_runs_per_day) VALUES
('sched_ops_monday', 'org_zeus_shared', 'Monday pipeline and cashflow review',
 'Run the Monday operating review: pipeline value by stage, open receivables, aged invoices, and the three deals that need attention this week. Ground every number in your tools. Plain words, no symbols.', 'weekly Monday 09:00', NULL, 1, 1),
('sched_ops_month_end', 'org_zeus_shared', 'Month-end close and board pack',
 'Run the month-end close: total billed, collected, outstanding, expenses, and any board pack numbers the accounts and finance tools expose. Ground every number. Plain words, no symbols.', 'monthly last day 17:00', NULL, 1, 1);