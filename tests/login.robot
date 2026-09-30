*** Settings ***
Library     Browser
Resource    ../resources/keywords.resource
Resource    ../resources/variables.resource

Suite Setup       New Browser    ${BROWSER}    headless=False
Suite Teardown    Close Browser

*** Test Cases ***

TC01 - Valid Login Redirects To Dashboard
    [Documentation]    Verify that a user with valid credentials is redirected to the dashboard.
    [Tags]    login    smoke
    Open Login Page
    Fill Login Form    ${VALID_USER}    ${VALID_PASS}
    Submit Login Form
    Verify Dashboard Is Displayed
    Close Login Page

TC02 - Invalid Credentials Show Error Message
    [Documentation]    Verify that invalid credentials display the "Invalid credentials" error alert.
    [Tags]    login    negative
    Open Login Page
    Fill Login Form    ${INVALID_USER}    ${INVALID_PASS}
    Submit Login Form
    Verify Error Message Is Displayed
    Close Login Page

TC03 - Empty Username Shows Required Validation
    [Documentation]    Verify that submitting with an empty username shows a required field error.
    [Tags]    login    negative    validation
    Open Login Page
    Fill Login Form    ${EMPTY}    ${VALID_PASS}
    Submit Login Form
    Verify Required Field Error Is Displayed
    Close Login Page

TC04 - Empty Password Shows Required Validation
    [Documentation]    Verify that submitting with an empty password shows a required field error.
    [Tags]    login    negative    validation
    Open Login Page
    Fill Login Form    ${VALID_USER}    ${EMPTY}
    Submit Login Form
    Verify Required Field Error Is Displayed
    Close Login Page

TC05 - Login Page Title And Heading Are Correct
    [Documentation]    Verify that the login page has the correct browser title and "Login" heading.
    [Tags]    login    smoke
    Open Login Page
    Get Title    ==    OrangeHRM
    Wait For Elements State    h5    visible    timeout=10s
    Close Login Page
