-- ============================================================
-- 0082_rollback_audit_guards.sql - forward rollback of 0081
-- Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
-- The documented way to undo 0081: as a FORWARD migration in the
-- real series (immutable history, reversible estate).
-- Drops the append-only guards; clears the registry marker.
-- Re-apply by re-running 0081 (both are IF NOT EXISTS - idempotent).
-- ============================================================
DROP TRIGGER IF EXISTS guard_audit_no_update;
DROP TRIGGER IF EXISTS guard_audit_no_delete;
DELETE FROM asset_registry WHERE id = 'ast_policy_audit_immutable';
-- ============================================================
