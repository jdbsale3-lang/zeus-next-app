-- ============================================================
-- 0012_rollback_governance.sql - reverses 0010 + 0011
-- Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
-- SAFETY: drops ONLY what 0010/0011 created. It does NOT drop
-- tool_audit / policy_rules / shopify_sync_log tables themselves
-- (they may be owned by the app schema - see migration review).
-- Seeded policy rows are deleted by id; schema-owned rows kept.
-- Apply: npx wrangler d1 execute zeus-db --file=app/migrations/0012_rollback_governance.sql --remote
-- ============================================================

-- 1) drop 0011's enforcement guards
DROP TRIGGER IF EXISTS guard_audit_no_update;
DROP TRIGGER IF EXISTS guard_audit_no_delete;

-- 2) drop 0010's audit triggers
DROP TRIGGER IF EXISTS audit_deals_ins;
DROP TRIGGER IF EXISTS audit_deals_upd;
DROP TRIGGER IF EXISTS audit_tasks_ins;
DROP TRIGGER IF EXISTS audit_contacts_ins;
DROP TRIGGER IF EXISTS audit_connections_chg;
DROP TRIGGER IF EXISTS audit_invoices_ins;
DROP TRIGGER IF EXISTS audit_shopify_sync;

-- 3) remove the 12 seeded governance policy rows (by seed id only)
DELETE FROM policy_rules WHERE id IN (
  'pol_spend_dept_500','pol_monthly_budget_2000','pol_sales_discount_20',
  'pol_finance_payment_1000','pol_payroll_human','pol_hr_no_pii_export',
  'pol_dev_deploy_prod','pol_marketing_publish','pol_seo_bulk_changes',
  'pol_data_delete','pol_external_send','pol_audit_immutable'
);

-- 4) tombstone the audit rows written by the now-dropped triggers
--    (append-only guards are gone, so this DELETE is legal now)
DELETE FROM tool_audit WHERE note IN (
  'deal created','deal modified','task created','contact created',
  'connection status changed','invoice raised','catalog sync event'
);

-- Re-apply path if needed: run 0011 then 0010 (exact current set).
-- ============================================================
