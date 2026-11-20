#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Hermes Agent — Railway Entrypoint
# Ensures persistent directories exist and are writable on Railway Volume.
# =============================================================================

DATA_DIR="${HERMES_HOME:-/opt/data}"

echo "▶ Hermes Agent starting..."
echo "  Data directory : ${DATA_DIR}"
echo "  Timezone       : ${TZ:-UTC}"

# Ensure persistent subdirectories exist on first boot
for dir in sessions profiles skills memory cron .local/bin; do
    mkdir -p "${DATA_DIR}/${dir}"
done

# Ensure the entire mounted volume is world-writable regardless of container UID
chmod -R 777 "${DATA_DIR}" 2>/dev/null || true

# If a seed config.yaml was provided in the image but the volume has none yet,
# copy it so the agent picks it up on first run.
SEED_CONFIG="/opt/hermes/seed-config.yaml"
LIVE_CONFIG="${DATA_DIR}/config.yaml"
if [ -f "${SEED_CONFIG}" ] && [ ! -f "${LIVE_CONFIG}" ]; then
    echo "  Seeding initial config.yaml → ${LIVE_CONFIG}"
    cp "${SEED_CONFIG}" "${LIVE_CONFIG}"
    chmod 666 "${LIVE_CONFIG}" 2>/dev/null || true
fi

echo "  Persistent dirs OK ✓"
echo ""

# Hand off to the Hermes gateway (runs agent + Telegram/Discord + dashboard)
if [ -x "/opt/hermes/docker/entrypoint-dispatch.sh" ]; then
    exec /opt/hermes/docker/entrypoint-dispatch.sh gateway run
else
    exec hermes gateway run
fi
