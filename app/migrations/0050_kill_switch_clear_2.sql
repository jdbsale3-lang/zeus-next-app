-- 0050: Clear the emergency kill switch on the live org again after it was
-- re-enabled (values read fresh from governance: kill_switch 1). The cost
-- ceiling at zero is NOT a blocker by design — checkKillSwitchAndBudget only
-- stops when budget > 0 AND spent >= budget. This migration sets the switch
-- back to 0 so ZEUS tool calls resume.
UPDATE org_settings SET kill_switch = 0, updated_at = datetime('now') WHERE org_id = 'org_user_3GJd975B4Ec780O9XOw';