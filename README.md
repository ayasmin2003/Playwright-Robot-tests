# OrangeHRM Robot Framework Test Suite

[![Robot Framework CI](https://github.com/ayasmin2003/Playwright-Robot-tests/actions/workflows/ci.yml/badge.svg)](https://github.com/ayasmin2003/Playwright-Robot-tests/actions/workflows/ci.yml)

End-to-end and API test suite for the [OrangeHRM Demo](https://opensource-demo.orangehrmlive.com) application, built with **Robot Framework** and the **Browser library** (Playwright-powered).

---

## Table of Contents

- [Purpose](#purpose)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [CI/CD](#cicd)
- [Contributing](#contributing)

---

## Purpose

This suite validates the OrangeHRM login feature across multiple dimensions:

| Dimension | What is tested |
|-----------|---------------|
| **Positive (UI)** | Valid login → dashboard redirect; page title; logout flow |
| **Negative (UI)** | Invalid credentials, wrong password, wrong username |
| **Validation (UI)** | Empty fields, whitespace-only input |
| **Security (UI)** | SQL injection, XSS payloads, oversized input |
| **Data-driven (UI)** | Multiple invalid-credential combinations |
| **API** | Auth endpoint reachability, valid/invalid credentials, missing fields, response time |

---

## Project Structure

```
Playwright-Robot-tests/
├── tests/
│   ├── login.robot              # UI login test suite (16 test cases)
│   └── api_login.robot          # API test suite (8 test cases)
│
├── resources/
│   ├── variables.resource       # Global variables (URL, browser, credentials)
│   ├── common.resource          # Suite/test lifecycle keywords + failure evidence capture
│   └── pages/
│       ├── login_page.resource  # Page Object: login page actions & assertions
│       └── dashboard_page.resource  # Page Object: dashboard assertions & logout
│
├── results/                     # Generated output (gitignored)
├── .github/
│   └── workflows/
│       └── ci.yml               # GitHub Actions CI pipeline
├── requirements.txt             # Python dependencies
├── run_parallel.py              # Run all browsers in parallel (local)
└── run_all_browsers.bat         # Run all browsers sequentially (Windows)
```

---

## Prerequisites

- **Python 3.9+**
- **pip**
- Internet access to reach `opensource-demo.orangehrmlive.com`

---

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/ayasmin2003/Playwright-Robot-tests.git
cd Playwright-Robot-tests

# 2. (Recommended) Create and activate a virtual environment
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate

# 3. Install Python dependencies
pip install -r requirements.txt

# 4. Download Playwright browsers (required once)
python -m rfbrowser init
```

---

## Running Tests

### Run the full UI suite (single browser)

```bash
# Chromium (default)
python -m robot --variable BROWSER:chromium --variable HEADLESS:False \
  --outputdir results/chrome tests/login.robot
# py -m robot --variable BROWSER:chromium --variable HEADLESS:False --outputdir results/chrome tests/login.robot

# Firefox
python -m robot --variable BROWSER:firefox --variable HEADLESS:False \
  --outputdir results/firefox tests/login.robot

# WebKit
python -m robot --variable BROWSER:webkit --variable HEADLESS:False \
  --outputdir results/webkit tests/login.robot
```

### Run the API suite

```bash
python -m robot --outputdir results/api tests/api_login.robot
```

### Run all browsers in parallel

```bash
python run_parallel.py
```

### Run all browsers sequentially (Windows)

```bat
run_all_browsers.bat
```

### Run by tag

```bash
# Smoke tests only
python -m robot --include smoke --outputdir results/smoke tests/

# Negative tests only
python -m robot --include negative --outputdir results/negative tests/

# Security tests only
python -m robot --include security --outputdir results/security tests/
```

### Headless mode (CI-friendly)

```bash
python -m robot --variable BROWSER:chromium --variable HEADLESS:True \
  --outputdir results/chrome tests/login.robot
```

---

## Test Coverage

### UI Tests — `tests/login.robot`

| ID    | Description                                      | Tags                          |
|-------|--------------------------------------------------|-------------------------------|
| TC01  | Valid login redirects to dashboard               | login, smoke, positive        |
| TC02  | Login page title and heading are correct         | login, smoke, positive, ui    |
| TC03  | Successful login then logout returns to login    | login, smoke, positive, e2e   |
| TC04  | Invalid credentials show error message           | login, negative               |
| TC05  | Correct username wrong password shows error      | login, negative               |
| TC06  | Wrong username correct password shows error      | login, negative               |
| TC07  | Empty username shows required validation         | login, negative, validation   |
| TC08  | Empty password shows required validation         | login, negative, validation   |
| TC09  | Both fields empty shows required validation      | login, negative, validation   |
| TC10  | Whitespace-only username shows validation error  | login, negative, validation, boundary |
| TC11  | SQL injection in username does not bypass login  | login, negative, security     |
| TC12  | XSS payload in username does not execute         | login, negative, security     |
| TC13  | Very long username does not crash the page       | login, negative, boundary     |
| TC14  | Data-driven: wrong username and password         | login, negative, data-driven  |
| TC15  | Data-driven: correct username wrong password     | login, negative, data-driven  |
| TC16  | Data-driven: wrong username correct password     | login, negative, data-driven  |

### API Tests — `tests/api_login.robot`

| ID        | Description                                      | Tags                     |
|-----------|--------------------------------------------------|--------------------------|
| API-TC01  | Valid credentials return success response        | api, smoke, positive     |
| API-TC02  | Auth endpoint is reachable                       | api, smoke, positive     |
| API-TC03  | Response Content-Type is HTML or JSON            | api, smoke, positive     |
| API-TC04  | Invalid credentials return non-2xx or error body | api, negative            |
| API-TC05  | Empty credentials return error                   | api, negative, validation|
| API-TC06  | SQL injection payload is rejected                | api, negative, security  |
| API-TC07  | Missing password field returns error             | api, negative, validation|
| API-TC08  | Login page responds within acceptable time       | api, performance         |

---

## CI/CD

Tests run automatically on every push and pull request via **GitHub Actions** (`.github/workflows/ci.yml`):

- **Matrix**: Chromium · Firefox · WebKit (all in parallel)
- **Headless**: always `True` in CI
- **Artefacts**: HTML reports and screenshots uploaded per browser (14-day retention)
- **Merged report**: combined `rebot` report uploaded after all browser jobs complete

To trigger a manual run: **Actions → Robot Framework CI → Run workflow**.

---

## Contributing

1. Branch from `main` using the convention `feature/<short-description>` or `fix/<short-description>`.
2. Add or update tests in `tests/` and keywords in `resources/pages/`.
3. Ensure all tests pass locally before opening a PR.
4. The CI pipeline must be green before merging.
