*** Settings ***
Documentation     API test suite for OrangeHRM authentication endpoints.
...               Tests the /auth/login API alongside the UI login suite.
...               Uses RequestsLibrary for HTTP-level assertions.
...               Retries up to 3 times on connection errors; captures
...               error logs and response details on failure.

Library           RequestsLibrary
Library           Collections
Library           String
Library           OperatingSystem
Resource          ../resources/variables.resource

Suite Setup       Create API Session
Suite Teardown    Delete All Sessions

*** Variables ***
${AUTH_ENDPOINT}        /auth/validateCredentials
${SESSION_ALIAS}        orangehrm
${MAX_RETRIES}          3
${RETRY_DELAY}          5s

*** Keywords ***

Create API Session
    [Documentation]    Create a persistent HTTP session with a 30-second timeout.
    Create Session    ${SESSION_ALIAS}
    ...               https://opensource-demo.orangehrmlive.com
    ...               verify=True
    ...               timeout=30

GET With Retry
    [Documentation]    GET the given path, retrying up to ${MAX_RETRIES} times on
    ...                connection errors. Logs full error details on each failure and
    ...                fails the test with a diagnostic message after all retries.
    [Arguments]    ${path}
    FOR    ${attempt}    IN RANGE    1    ${MAX_RETRIES} + 1
        ${status}    ${response}=    Run Keyword And Ignore Error
        ...    GET On Session    ${SESSION_ALIAS}    ${path}    expected_status=any
        IF    '${status}' == 'PASS'
            RETURN    ${response}
        END
        Log    [Attempt ${attempt}/${MAX_RETRIES}] GET ${path} failed: ${response}    level=WARN
        Log    Error detail: ${response}    level=ERROR
        IF    ${attempt} < ${MAX_RETRIES}
            Sleep    ${RETRY_DELAY}    reason=Waiting before retry ${attempt + 1}
        END
    END
    Fail    GET ${path} failed after ${MAX_RETRIES} attempts. Last error: ${response}

POST With Retry
    [Documentation]    POST to the given path, retrying up to ${MAX_RETRIES} times on
    ...                connection errors. Logs full error details on each failure and
    ...                fails the test with a diagnostic message after all retries.
    [Arguments]    ${path}    ${payload}    ${headers}
    FOR    ${attempt}    IN RANGE    1    ${MAX_RETRIES} + 1
        ${status}    ${response}=    Run Keyword And Ignore Error
        ...    POST On Session    ${SESSION_ALIAS}    ${path}
        ...    json=${payload}    headers=${headers}    expected_status=any
        IF    '${status}' == 'PASS'
            RETURN    ${response}
        END
        Log    [Attempt ${attempt}/${MAX_RETRIES}] POST ${path} failed: ${response}    level=WARN
        Log    Error detail: ${response}    level=ERROR
        IF    ${attempt} < ${MAX_RETRIES}
            Sleep    ${RETRY_DELAY}    reason=Waiting before retry ${attempt + 1}
        END
    END
    Fail    POST ${path} failed after ${MAX_RETRIES} attempts. Last error: ${response}

Post Login API
    [Documentation]    POST credentials to the auth endpoint and return the response.
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    username=${username}    password=${password}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${response}=   POST With Retry
    ...            /web/index.php/auth/validateCredentials
    ...            ${payload}
    ...            ${headers}
    RETURN    ${response}

Log Response Details
    [Documentation]    Log full response details for debugging on failure.
    [Arguments]    ${response}
    Log    Status Code: ${response.status_code}    INFO
    Log    Response URL: ${response.url}    INFO
    Log    Headers: ${response.headers}    INFO
    Log    Body: ${response.text[:2000]}    INFO

*** Test Cases ***

# ── Positive API Tests ────────────────────────────────────────────────────────

API-TC01 - Login Endpoint Returns HTTP 200
    [Documentation]    The login page GET returns HTTP 200 — server is healthy and serving the app.
    [Tags]    api    smoke    positive
    ${response}=    GET With Retry    /web/index.php/auth/login
    Run Keyword If    '${response.status_code}' != '200'    Log Response Details    ${response}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Contain    ${response.text}    OrangeHRM

API-TC02 - Auth Endpoint Is Reachable
    [Documentation]    A GET to the login page returns HTTP 200 (server is up).
    [Tags]    api    smoke    positive
    ${response}=    GET With Retry    /web/index.php/auth/login
    Run Keyword If    '${response.status_code}' != '200'    Log Response Details    ${response}
    Should Be Equal As Integers    ${response.status_code}    200

API-TC03 - Response Content-Type Is HTML Or JSON
    [Documentation]    The login page response must declare a recognised content type.
    [Tags]    api    smoke    positive
    ${response}=    GET With Retry    /web/index.php/auth/login
    Run Keyword If    '${response.status_code}' != '200'    Log Response Details    ${response}
    ${content_type}=    Get From Dictionary    ${response.headers}    Content-Type
    Should Match Regexp    ${content_type}    (text/html|application/json)

# ── Negative API Tests ────────────────────────────────────────────────────────

API-TC04 - Invalid Credentials Return Non-2xx Or Error Body
    [Documentation]    POST invalid credentials; the server must not return a success session.
    [Tags]    api    negative
    ${response}=    Post Login API    ${INVALID_USER}    ${INVALID_PASS}
    Log Response Details    ${response}
    # Accept 200 with error body OR a 4xx status — both indicate rejection
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

API-TC05 - Empty Credentials Return Error
    [Documentation]    POST empty username and password; must not succeed.
    [Tags]    api    negative    validation
    ${response}=    Post Login API    ${EMPTY}    ${EMPTY}
    Log Response Details    ${response}
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

API-TC06 - SQL Injection Payload Is Rejected
    [Documentation]    POST a SQL injection payload; must not grant access.
    [Tags]    api    negative    security
    ${response}=    Post Login API    ' OR '1'='1    ${VALID_PASS}
    Log Response Details    ${response}
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

API-TC07 - Missing Password Field Returns Error
    [Documentation]    POST only a username with no password key; must not succeed.
    [Tags]    api    negative    validation
    ${payload}=    Create Dictionary    username=${VALID_USER}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=   POST With Retry
    ...            /web/index.php/auth/validateCredentials
    ...            ${payload}
    ...            ${headers}
    Log Response Details    ${response}
    Run Keyword If    ${response.status_code} == 200
    ...    Should Contain    ${response.text}    Invalid
    ...    ELSE
    ...    Should Be True    ${response.status_code} >= 400

# ── Performance / Contract Tests ──────────────────────────────────────────────

API-TC08 - Login Page Responds Within Acceptable Time
    [Documentation]    The login page must respond within 10 seconds.
    [Tags]    api    performance
    ${start}=       Evaluate    __import__('time').time()
    ${response}=    GET With Retry    /web/index.php/auth/login
    ${elapsed}=     Evaluate    __import__('time').time() - ${start}
    Run Keyword If    '${response.status_code}' != '200'    Log Response Details    ${response}
    Should Be True    ${elapsed} < 10    Login page took ${elapsed}s — exceeds 10s threshold
