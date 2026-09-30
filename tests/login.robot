*** Settings ***
Library     Browser

Suite Setup       New Browser    ${BROWSER}    headless=False
Suite Teardown    Close Browser

*** Variables ***
${BROWSER}          chromium
${BASE_URL}         https://opensource-demo.orangehrmlive.com/web/index.php/auth/login
${VALID_USER}       Admin
${VALID_PASS}       admin123
${INVALID_USER}     wronguser
${INVALID_PASS}     wrongpass

*** Test Cases ***

TC01 - Valid Login Redirects To Dashboard
    [Documentation]    Verify that a user with valid credentials is redirected to the dashboard.
    [Tags]    login    smoke
    New Page    ${BASE_URL}
    Fill Text    input[name="username"]    ${VALID_USER}
    Fill Secret    input[name="password"]    $VALID_PASS
    Click    button.oxd-button.oxd-button--medium.oxd-button--main
    Wait For Elements State    h6    visible    timeout=10s
    Get Url    contains    /dashboard/index
    Close Page

TC02 - Invalid Credentials Show Error Message
    [Documentation]    Verify that invalid credentials display the "Invalid credentials" error alert.
    [Tags]    login    negative
    New Page    ${BASE_URL}
    Fill Text    input[name="username"]    ${INVALID_USER}
    Fill Secret    input[name="password"]    $INVALID_PASS
    Click    button.oxd-button.oxd-button--medium.oxd-button--main
    Wait For Elements State    p.oxd-text.oxd-text--p.oxd-alert-content-text    visible    timeout=10s
    Get Text    p.oxd-text.oxd-text--p.oxd-alert-content-text    ==    Invalid credentials
    Close Page

TC03 - Empty Username Shows Required Validation
    [Documentation]    Verify that submitting with an empty username shows a required field error.
    [Tags]    login    negative    validation
    New Page    ${BASE_URL}
    Fill Text    input[name="username"]    ${EMPTY}
    Fill Secret    input[name="password"]    $VALID_PASS
    Click    button.oxd-button.oxd-button--medium.oxd-button--main
    Wait For Elements State    span.oxd-input-field-error-message    visible    timeout=10s
    Close Page

TC04 - Empty Password Shows Required Validation
    [Documentation]    Verify that submitting with an empty password shows a required field error.
    [Tags]    login    negative    validation
    New Page    ${BASE_URL}
    Fill Text    input[name="username"]    ${VALID_USER}
    Fill Secret    input[name="password"]    $EMPTY
    Click    button.oxd-button.oxd-button--medium.oxd-button--main
    Wait For Elements State    span.oxd-input-field-error-message    visible    timeout=10s
    Close Page

TC05 - Login Page Title And Heading Are Correct
    [Documentation]    Verify that the login page has the correct browser title and "Login" heading.
    [Tags]    login    smoke
    New Page    ${BASE_URL}
    Get Title    ==    OrangeHRM
    Wait For Elements State    h5    visible    timeout=10s
    Close Page
