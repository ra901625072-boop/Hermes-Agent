---
name: test-runner
description: Runs test suites, linters, or syntax checks on a project repository branch and summarizes results.
version: 1.0.0
---

# Test Runner and CI Report

Executes automated tests in an isolated workspace and produces a clear PASS/FAIL test summary.

## Execution Steps:
1. Clone or checkout the target repository branch using `git clone` or `git checkout`.
2. Inspect `package.json`, `pyproject.toml`, or `Makefile` to detect the appropriate runner (`npm test`, `pytest`, `cargo test`, etc.).
3. Execute the tests in a non-interactive shell.
4. Parse test results: total tests run, passed, failed, and skipped.
5. Report status: [PASS/FAIL], highlighting any failure stack traces.
