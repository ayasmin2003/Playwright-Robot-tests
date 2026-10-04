*** Settings ***
Library     Browser

*** Keywords ***

# ── Navigation ──────────────────────────────────────────────────────────────

Open Login Page
    [Documentation]    Navigate to the OrangeHRM login page and wait for it to be ready.
    New Page    ${BASE_URL}
    Wait For Elements State    input[name="username"]    visible    timeout=15s

# ── Actions ──────────────────────────────────────────────────────────────────

Fill Username
    [Documentation]    Type into the username field.
    [Arguments]    ${username}
    Fill Text    input[name="username"]    ${username}

Fill Password
    [Documentation]    Type into the password field.
    [Arguments]    ${password}
    Fill Text    input[name="password"]    ${password}

Submit Login Form
    [Documentation]    Click the Login button.
    Click    button.oxd-button--main

Fill Login Form
    [Documentation]    Fill both username and password fields.
    [Arguments]    ${username}    ${password}
    Fill Username    ${username}
    Fill Password    ${password}

Login With Credentials
    [Documentation]    Full login action: fill form and submit.
    [Arguments]    ${username}    ${password}
    Fill Login Form    ${username}    ${password}
    Submit Login Form

# ── Assertions ───────────────────────────────────────────────────────────────

Verify Dashboard Is Displayed
    [Documentation]    Assert the user is redirected to the dashboard.
    Wait For Elements State    h6    visible    timeout=15s
    Get Url    contains    /dashboard/index

Verify Login Error Message
    [Documentation]    Assert the "Invalid credentials" alert is visible with correct text.
    Wait For Elements State    p.oxd-alert-content-text    visible    timeout=10s
    Get Text    p.oxd-alert-content-text    ==    Invalid credentials

Verify Required Field Error Is Displayed
    [Documentation]    Assert at least one required-field validation error is visible.
    Wait For Elements State    span.oxd-input-field-error-message >> nth=0    visible    timeout=10s

Verify Page Title Is Correct
    [Documentation]    Assert the browser tab title equals OrangeHRM.
    Get Title    ==    OrangeHRM

Verify Login Heading Is Visible
    [Documentation]    Assert the "Login" heading is visible on the page.
    Wait For Elements State    h5    visible    timeout=10s

# ── Teardown ─────────────────────────────────────────────────────────────────

Close Login Page
    [Documentation]    Close the current browser page.
    Close Page
