*** Settings ***
Library     Browser

*** Keywords ***

# ── Assertions ───────────────────────────────────────────────────────────────

Verify Dashboard Header
    [Documentation]    Assert the Dashboard heading is visible after login.
    Wait For Elements State    h6    visible    timeout=15s
    Get Text    h6    ==    Dashboard

Verify User Menu Is Visible
    [Documentation]    Assert the top-right user dropdown is present.
    Wait For Elements State    .oxd-userdropdown-tab    visible    timeout=10s

# ── Actions ──────────────────────────────────────────────────────────────────

Logout
    [Documentation]    Open the user menu and click Logout.
    Click    .oxd-userdropdown-tab
    Wait For Elements State    text=Logout    visible    timeout=5s
    Click    text=Logout
    Wait For Elements State    input[name="username"]    visible    timeout=15s
