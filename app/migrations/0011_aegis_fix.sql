-- ============================================================
-- 0011_aegis_fix.sql — fixes 0010 gaps (DRAFT, review before apply)
-- Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
-- Verifies/fixes the 0010_governance dependencies that were NOT
-- created by any earlier migration (tool_audit, policy_rules,
-- shopify_sync_log) and ENFORCES the audit immutability that
-- 0010 only declared as a policy row.
-- Apply AFTER confirming the tables are absent:
--   wrangler d1 execute zeus-db --file=app/migrations/0011_aegis_fix.sql --remote
-- ============================================================

-- 1) the audit sink 0010's triggers INSERT into
CREATE TABLE IF NOT EXISTS tool_audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tool TEXT NOT NULL,
  args TEXT,
  outcome TEXT NOT NULL DEFAULT 'ok',
  note TEXT,
  actor TEXT,                -- who/what performed the action
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_tool_audit_tool ON tool_audit(tool);
CREATE INDEX IF NOT EXISTS idx_tool_audit_created ON tool_audit(created_at);

-- 2) the policy table 0010 seeds
CREATE TABLE IF NOT EXISTS policy_rules (
  id TEXT PRIMARY KEY,
  rule TEXT NOT NULL,
  apply_to TEXT DEFAULT 'all',
  limit_value REAL,
  action TEXT DEFAULT 'block',
  enabled INT DEFAULT 1,
  note TEXT
);

-- 3) the sync-log table 0010's trigger depends on
CREATE TABLE IF NOT EXISTS shopify_sync_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  rowid_src INTEGER,
  event TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 4) ENFORCE the immutability 0010 only declared:
--    pol_audit_immutable said tool_audit rows must never change;
--    these triggers make that a database guarantee.
CREATE TRIGGER IF NOT EXISTS guard_audit_no_update
BEFORE UPDATE ON tool_audit
BEGIN
  SELECT RAISE(ABORT, 'tool_audit is append-only: UPDATE blocked (pol_audit_immutable)');
END;

CREATE TRIGGER IF NOT EXISTS guard_audit_no_delete
BEFORE DELETE ON tool_audit
BEGIN
  SELECT RAISE(ABORT, 'tool_audit is append-only: DELETE blocked (pol_audit_immutable)');
END;

-- 5) re-run 0010's seed only if policy_rules was empty (idempotent)
INSERT OR IGNORE INTO policy_rules (id, rule, apply_to, limit_value, action, enabled, note) VALUES
('pol_spend_dept_500','No single agent-initiated spend above 500 GBP without owner approval','all',500,'approve',1,'AEGIS guardrail: spend cap per action'),
('pol_monthly_budget_2000','Agent monthly operating spend must not exceed 2000 GBP','all',2000,'block',1,'Monthly burn ceiling'),
('pol_sales_discount_20','Sales agent cannot approve discounts over 20 percent; escalate to Darren','Sales',20,'approve',1,'Pricing authority limit'),
('pol_finance_payment_1000','Finance agent cannot release payments above 1000 GBP without dual approval','Finance',1000,'approve',1,'Payment authority'),
('pol_payroll_human','Payroll and HMRC filings are prepare-only; human submission required','Payroll',NULL,'block',1,'Statutory compliance boundary'),
('pol_hr_no_pii_export','HR agent must not export employee PII outside the Second Brain','HR',NULL,'block',1,'GDPR / UK DPA 2018'),
('pol_dev_deploy_prod','Development agent requires explicit owner approval for production deploys','Development',NULL,'approve',1,'Change control'),
('pol_marketing_publish','Marketing agent may draft but not publish to X/LinkedIn/TikTok without review','Marketing',NULL,'approve',1,'Brand safety gate'),
('pol_seo_bulk_changes','SEO agent limited to 50 bulk page changes per run','SEO',50,'block',1,'Prevents runaway automation'),
('pol_data_delete','No bulk deletes over 100 rows without owner approval','all',100,'approve',1,'Data-loss protection'),
('pol_external_send','Outbound email to more than 50 recipients per hour is blocked','all',50,'block',1,'Spam/reputation guard'),
('pol_audit_immutable','tool_audit rows must never be updated or deleted by agents','all',NULL,'block',1,'Audit trail integrity');
-- ============================================================
-- NOTE on apply order: run 0011 BEFORE 0010 (it creates the
-- tables + guards) OR run 0011 after 0010 fails and re-run 0010.
-- 0010's own triggers stay valid either way (IF NOT EXISTS).
-- ============================================================
