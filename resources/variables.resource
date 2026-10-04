*** Variables ***

# ── Application ───────────────────────────────────────────────────────────────
${BASE_URL}             https://opensource-demo.orangehrmlive.com/web/index.php/auth/login
${API_BASE_URL}         https://opensource-demo.orangehrmlive.com/web/index.php/api/v2

# ── Browser ───────────────────────────────────────────────────────────────────
${BROWSER}              chromium
${HEADLESS}             False

# ── Credentials (override via --variable or CI env vars) ─────────────────────
${VALID_USER}           Admin
${VALID_PASS}           admin123
${INVALID_USER}         wronguser
${INVALID_PASS}         wrongpass
