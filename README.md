# Playwright Robot Tests — OrangeHRM Login Suite

Robot Framework + Browser library (Playwright-powered) test suite for [OrangeHRM Demo](https://opensource-demo.orangehrmlive.com).

## Project Structure

```
Playwright-Robot-tests/
├── tests/                    # Test suites (.robot files)
│   └── login.robot           # 5 login test cases
├── resources/                # Reusable keywords and variables
│   ├── keywords.resource     # Page-level keywords (Open Login Page, Fill Login Form, etc.)
│   └── variables.resource    # Shared variables (URLs, credentials, browser)
├── results/                  # Test output (gitignored)
├── run_parallel.py           # Run all browsers in parallel
├── run_all_browsers.bat      # Run all browsers sequentially
└── pabot_suite_config.yaml   # pabot parallel config
```

## Prerequisites

- Python 3.x
- Install dependencies:
  ```
  py -m pip install robotframework robotframework-browser robotframework-pabot
  py -m rfbrowser init
  ```

## Running Tests

### Single browser
```
py -m robot --variable BROWSER:chromium --outputdir results/chrome tests/login.robot
py -m robot --variable BROWSER:firefox  --outputdir results/firefox tests/login.robot
py -m robot --variable BROWSER:webkit   --outputdir results/edge tests/login.robot
```

### All browsers in parallel
```
py run_parallel.py
```

### All browsers sequentially
```
run_all_browsers.bat
```

## Test Cases

| ID   | Description                              | Tags                    |
|------|------------------------------------------|-------------------------|
| TC01 | Valid login redirects to dashboard       | login, smoke            |
| TC02 | Invalid credentials show error message   | login, negative         |
| TC03 | Empty username shows required validation | login, negative, validation |
| TC04 | Empty password shows required validation | login, negative, validation |
| TC05 | Login page title and heading are correct | login, smoke            |

## Browsers Supported
- Chrome (`chromium`)
- Firefox (`firefox`)
- Edge/WebKit (`webkit`)
