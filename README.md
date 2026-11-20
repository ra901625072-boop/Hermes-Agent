# Hermes Agent — Railway Deployment

24/7 cloud AI development assistant controlled via Telegram.

## Architecture

- **Runtime:** [Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research
- **Platform:** Railway (Docker-based deploy + persistent Volume)
- **LLM:** Google Gemini
- **Interface:** Telegram bot (allowlisted to a single user ID)
- **Browser:** Playwright Chromium (for web verification tasks)
- **Storage:** Railway Volume mounted at `/opt/data`

## Quick Reference

| Item | Value |
|---|---|
| Docker base | `nousresearch/hermes-agent:latest` |
| Data mount | `/opt/data` (Railway Volume) |
| Dashboard port | `9119` |
| Startup command | `hermes gateway run` (via `entrypoint.sh`) |

## Environment Variables

See [`.env.example`](.env.example) for the full list. **Never commit real values.**
Set all secrets in Railway → Service → Variables.

## Files

```
.
├── Dockerfile            # Extends official image + Playwright Chromium
├── entrypoint.sh         # Ensures volume dirs exist, seeds config, starts gateway
├── seed-config.yaml      # Initial config.yaml (copied to volume on first boot)
├── .env.example          # Variable name reference (no secrets)
├── .gitignore            # Excludes secrets and local data
└── README.md             # This file
```

## Deployment

1. Push this repo to a **private** GitHub repository.
2. Create a Railway project → new service → connect the GitHub repo.
3. Add a Volume, mount at `/opt/data`.
4. Set all environment variables from `.env.example` in Railway's Variables panel.
5. Deploy. The service will build the Dockerfile and start the gateway.

## Runbook

See the Phase 9 runbook (created during hardening) for:
- Redeployment, rollback, and key rotation procedures
- Log access and error alerting
- Shutdown / billing stop instructions
