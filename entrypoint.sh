#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Hermes Agent — Railway Entrypoint
# Ensures persistent directories exist on the Railway Volume before startup.
# =============================================================================

DATA_DIR="${HERMES_HOME:-/opt/data}"

echo "▶ Hermes Agent starting..."
echo "  Data directory : ${DATA_DIR}"
echo "  Timezone       : ${TZ:-UTC}"

# Ensure persistent subdirectories exist on first boot (volume may be empty)
for dir in profiles skills memory cron .local/bin; do
    mkdir -p "${DATA_DIR}/${dir}"
done

# If a seed config.yaml was provided in the image but the volume has none yet,
# copy it so the agent picks it up on first run.
SEED_CONFIG="/opt/hermes/seed-config.yaml"
LIVE_CONFIG="${DATA_DIR}/config.yaml"
if [ -f "${SEED_CONFIG}" ] && [ ! -f "${LIVE_CONFIG}" ]; then
    echo "  Seeding initial config.yaml → ${LIVE_CONFIG}"
    cp "${SEED_CONFIG}" "${LIVE_CONFIG}"
fi

echo "  Persistent dirs OK ✓"
echo ""

# Hand off to the Hermes gateway (runs agent + Telegram/Discord + dashboard)
exec hermes gateway run
