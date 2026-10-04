*** Variables ***

# ── Valid credentials ─────────────────────────────────────────────────────────
${VALID_USER}           Admin
${VALID_PASS}           admin123

# ── Invalid / boundary credentials ───────────────────────────────────────────
${INVALID_USER}         wronguser
${INVALID_PASS}         wrongpass
${SQL_INJECTION}        ' OR '1'='1
${XSS_PAYLOAD}          <script>alert(1)</script>
${LONG_STRING}          ${'x' * 256}

# ── Boundary values ───────────────────────────────────────────────────────────
${EMPTY}                ${EMPTY}
${WHITESPACE_ONLY}      ${SPACE}

# ── Data-driven login scenarios (list of dicts) ───────────────────────────────
@{INVALID_LOGIN_SCENARIOS}
...    username=wronguser     password=wrongpass      label=Wrong username and password
...    username=Admin         password=wrongpass      label=Correct username wrong password
...    username=wronguser     password=admin123       label=Wrong username correct password
...    username=${EMPTY}      password=${EMPTY}       label=Both fields empty
