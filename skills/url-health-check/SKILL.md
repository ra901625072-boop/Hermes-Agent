---
name: url-health-check
description: Verifies that a deployed web URL or API endpoint is healthy, returns HTTP 200, and measures response latency.
version: 1.0.0
---

# URL Health Check

Performs an automated uptime and latency check on a deployed web service or API endpoint.

## Execution Steps:
1. Run curl probe: `curl -s -o /dev/null -w "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}s\n" <URL>`.
2. Check if HTTP status is between 200 and 399 (healthy) or 4xx/5xx (unhealthy).
3. Optionally invoke `browser_exec` to load the URL in headless Chromium and capture a screenshot.
4. Report status: [UP/DOWN], latency in milliseconds, and any error details.
