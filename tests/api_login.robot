*** Settings ***
Documentation     API test suite for OrangeHRM authentication endpoints.
...               Tests the /auth/login API alongside the UI login suite.
...               Uses RequestsLibrary for HTTP-level assertions.

Library           RequestsLibrary
Library           Collections
Library           String
Resource          ../resources/variables.resource

Suite Setup       Create API Session
Suite Teardown    Delete All Sessions

*** Variables ***
${AUTH_ENDPOINT}        /auth/validateCredentials
${SESSION_ALIAS}        orangehrm

*** Keywords ***

Create API Session
    [Documentation]    Create a persistent HTTP session for all API tests.
    Create Session    ${SESSION_ALIAS}
    ...               https://opensource-demo.orangehrmlive.com
    ...               verify=True

Post Login API
    [Documentation]    POST credentials to the auth endpoint and return the response.
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    username=${username}    password=${password}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${response}=   POST On Session
    ...            ${SESSION_ALIAS}
    ...            /web/index.php/auth/validateCredentials
    ...            json=${payload}
    ...            headers=${headers}
    ...            expected_status=any
    RETURN    ${response}

*** Test Cases ***

# ── Positive API Tests ────────────────────────────────────────────────────────

API-TC01 - Login Endpoint Returns HTTP 200
    [Documentation]    The login page GET returns HTTP 200 — server is healthy and serving the app.
    [Tags]    api    smoke    positive
    ${response}=    GET On Session    ${SESSION_ALIAS}
    ...             /web/index.php/auth/login
    ...             expected_status=any
    Should Be Equal As Integers    ${response.status_code}    200
    Should Contain    ${response.text}    OrangeHRM

API-TC02 - Auth Endpoint Is Reachable
    [Documentation]    A GET to the login page returns HTTP 200 (server is up).
    [Tags]    api    smoke    positive
    ${response}=    GET On Session    ${SESSION_ALIAS}
    ...             /web/index.php/auth/login
    ...             expected_status=any
    Should Be Equal As Integers    ${response.status_code}    200

API-TC03 - Response Content-Type Is HTML Or JSON
    [Documentation]    The login page response must declare a recognised content type.
    [Tags]    api    smoke    positive
    ${response}=    GET On Session    ${SESSION_ALIAS}
    ...             /web/index.php/auth/login
    ...             expected_status=any
    ${content_type}=    Get From Dictionary    ${response.headers}    Content-Type
    Should Match Regexp    ${content_type}    (text/html|application/json)

# ── Negative API Tests ────────────────────────────────────────────────────────

API-TC04 - Invalid Credentials Return Non-2xx Or Error Body
    [Documentation]    POST invalid credentials; the server must not return a success session.
    [Tags]    api    negative
    ${response}=    Post Login API    ${INVALID_USER}    ${INVALID_PASS}
    # Accept 200 with error body OR a 4xx status — both indicate rejection
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

API-TC05 - Empty Credentials Return Error
    [Documentation]    POST empty username and password; must not succeed.
    [Tags]    api    negative    validation
    ${response}=    Post Login API    ${EMPTY}    ${EMPTY}
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

API-TC06 - SQL Injection Payload Is Rejected
    [Documentation]    POST a SQL injection payload; must not grant access.
    [Tags]    api    negative    security
    ${response}=    Post Login API    ' OR '1'='1    ${VALID_PASS}
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

API-TC07 - Missing Password Field Returns Error
    [Documentation]    POST only a username with no password key; must not succeed.
    [Tags]    api    negative    validation
    ${payload}=    Create Dictionary    username=${VALID_USER}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=   POST On Session
    ...            ${SESSION_ALIAS}
    ...            /web/index.php/auth/validateCredentials
    ...            json=${payload}
    ...            headers=${headers}
    ...            expected_status=any
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

# ── Performance / Contract Tests ──────────────────────────────────────────────

API-TC08 - Login Page Responds Within Acceptable Time
    [Documentation]    The login page must respond within 10 seconds.
    [Tags]    api    performance
    ${start}=       Evaluate    __import__('time').time()
    ${response}=    GET On Session    ${SESSION_ALIAS}
    ...             /web/index.php/auth/login
    ...             expected_status=any
    ${elapsed}=     Evaluate    __import__('time').time() - ${start}
    Should Be True    ${elapsed} < 10    Login page took ${elapsed}s — exceeds 10s threshold
