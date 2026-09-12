# ZEUS VERIFY v2 (PowerShell) - Windows deployment integrity check
# Run in PowerShell 5.1+ (ISExclude: plain console). Flat structure, exit 0/1.
$ErrorActionPreference = "Continue"
$SRC    = "$env:SystemDrive\inetpub\wwwroot"
$EXPECT = "1e3496aa1a4b0364da7f225158265491dbbcfeb539746e6ed15e7f64c0982f41"
$FAIL   = 0
$Z = Join-Path $SRC "zeus.html"
$I = Join-Path $SRC "index.html"
Write-Host ""
Write-Host "== ZEUS VERIFY v2 (PowerShell) =="

if (-not (Test-Path $Z)) { Write-Host "[1] FATAL: $Z not found"; exit 1 }

$SZ = (Get-Item $Z).Length
Write-Host "[1] size: $SZ bytes"
if ($SZ -lt 600000) { Write-Host "    FAIL - too small"; $FAIL = 1 } else { Write-Host "    ok" }

Write-Host "[2] markers:"
foreach ($m in @("zeusPaymentCheck","zeusReminderSet","AEGIS BUILT-IN","zeusFilingCheck","zeusDementiaPanel","zeusSwarmMonitor")) {
  if (Select-String -Path $Z -SimpleMatch $m -Quiet) { Write-Host "    $m : ok" } else { Write-Host "    $m : FAIL"; $FAIL = 1 }
}

if (Select-String -Path $I -SimpleMatch "zeusPaymentCheck" -Quiet) { Write-Host "[3] root sync: ok" }
else { Write-Host "[3] root sync: FAIL - index.html stale"; $FAIL = 1 }

$H = (Get-FileHash -Path $Z -Algorithm SHA256).Hash.ToLower()
Write-Host "[4] sha256: $H"
if ($H -ne $EXPECT) { Write-Host "    FAIL - mismatch, expected $EXPECT"; $FAIL = 1 } else { Write-Host "    MATCH - sealed standard" }

if (Test-Path (Join-Path $SRC "zeus.previous.html")) { Write-Host "[5] rollback copy: present" }
else { Write-Host "[5] rollback copy: MISSING (info only)"; $FAIL = 1 }

Write-Host ""
if ($FAIL -ne 0) { Write-Host "RESULT: FAIL - see lines above."; exit 1 }
Write-Host "RESULT: PASS - estate verified."
exit 0
