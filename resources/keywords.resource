*** Settings ***
Library     Browser

*** Keywords ***

Open Login Page
    [Documentation]    Navigate to the OrangeHRM login page.
    New Page    ${BASE_URL}

Fill Login Form
    [Documentation]    Fill username and password fields.
    [Arguments]    ${username}    ${password}
    Fill Text    input[name="username"]    ${username}
    Fill Text    input[name="password"]    ${password}

Submit Login Form
    [Documentation]    Click the Login button.
    Click    button.oxd-button.oxd-button--medium.oxd-button--main

Verify Dashboard Is Displayed
    [Documentation]    Assert the user is redirected to the dashboard.
    Wait For Elements State    h6    visible    timeout=10s
    Get Url    contains    /dashboard/index

Verify Error Message Is Displayed
    [Documentation]    Assert the invalid credentials error alert is visible.
    Wait For Elements State    p.oxd-text.oxd-text--p.oxd-alert-content-text    visible    timeout=10s
    Get Text    p.oxd-text.oxd-text--p.oxd-alert-content-text    ==    Invalid credentials

Verify Required Field Error Is Displayed
    [Documentation]    Assert at least one required field error is visible.
    Wait For Elements State    span.oxd-input-field-error-message    visible    timeout=10s

Close Login Page
    [Documentation]    Close the current browser page.
    Close Page
