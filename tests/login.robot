*** Settings ***
Documentation     Login test suite for OrangeHRM Demo.
...               Covers positive, negative, validation, and security scenarios.
...               Uses Page Object Model via resources/pages/login_page.resource.

Library           Browser
Resource          ../resources/variables.resource
Resource          ../resources/common.resource
Resource          ../resources/pages/login_page.resource
Resource          ../resources/pages/dashboard_page.resource

Suite Setup       Suite Setup With Browser
Suite Teardown    Suite Teardown With Browser
Test Setup        Test Setup Default
Test Teardown     Test Teardown With Screenshot

*** Test Cases ***

# ── Positive Tests ────────────────────────────────────────────────────────────

TC01 - Valid Login Redirects To Dashboard
    [Documentation]    A user with valid credentials should be redirected to the dashboard.
    [Tags]    login    smoke    positive
    Open Login Page
    Login With Credentials    ${VALID_USER}    ${VALID_PASS}
    Verify Dashboard Is Displayed
    Verify Dashboard Header

TC02 - Login Page Title And Heading Are Correct
    [Documentation]    The browser title must be "OrangeHRM" and the Login heading must be visible.
    [Tags]    login    smoke    positive    ui
    Open Login Page
    Verify Page Title Is Correct
    Verify Login Heading Is Visible

TC03 - Successful Login Then Logout Returns To Login Page
    [Documentation]    After a successful login the user can log out and return to the login page.
    [Tags]    login    smoke    positive    e2e
    Open Login Page
    Login With Credentials    ${VALID_USER}    ${VALID_PASS}
    Verify Dashboard Is Displayed
    Logout
    Verify Login Heading Is Visible

# ── Negative Tests ────────────────────────────────────────────────────────────

TC04 - Invalid Credentials Show Error Message
    [Documentation]    Submitting wrong username and password shows "Invalid credentials".
    [Tags]    login    negative
    Open Login Page
    Login With Credentials    ${INVALID_USER}    ${INVALID_PASS}
    Verify Login Error Message

TC05 - Correct Username Wrong Password Shows Error
    [Documentation]    Correct username with wrong password still shows "Invalid credentials".
    [Tags]    login    negative
    Open Login Page
    Login With Credentials    ${VALID_USER}    ${INVALID_PASS}
    Verify Login Error Message

TC06 - Wrong Username Correct Password Shows Error
    [Documentation]    Wrong username with correct password still shows "Invalid credentials".
    [Tags]    login    negative
    Open Login Page
    Login With Credentials    ${INVALID_USER}    ${VALID_PASS}
    Verify Login Error Message

# ── Validation Tests ──────────────────────────────────────────────────────────

TC07 - Empty Username Shows Required Validation
    [Documentation]    Submitting with an empty username shows a required-field error.
    [Tags]    login    negative    validation
    Open Login Page
    Fill Login Form    ${EMPTY}    ${VALID_PASS}
    Submit Login Form
    Verify Required Field Error Is Displayed

TC08 - Empty Password Shows Required Validation
    [Documentation]    Submitting with an empty password shows a required-field error.
    [Tags]    login    negative    validation
    Open Login Page
    Fill Login Form    ${VALID_USER}    ${EMPTY}
    Submit Login Form
    Verify Required Field Error Is Displayed

TC09 - Both Fields Empty Shows Required Validation
    [Documentation]    Submitting with both fields empty shows required-field errors.
    [Tags]    login    negative    validation
    Open Login Page
    Fill Login Form    ${EMPTY}    ${EMPTY}
    Submit Login Form
    Verify Required Field Error Is Displayed

TC10 - Whitespace Only Username Shows Validation Or Credentials Error
    [Documentation]    A username containing only spaces is rejected — either a required-field
    ...                validation error or an invalid-credentials alert must appear.
    [Tags]    login    negative    boundary
    Open Login Page
    Fill Login Form    ${SPACE}    ${VALID_PASS}
    Submit Login Form
    ${validation_count}=    Get Element Count    span.oxd-input-field-error-message
    ${alert_count}=         Get Element Count    p.oxd-alert-content-text
    Should Be True    ${validation_count} > 0 or ${alert_count} > 0
    ...    Expected a validation or credentials error but neither appeared

# ── Security / Boundary Tests ─────────────────────────────────────────────────

TC11 - SQL Injection In Username Does Not Bypass Login
    [Documentation]    A SQL injection payload in the username must not grant access.
    [Tags]    login    negative    security
    Open Login Page
    Login With Credentials    ' OR '1'='1    ${VALID_PASS}
    Verify Login Error Message

TC12 - XSS Payload In Username Does Not Execute
    [Documentation]    An XSS payload in the username must not execute and must show an error.
    [Tags]    login    negative    security
    Open Login Page
    Login With Credentials    <script>alert(1)</script>    ${VALID_PASS}
    Verify Login Error Message

TC13 - Very Long Username Does Not Crash The Page
    [Documentation]    A 256-character username should be handled gracefully (error, not crash).
    [Tags]    login    negative    boundary
    ${long_string}=    Evaluate    'x' * 256
    Open Login Page
    Login With Credentials    ${long_string}    ${VALID_PASS}
    Verify Login Error Message

# ── Data-Driven Tests ─────────────────────────────────────────────────────────

TC14 - Data Driven Invalid Login - Wrong Username And Password
    [Documentation]    Data-driven: wrong username and password shows error.
    [Tags]    login    negative    data-driven
    Open Login Page
    Login With Credentials    wronguser    wrongpass
    Verify Login Error Message

TC15 - Data Driven Invalid Login - Correct Username Wrong Password
    [Documentation]    Data-driven: correct username with wrong password shows error.
    [Tags]    login    negative    data-driven
    Open Login Page
    Login With Credentials    Admin    wrongpass
    Verify Login Error Message

TC16 - Data Driven Invalid Login - Wrong Username Correct Password
    [Documentation]    Data-driven: wrong username with correct password shows error.
    [Tags]    login    negative    data-driven
    Open Login Page
    Login With Credentials    wronguser    admin123
    Verify Login Error Message
