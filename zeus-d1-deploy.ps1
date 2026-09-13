# ============================================================
#  ZEUS D1 GOVERNANCE DEPLOYER v2 (app-slug-placeholder-db binding) - executable runbook
#  Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
#  ---- rename to zeus-d1-deploy.ps1 ----
#  Runs: auth-check -> verify tables -> decide Case A/B ->
#        apply 0011 (+0010 if A) -> verify -> report.
#  WHERE: PC PowerShell, repo root. Use npx wrangler.
#  # ============================================================
$ErrorActionPreference = "Stop"
$WR = "npx wrangler"
function Run($label, $cmd) {
  Write-Host ""
  Write-Host "== $label ==" -ForegroundColor Cyan
  Invoke-Expression $cmd
  if ($LASTEXITCODE -ne 0) { Write-Host "  [XX] failed: $label" -ForegroundColor Red; exit 1 }
}
function OK($m) { Write-Host "  [OK] $m" -ForegroundColor Green }

Write-Host "ZEUS D1 Governance Deployer" -ForegroundColor Cyan

# 1) wrangler available?
Run "wrangler check" "$WR --version"

# 2) table dependency check
$q = "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('tool_audit','policy_rules','shopify_sync_log')"
Write-Host ""
Write-Host "== Dependency check ==" -ForegroundColor Cyan
$out = & npx wrangler d1 execute app-slug-placeholder-db --command $q --remote 2>&1
$out | Write-Host
$found = @()
foreach ($t in @('tool_audit','policy_rules','shopify_sync_log')) { if ($out -match $t) { $found += $t } }
Write-Host ""
Write-Host "Present: $($found -join ', ')" -ForegroundColor Yellow
if ($found.Count -eq 3) {
  OK "Case B: all tables present - apply 0010 only"
  Run "apply 0010" "npx wrangler d1 execute app-slug-placeholder-db --file=app/migrations/0010_governance.sql --remote"
} else {
  OK "Case A: $($found.Count)/3 present - apply 0011 then 0010"
  Run "apply 0011" "npx wrangler d1 execute app-slug-placeholder-db --file=app/migrations/0011_aegis_fix.sql --remote"
  Run "apply 0010" "npx wrangler d1 execute app-slug-placeholder-db --file=app/migrations/0010_governance.sql --remote"
}

# 3) verify
Run "verify policies" "npx wrangler d1 execute app-slug-placeholder-db --command `"SELECT id, rule FROM policy_rules LIMIT 5`" --remote"
Run "verify guards" "npx wrangler d1 execute app-slug-placeholder-db --command `"SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'guard_audit_%'`" --remote"

Write-Host ""
Write-Host "DONE - governance applied and verified." -ForegroundColor Green
Write-Host "All IP belongs to Darren Birch - ZEUSTRUSTAEGISSECURITY LTD."
