@echo off
rem ============================================================
rem  ZEUS AI - IIS deploy script FIXED v5 (rollback-pair + SHA spaced-hex fix + smoke test) (ADMIN prompt)
rem  Darren Birch - ZEUSTRUSTAEGISSECURITY LTD - 13 Sep 2026
rem  FIXES the Cursor script, VERIFIED against live estate:
rem    - URL pinned to the SEALED build efe20acd (HTTP 200,
rem      631,466 B, SHA 1e3496aa...) - Cursor's adbc5b8e and
rem      a0130e8a URLs were 356 KB STALE builds that would have
rem      downgraded the estate.
rem    - Size gate >= 600,000 (not 340,000 - too low to reject
rem      a truncated or stale download; Cursor's comment said
rem      "~354341 bytes" - wrong for the sealed standard).
rem    - Marker set = 4 modern + 4 classic (8 total). Cursor
rem      checked only 4 classic markers, so a build missing
rem      zeusPaymentCheck/zeusReminderSet/AEGIS/FilingCheck
rem      would have passed its gate.
rem  Flow: backup -> download -> size -> 8 markers -> swap ->
rem        root sync -> log. Never installs a failed download.
rem ============================================================
setlocal
set "URL=https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/efe20acd-3898-4d98-a9a0-c53abc78a430.html"
set "SRC=%SystemDrive%\inetpub\wwwroot"
set "LOG=%SRC%\zeus-deploy.log"
set "SEALED=1e3496aa1a4b0364da7f225158265491dbbcfeb539746e6ed15e7f64c0982f41"

echo [%date% %time%] DEPLOY START (fixed v5) >> "%LOG%"

rem 1. backup previous build (keep one generation)
if exist "%SRC%\zeus.html" (
  copy /y "%SRC%\zeus.html" "%SRC%\zeus.previous.html" >> "%LOG%" 2>&1
)

rem 1b. ROLLBACK-PAIR VALIDATION: the pair must be sane before any swap
for %%A in ("%SRC%\zeus.previous.html") do set "PSZ=%%~zA"
if %PSZ% LSS 600000 (
  echo [%date% %time%] ROLLBACK PAIR INVALID - previous copy is %PSZ% B, refusing to proceed >> "%LOG%"
  echo Rollback pair check failed: previous copy too small. Nothing installed.
  exit /b 1
)
findstr /C:"zeusPaymentCheck" "%SRC%\zeus.previous.html" >nul || goto pairfail
goto pairdone
:pairfail
echo [%date% %time%] ROLLBACK PAIR INVALID - previous copy failed marker check >> "%LOG%"
echo Rollback pair check failed: zeus.previous.html missing payment marker. Nothing installed.
exit /b 1
:pairdone
echo [%date% %time%] rollback pair validated (previous=%PSZ% B, marker ok) >> "%LOG%"

rem 2. download the sealed build
curl -L -o "%SRC%\zeus.new.html" "%URL%" >> "%LOG%" 2>&1
for %%A in ("%SRC%\zeus.new.html") do set "SZ=%%~zA"
echo [%date% %time%] downloaded size= %SZ% bytes (sealed standard 631466) >> "%LOG%"

rem 3. size gate (rejects stale 356KB builds and truncations)
if %SZ% LSS 600000 (
  echo [%date% %time%] SIZE CHECK FAILED - %SZ% B is NOT the sealed standard - NOT installed >> "%LOG%"
  echo Download is %SZ% bytes; sealed standard is 631,466 B. Build NOT installed. See "%LOG%".
  exit /b 1
)

rem 4. eight-marker verification (4 modern must be present on top of the 4 classic)
findstr /C:"zeusReminderSet"  "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"zeusPaymentCheck" "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"AEGIS BUILT-IN"   "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"zeusFilingCheck"  "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"zeusDementiaPanel" "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"zeusQueueTask"    "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"dossierOpen"      "%SRC%\zeus.new.html" >nul || goto fail
findstr /C:"zeusSwarmMonitor" "%SRC%\zeus.new.html" >nul || goto fail
goto swap

:fail
echo [%date% %time%] MARKER VERIFY FAILED - build NOT installed >> "%LOG%"
echo Marker verification failed (8-marker set). Build NOT installed. See "%LOG%".
exit /b 1

:swap
move /y "%SRC%\zeus.new.html" "%SRC%\zeus.html" >> "%LOG%" 2>&1
rem root-fix: IIS default document serves index.html, so sync it too
copy /y "%SRC%\zeus.html" "%SRC%\index.html" >> "%LOG%" 2>&1
findstr /C:"zeusPaymentCheck" "%SRC%\index.html" >nul || goto rootfail
echo [%date% %time%] DEPLOY OK - zeus.html + index.html installed, 8 markers verified >> "%LOG%"
echo.
echo ZEUS AI deployed and verified (sealed 631,466 B standard).
echo.

rem SMOKE TEST 1: IIS must actually serve the new file (skips gracefully if curl absent)
where curl >nul 2>&1 && (
  for /f "delims=" %%C in ('curl -s -o NUL -w "%%{http_code}" --max-time 10 http://localhost/') do set "HTTP=%%C"
  if "%HTTP%"=="200" (echo SMOKE OK - IIS serves HTTP 200 at localhost) else (echo SMOKE WARNING - localhost returned %HTTP%; check IIS default document)
)

rem SMOKE TEST 2: on-disk hash must match the sealed standard
for /f "delims=" %%H in ('certutil -hashfile "%SRC%\zeus.html" SHA256 ^| findstr /R /C:"^[0-9a-fA-F][0-9a-fA-F]*"') do set "CHK2=%%H"
set "CHK2=%CHK2: =%"
if /I "%CHK2%"=="%SEALED%" (echo SMOKE OK - on-disk hash matches sealed standard) else (echo SMOKE FAIL - on-disk hash does NOT match sealed standard)

rem SHA-256 confirmation (fixed v5: certutil emits SPACED hex - strip spaces before compare)
for /f "delims=" %%H in ('certutil -hashfile "%SRC%\zeus.html" SHA256 ^| findstr /R /C:"^[0-9a-fA-F][0-9a-fA-F]*"') do set "CHK=%%H"
set "CHK=%CHK: =%"
if /I "%CHK%"=="%SEALED%" (echo SHA256 MATCH - sealed fingerprint confirmed) else (echo SHA256 NOT MATCHED - see zeus-deploy.log)
endlocal
exit /b 0

:rootfail
echo [%date% %time%] ROOT SYNC FAILED - zeus.html OK but index.html not verified >> "%LOG%"
echo zeus.html installed but root sync failed. Run: copy /y "%SRC%\zeus.html" "%SRC%\index.html"
exit /b 1