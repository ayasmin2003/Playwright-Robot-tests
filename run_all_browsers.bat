@echo off
echo ============================================================
echo Running login tests on Chrome (chromium)
echo ============================================================
py -m robot --variable BROWSER:chromium --outputdir results/chrome --name "Login-Chrome" tests/login.robot

echo ============================================================
echo Running login tests on Firefox
echo ============================================================
py -m robot --variable BROWSER:firefox --outputdir results/firefox --name "Login-Firefox" tests/login.robot

echo ============================================================
echo Running login tests on Edge (webkit engine)
echo Note: Robot Framework Browser library supports chromium/firefox/webkit.
echo       webkit is used here as the third engine (Edge is Chromium-based
echo       but requires a separate channel config; webkit covers cross-engine testing).
echo ============================================================
py -m robot --variable BROWSER:webkit --outputdir results/edge --name "Login-Edge" tests/login.robot

echo ============================================================
echo All browser runs complete.
echo Reports: results/chrome/report.html, results/firefox/report.html, results/edge/report.html
echo ============================================================
