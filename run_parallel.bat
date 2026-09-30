@echo off
echo ============================================================
echo Running login tests in parallel across Chrome, Firefox, Edge
echo ============================================================

REM Launch all 3 browser runs simultaneously using Windows START
start "Login-Chrome" /wait cmd /c "py -m robot --variable BROWSER:chromium --outputdir results/chrome --name Login-Chrome tests/login.robot > results/chrome_run.log 2>&1"
start "Login-Firefox" cmd /c "py -m robot --variable BROWSER:firefox --outputdir results/firefox --name Login-Firefox tests/login.robot > results/firefox_run.log 2>&1"
start "Login-Edge" cmd /c "py -m robot --variable BROWSER:webkit --outputdir results/edge --name Login-Edge tests/login.robot > results/edge_run.log 2>&1"

REM Wait a moment then check logs
timeout /t 120 /nobreak > nul

echo ============================================================
echo Chrome results:
type results\chrome_run.log
echo.
echo Firefox results:
type results\firefox_run.log
echo.
echo Edge/webkit results:
type results\edge_run.log
echo ============================================================
echo Reports: results/chrome/report.html, results/firefox/report.html, results/edge/report.html
