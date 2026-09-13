-- ============================================================
-- 0081_audit_immutability.sql - append-only enforcement
-- Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
-- REAL estate chain (platform repo). Tables verified ALREADY
-- EXIST: tool_audit + policy_rules (0074_zeus_ops_upgrade),
-- shopify_sync_log (0067). This migration ONLY adds the
-- enforcement that is currently MISSING estate-wide: nothing
-- guards tool_audit from UPDATE/DELETE today (verified: no
-- RAISE(ABORT) anywhere in the chain).
-- Pure additive: CREATE TRIGGER IF NOT EXISTS, no table changes.
-- Apply: platform deploy runs app/migrations/*.sql at deploy
-- (manifest "db": true). No manual wrangler needed.
-- ============================================================

-- 1) audit trail is append-only - agents cannot rewrite history
CREATE TRIGGER IF NOT EXISTS guard_audit_no_update
BEFORE UPDATE ON tool_audit
BEGIN
  SELECT RAISE(ABORT, 'tool_audit is append-only: UPDATE blocked (pol_audit_immutable)');
END;

-- 2) audit trail cannot be deleted
CREATE TRIGGER IF NOT EXISTS guard_audit_no_delete
BEFORE DELETE ON tool_audit
BEGIN
  SELECT RAISE(ABORT, 'tool_audit is append-only: DELETE blocked (pol_audit_immutable)');
END;

-- 3) record that the guard exists in the estate registry (idempotent)
INSERT OR IGNORE INTO asset_registry (id, category, name, vendor, notes, status)
VALUES ('ast_policy_audit_immutable', 'policy', 'Audit immutability guard', 'ZEUS',
        '0081: tool_audit UPDATE/DELETE blocked by RAISE(ABORT) triggers - audit trail append-only.',
        'active');
-- ============================================================
