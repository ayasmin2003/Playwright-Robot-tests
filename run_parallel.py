"""
Run login.robot tests in parallel across Chrome, Firefox, and Edge (webkit).
Usage: py run_parallel.py
"""
import subprocess
import sys
import os
from concurrent.futures import ThreadPoolExecutor, as_completed

BROWSERS = [
    {"browser": "chromium", "name": "Login-Chrome",  "outputdir": "results/chrome"},
    {"browser": "firefox",  "name": "Login-Firefox", "outputdir": "results/firefox"},
    {"browser": "webkit",   "name": "Login-Edge",    "outputdir": "results/edge"},
]

def run_browser(config):
    os.makedirs(config["outputdir"], exist_ok=True)
    cmd = [
        sys.executable, "-m", "robot",
        "--variable", f"BROWSER:{config['browser']}",
        "--outputdir", config["outputdir"],
        "--name", config["name"],
        "tests/login.robot",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return config["name"], result.returncode, result.stdout, result.stderr

if __name__ == "__main__":
    print("=" * 60)
    print("Running login tests in PARALLEL across Chrome, Firefox, Edge")
    print("=" * 60)

    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {executor.submit(run_browser, b): b for b in BROWSERS}
        results = {}
        for future in as_completed(futures):
            name, rc, stdout, stderr = future.result()
            results[name] = rc
            print(f"\n{'=' * 60}")
            print(f"Results for: {name}")
            print("=" * 60)
            print(stdout)
            if stderr:
                print(stderr)

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    all_passed = True
    for name, rc in results.items():
        status = "PASS" if rc == 0 else "FAIL"
        print(f"  {name}: {status}")
        if rc != 0:
            all_passed = False

    print("\nReports:")
    for b in BROWSERS:
        print(f"  {b['name']}: {b['outputdir']}/report.html")

    sys.exit(0 if all_passed else 1)
