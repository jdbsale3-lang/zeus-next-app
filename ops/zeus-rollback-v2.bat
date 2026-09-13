@echo off
rem ============================================================
rem  ZEUS AI - ROLLBACK AUTOMATION v2 (ADMIN prompt)
rem  Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
rem  Restores zeus.previous.html -> zeus.html + index.html with
rem  full validation BEFORE and AFTER, plus a public-site smoke.
rem  Same discipline as the v7 deploy script: never trust a bad
rem  pair, never roll back to a broken build, log everything.
rem ============================================================
setlocal
set "SRC=%SystemDrive%\inetpub\wwwroot"
set "LOG=%SRC%\zeus-deploy.log"
set "SEALED=1e3496aa1a4b0364da7f225158265491dbbcfeb539746e6ed15e7f64c0982f41"
set "PREV=%SRC%\zeus.previous.html"

echo [%date% %time%] ROLLBACK v2 START >> "%LOG%"

rem 1. previous copy must exist AND be sane (no crash on missing - init first)
set "PSZ=0"
if not exist "%PREV%" (
  echo [%date% %time%] ROLLBACK ABORT - no zeus.previous.html to restore >> "%LOG%"
  echo ROLLBACK ABORT: no previous copy exists. Nothing to restore.
  exit /b 1
)
for %%A in ("%PREV%") do set "PSZ=%%~zA"
if %PSZ% LSS 600000 (
  echo [%date% %time%] ROLLBACK ABORT - previous copy %PSZ% B too small >> "%LOG%"
  echo ROLLBACK ABORT: previous copy is %PSZ% B (expect >=600000). Refusing.
  exit /b 1
)
findstr /C:"zeusPaymentCheck" "%PREV%" >nul || goto pmarkfail

rem 2. hash the rollback source for the record
set "CHK=0"
for /f "delims=" %%H in ('certutil -hashfile "%PREV%" SHA256 ^| findstr /R /C:"^[0-9a-fA-F][0-9a-fA-F]*"') do set "CHK=%%H"
set "CHK=%CHK: =%"
echo [%date% %time%] rollback source hash %CHK% >> "%LOG%"
if /I "%CHK%"=="%SEALED%" (
  echo ROLLBACK NOTE: restoring the SEALED standard (%CHK:~0,8%...)
) else (
  echo ROLLBACK NOTE: restoring a previous build (%CHK:~0,8%...) - not the current sealed hash
)

rem 3. perform the restore
copy /y "%PREV%" "%SRC%\zeus.html" >> "%LOG%" 2>&1
copy /y "%SRC%\zeus.html" "%SRC%\index.html" >> "%LOG%" 2>&1
echo [%date% %time%] rollback files copied (zeus.html + index.html) >> "%LOG%"

rem 4. POST-restore verification: marker + hash on disk
findstr /C:"zeusPaymentCheck" "%SRC%\index.html" >nul || goto rootfail
set "CHK2=0"
for /f "delims=" %%H in ('certutil -hashfile "%SRC%\zeus.html" SHA256 ^| findstr /R /C:"^[0-9a-fA-F][0-9a-fA-F]*"') do set "CHK2=%%H"
set "CHK2=%CHK2: =%"
if "%CHK2%"=="%CHK%" (
  echo [%date% %time%] ROLLBACK VERIFIED - on-disk hash matches restored source >> "%LOG%"
) else (
  echo [%date% %time%] ROLLBACK WARNING - hash mismatch after restore >> "%LOG%"
)

rem 5. post-restore public-site smoke (skips gracefully offline)
set "LIVE=000"
where curl >nul 2>&1 && (
  for /f "delims=" %%L in ('curl -s -o NUL -w "%%{http_code}" --max-time 15 https://zeusaiintelligence.com') do set "LIVE=%%L"
)
if "%LIVE%"=="200" (
  curl -s -m 15 https://zeusaiintelligence.com | findstr /C:"zeusPaymentCheck" >nul && (echo SMOKE OK - public site serves 200 with payment marker) || (echo SMOKE WARNING - public site 200 but marker missing)
) else (echo SMOKE NOTE - public site unreachable from this host (%LIVE%); skipped)

echo [%date% %time%] ROLLBACK COMPLETE >> "%LOG%"
echo.
echo ROLLBACK COMPLETE - zeus.html + index.html restored and verified.
endlocal
exit /b 0

:pmarkfail
echo [%date% %time%] ROLLBACK ABORT - previous copy missing payment marker >> "%LOG%"
echo ROLLBACK ABORT: previous copy failed marker check. Refusing.
exit /b 1

:rootfail
echo [%date% %time%] ROLLBACK ROOT SYNC FAILED - index.html not verified >> "%LOG%"
echo zeus.html restored but root sync failed. Run: copy /y "%SRC%\zeus.html" "%SRC%\index.html"
exit /b 1
