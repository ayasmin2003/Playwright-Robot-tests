*** Settings ***
Library     Browser
Library     OperatingSystem
Library     Collections

*** Keywords ***

# ── Suite / Test lifecycle ────────────────────────────────────────────────────

Suite Setup With Browser
    [Documentation]    Open a new browser instance for the suite.
    [Arguments]    ${browser}=${BROWSER}    ${headless}=${HEADLESS}
    New Browser    ${browser}    headless=${headless}

Suite Teardown With Browser
    [Documentation]    Close all browser instances after the suite.
    Close Browser

Test Setup Default
    [Documentation]    Create a fresh browser context and page before each test.
    New Context    viewport={'width': 1280, 'height': 800}

Test Teardown With Screenshot
    [Documentation]    On failure capture a screenshot and trace; always close the context.
    Run Keyword If Test Failed    Capture Failure Evidence
    Close Context

Capture Failure Evidence
    [Documentation]    Save a screenshot and (if tracing) stop the trace on test failure.
    ${test_safe}=    Evaluate    "${TEST NAME}".replace(" ", "_").replace("/", "-")
    ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y%m%d_%H%M%S')
    ${filename}=     Set Variable    ${OUTPUTDIR}/screenshots/${test_safe}_${timestamp}.png
    Take Screenshot    filename=${filename}    fullPage=True
    Log    Screenshot saved: ${filename}    level=WARN
