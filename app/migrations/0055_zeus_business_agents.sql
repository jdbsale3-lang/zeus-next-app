-- 0055: ZEUS BUSINESS AGENT TEAM — 50 biz_* scheduled agents.
-- The Second Brain renders two squads of 50: the SEO task force (seo_*) and
-- this business team (biz_*). Each agent runs a grounded department sweep on
-- its cadence and writes its result into scheduled_runs. Plain words only.
INSERT OR IGNORE INTO scheduled_agents (id, org_id, name, prompt, schedule, enabled, max_runs_per_day, email_to) VALUES
-- SALES (8)
('biz_sales_pipeline','org_zeus_shared','Sales: Pipeline Runner','Run the sales pipeline sweep. Pull deals by stage, flag deals with no movement for 7 days, name the next best action for the top three closes. Ground every number in the deals tool. Plain words, no symbols.','every Monday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_sales_outreach','org_zeus_shared','Sales: Outreach Planner','Plan the outreach sequence for today: target list from qualified leads, next touch for each, and the hook for each contact. Only use real contacts from the tools. Plain words.','every weekday 08:30',1,4,'jdbsale3@gmail.com'),
('biz_sales_quotes','org_zeus_shared','Sales: Quote Watcher','Sweep open quotes and proposals. Flag any quote sent more than 7 days ago with no reply and any quote approaching the expiry date. Plain words, no invented numbers.','every Monday 10:00',1,4,'jdbsale3@gmail.com'),
('biz_sales_followup','org_zeus_shared','Sales: Follow-up Chaser','List the deals that need a follow-up this week with the exact stage and last activity date. Create a task for each. Plain words. only task rows returned by the tools.','every Monday 10:30',1,4,'jdbsale3@gmail.com'),
('biz_sales_winback','org_zeus_shared','Sales: Win-back Scout','Sweep contacts and deals for lapsed or stalled opportunities older than 60 days with no activity. Name the three worth a win-back note. Plain words.','weekly Tuesday 11:00',1,4,'jdbsale3@gmail.com'),
('biz_sales_partners','org_zeus_shared','Sales: Partner Rail','Check the partner and referral connections. List each connected partner, its status, and the last sync. Flag any partner needing a reconnect. Plain words.','weekly Wednesday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_sales_nhs','org_zeus_shared','Sales: AEGIS-NHS Track','Pull the NHS and AEGIS track state. Report pipeline value, stage, and the next commercial action on the procurement plan. Only report what the tools return. Plain words.','weekly Monday 08:00',1,4,'jdbsale3@gmail.com'),
('biz_sales_referrals','org_zeus_shared','Sales: Referral Miner','From contacts and connected tools, find referral events and satisfied references from the last 90 days that could seed two new conversations. Plain words.','weekly Friday 09:00',1,4,'jdbsale3@gmail.com'),
-- ACCOUNTS (5)
('biz_acct_cashflow','org_zeus_shared','Accounts: Cashflow','Pull the cash position from invoicing. Report money in, money out, and the top three inflows this week. Ground every number. Plain words.','every weekday 08:00',1,4,'jdbsale3@gmail.com'),
('biz_acct_invoicing','org_zeus_shared','Accounts: Invoicing','Sweep billable work and open orders. Flag anything billable with no invoice raised and invoice any approved zero-stress items. Plain words.','weekly Monday 14:00',1,4,'jdbsale3@gmail.com'),
('biz_acct_chasing','org_zeus_shared','Accounts: Debt Chase','Identify unpaid invoices past due, their age, and draft a chase note for each. Never invent amounts. Plain words.','every weekday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_acct_aging','org_zeus_shared','Accounts: Aging Report','Produce the receivables aging summary by bucket. State overdue total and the worst invoice by age. Plain words, at most one line per invoice.','weekly Friday 08:00',1,4,'jdbsale3@gmail.com'),
('biz_acct_recon','org_zeus_shared','Accounts: Recon Check','Check invoice vs payment totals for the month. Report any invoice that is paid, partially paid, or unmatched. Plain words.','monthly on the 1st 09:00',1,4,'jdbsale3@gmail.com'),
-- FINANCE (5)
('biz_fin_forecast','org_zeus_shared','Finance: Forecast','Produce a cash and pipeline forecast for the next 30 days. Flag shortfall risk if the runway drops under 60 days. Ground every number. Plain words.','every Monday 08:00',1,4,'jdbsale3@gmail.com'),
('biz_fin_budget','org_zeus_shared','Finance: Budget','Compare budget ceiling to spend from governance and tools. Flag at or over ceiling and warn from 80 percent. Plain words.','every Monday 08:45',1,4,'jdbsale3@gmail.com'),
('biz_fin_cash','org_zeus_shared','Finance: Cash Position','State the cash position card: collected, outstanding, pipeline, and the single number the founder must know today. Plain words.','daily 07:40',1,4,'jdbsale3@gmail.com'),
('biz_fin_board','org_zeus_shared','Finance: Board Pack','Assemble the board pack numbers: totals, pipeline, receivables, spend, headcount-ready rows. Plain words, under 300.','monthly on the 1st 08:00',1,4,'jdbsale3@gmail.com'),
('biz_fin_tax','org_zeus_shared','Finance: Tax Calendar','Sweep HMRC deadlines from governance and flag the next 3 payment dates. Never invent amounts. Plain words.','every 1st Monday 09:00',1,4,'jdbsale3@gmail.com'),
-- DEVELOPMENT (7)
('biz_dev_builds','org_zeus_shared','Dev: Build Watch','List build requests by status and flag anything queued longer than 7 days or blocked on a dependency. Plain words.','every weekday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_dev_qa','org_zeus_shared','Dev: QA Gate','Sweep released builds and their verification state. Flag any build, site, or app not verified. Report facts only.','daily 09:30',1,4,'jdbsale3@gmail.com'),
('biz_dev_deploys','org_zeus_shared','Dev: Deploy Radar','Check live deployments and URLs return healthy status. Report each URL and its status, and list any failing. Plain words.','daily 10:00',1,4,'jdbsale3@gmail.com'),
('biz_dev_security','org_zeus_shared','Dev: Security Sweep','Run the security checklist sweep: keys, secrets, audit fixes, readiness gates. Flag anything open or revoked. Plain words','daily 07:20',1,4,'jdbsale3@gmail.com'),
('biz_dev_incidents','org_zeus_shared','Dev: Incident Watch','Sweep audit and latency rows for errors in the last 24 hours. List each incident, latency breach, and fix owner. Only report what the tools return.','daily 07:10',1,4,'jdbsale3@gmail.com'),
('biz_dev_roadmap','org_zeus_shared','Dev: Roadmap','From builds and projects, summarize the roadmap: shipped, in build, and planned for the quarter. Plain words.','weekly Monday 11:00',1,4,'jdbsale3@gmail.com'),
('biz_dev_ci','org_zeus_shared','Dev: CI Health','Check the build pipeline states and flag any failure. Report each pipeline row with status. Plain words.','every hour 07:00-19:00',1,4,'jdbsale3@gmail.com'),
-- MARKETING (7)
('biz_mkt_calendar','org_zeus_shared','Marketing: Calendar','Plan the week content calendar for X, LinkedIn, TikTok and YouTube from connected accounts. Log the plan as a note with tasks.','every Monday 10:00',1,4,'jdbsale3@gmail.com'),
('biz_mkt_content','org_zeus_shared','Marketing: Content','Review drafts on the publishing queue and flag anything ready or stale. Plain words.','weekly Wednesday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_mkt_social','org_zeus_shared','Marketing: Social','Check connected social accounts for errors and pending posts. Flag anything failed. Plain words.','daily 09:00',1,4,'jdbsale3@gmail.com'),
('biz_mkt_email','org_zeus_shared','Marketing: Email','Check the outbox for unsent letters and email routes. Flag any letter addressed and unsent. Plain words.','daily 08:00',1,4,'jdbsale3@gmail.com'),
('biz_mkt_ads','org_zeus_shared','Marketing: Ads','If an ad account is connected, report its status and campaign activity. If none connected, say so.','weekly Monday 12:00',1,4,'jdbsale3@gmail.com'),
('biz_mkt_seo_link','org_zeus_shared','Marketing: SEO-Biz Link','Check the link between business goals and the SEO task force. Report which SEO agents are live and the last result each produced. Plain words.','weekly Monday 07:00',1,4,'jdbsale3@gmail.com'),
('biz_mkt_brand','org_zeus_shared','Marketing: Brand Watch','Check brand assets and web_pages for outdated company claims (company, officer, office). Flag any stale page. Plain words.','weekly Friday 09:00',1,4,'jdbsale3@gmail.com'),
-- HR (6)
('biz_hr_onboarding','org_zeus_shared','HR: Onboarding','List new starter tasks: contracts, right to work, policies, and any missing hire file. Flag what is missing. Plain words.','every Monday 11:00',1,4,'jdbsale3@gmail.com'),
('biz_hr_righttowork','org_zeus_shared','HR: Right to Work','Sweep right-to-work documents for expiring or missing. Just list the items to fix, never invent. Plain words.','weekly Wednesday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_hr_holiday','org_zeus_shared','HR: Holiday','List holiday requests and approved days this month and remaining allowance for the founder. Plain words.','monthly on the 1st 09:00',1,4,'jdbsale3@gmail.com'),
('biz_hr_reviews','org_zeus_shared','HR: Reviews','Check upcoming review due dates within 30 days and flag overdue reviews with their date. Plain words.','weekly Monday 11:00',1,4,'jdbsale3@gmail.com'),
('biz_hr_policies','org_zeus_shared','HR: Policies','Verify policy documents exist and are current. Report only the store rows. Plain words.','monthly on the 15th 09:00',1,4,'jdbsale3@gmail.com'),
('biz_hr_offboarding','org_zeus_shared','HR: Offboarding','Check offboarding checklist status for anyone no longer active and flag tasks overdue. Plain words.','monthly on the 1st 10:00',1,4,'jdbsale3@gmail.com'),
-- PAYROLL (4)
('biz_pay_monthly','org_zeus_shared','Payroll: Monthly Run','Prepare monthly pay run checklist: HMRC deadlines, pension, PAYE, payslips. Create tasks per step. Plain words.','monthly on the 18th 09:00',1,4,'jdbsale3@gmail.com'),
('biz_pay_paye','org_zeus_shared','Payroll: PAYE','Check PAYE submission dates and flag the next deadline with days remaining. Plain words.','monthly on the 5th 08:00',1,4,'jdbsale3@gmail.com'),
('biz_pay_pensions','org_zeus_shared','Payroll: Pensions','Check pension enrolment grace period status and flag any missed. Plain words.','monthly on the 5th 09:00',1,4,'jdbsale3@gmail.com'),
('biz_pay_payslips','org_zeus_shared','Payroll: Payslips','Sweep payslip delivery status for the last run and flag missing recipients. Plain words.','monthly on the 18th 14:00',1,4,'jdbsale3@gmail.com'),
-- LEGAL (4)
('biz_leg_contracts','org_zeus_shared','Legal: Contracts','Sweep contracts and agreements

for expiry and renewal dates in the next 60 days. Flag each with its date. Plain words.','weekly Monday 10:00',1,4,'jdbsale3@gmail.com'),
('biz_leg_compliance','org_zeus_shared','Legal: Compliance','Check compliance evidence files and audit rows. Flag any checkbox or finding still open. Plain words.','weekly Tuesday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_leg_audit','org_zeus_shared','Legal: Audit Prep','Stage the audit readiness list: files, addresses, evidence rows, and the open fixes. Report only rows returned. Plain words.','monthly on the 1st 09:00',1,4,'jdbsale3@gmail.com'),
('biz_leg_ip','org_zeus_shared','Legal: IP','Review the IP ledger (JDB Sales owns ZEUS IP) and flag any licence or assign agreement that needs a renewal. Plain words.','monthly on the 5th 10:00',1,4,'jdbsale3@gmail.com'),
-- OPS (4)
('biz_ops_ready','org_zeus_shared','Ops: Go-Live Readiness','Run the readiness sweep: email key, sender, outbox letters, first invoice, voice, agents. End with READY or NOT READY and the blocker.','daily 08:15',1,4,'jdbsale3@gmail.com'),
('biz_ops_suppliers','org_zeus_shared','Ops: Suppliers','List vendor and service connections with status. Flag any disconnected or needing a key. Plain words.','weekly Monday 09:00',1,4,'jdbsale3@gmail.com'),
('biz_ops_assets','org_zeus_shared','Ops: Assets','Sweep the asset registry for renewals within 30 days and flag anything due to renew with days remaining. Plain words.','every 15th 09:00',1,4,'jdbsale3@gmail.com'),
('biz_ops_continuity','org_zeus_shared','Ops: Continuity','Check the continuity drills state: backups, kill switches, and runbooks. Flag what is missing. Plain words.','every 1st 09:00',1,4,'jdbsale3@gmail.com');