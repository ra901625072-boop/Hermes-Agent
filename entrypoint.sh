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

# Seed or update config.yaml with Groq primary and Gemini fallback
SEED_CONFIG="/opt/hermes/seed-config.yaml"
LIVE_CONFIG="${DATA_DIR}/config.yaml"
if [ -f "${SEED_CONFIG}" ]; then
    echo "  Applying Groq (primary) and Gemini (fallback) configuration to ${LIVE_CONFIG}"
    cp "${SEED_CONFIG}" "${LIVE_CONFIG}"
    chmod 666 "${LIVE_CONFIG}" 2>/dev/null || true
fi

# Configure Groq authentication for Hermes
if [ -n "${GROQ_API_KEY:-}" ]; then
    echo "  Configuring Groq API key in ${DATA_DIR}/.env"
    touch "${DATA_DIR}/.env"
    grep -v "^GROQ_API_KEY=" "${DATA_DIR}/.env" > "${DATA_DIR}/.env.tmp" 2>/dev/null || true
    echo "GROQ_API_KEY=${GROQ_API_KEY}" >> "${DATA_DIR}/.env.tmp"
    mv "${DATA_DIR}/.env.tmp" "${DATA_DIR}/.env"
    chmod 666 "${DATA_DIR}/.env" 2>/dev/null || true
    export GROQ_API_KEY="${GROQ_API_KEY}"
    mkdir -p /etc/profile.d
    echo "export GROQ_API_KEY=\"${GROQ_API_KEY}\"" > /etc/profile.d/groq.sh
    chmod 644 /etc/profile.d/groq.sh 2>/dev/null || true
fi

# Configure Google Gemini authentication in ${DATA_DIR}/.env
if [ -n "${GOOGLE_API_KEY:-}" ]; then
    echo "  Configuring Google API key in ${DATA_DIR}/.env"
    touch "${DATA_DIR}/.env"
    grep -v "^GOOGLE_API_KEY=" "${DATA_DIR}/.env" | grep -v "^GEMINI_API_KEY=" > "${DATA_DIR}/.env.tmp" 2>/dev/null || true
    echo "GOOGLE_API_KEY=${GOOGLE_API_KEY}" >> "${DATA_DIR}/.env.tmp"
    echo "GEMINI_API_KEY=${GOOGLE_API_KEY}" >> "${DATA_DIR}/.env.tmp"
    mv "${DATA_DIR}/.env.tmp" "${DATA_DIR}/.env"
    chmod 666 "${DATA_DIR}/.env" 2>/dev/null || true
    export GOOGLE_API_KEY="${GOOGLE_API_KEY}"
    export GEMINI_API_KEY="${GOOGLE_API_KEY}"
fi

# Configure GitHub authentication for Hermes tools and gh CLI
if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "  Configuring GitHub token in ${DATA_DIR}/.env and gh CLI"
    touch "${DATA_DIR}/.env"
    grep -v "^GITHUB_TOKEN=" "${DATA_DIR}/.env" | grep -v "^GH_TOKEN=" > "${DATA_DIR}/.env.tmp" 2>/dev/null || true
    echo "GITHUB_TOKEN=${GITHUB_TOKEN}" >> "${DATA_DIR}/.env.tmp"
    echo "GH_TOKEN=${GITHUB_TOKEN}" >> "${DATA_DIR}/.env.tmp"
    mv "${DATA_DIR}/.env.tmp" "${DATA_DIR}/.env"
    chmod 666 "${DATA_DIR}/.env" 2>/dev/null || true

    # Export for current shell and system profile
    export GITHUB_TOKEN="${GITHUB_TOKEN}"
    export GH_TOKEN="${GITHUB_TOKEN}"
    mkdir -p /etc/profile.d
    echo "export GITHUB_TOKEN=\"${GITHUB_TOKEN}\"" > /etc/profile.d/github.sh
    echo "export GH_TOKEN=\"${GITHUB_TOKEN}\"" >> /etc/profile.d/github.sh
    chmod 644 /etc/profile.d/github.sh 2>/dev/null || true

    # Configure gh CLI config for root, hermes user, and volume
    mkdir -p /root/.config/gh "${DATA_DIR}/.config/gh" /home/hermes/.config/gh
    cat <<EOF > /root/.config/gh/hosts.yml
github.com:
    oauth_token: ${GITHUB_TOKEN}
    user: ra901625072-boop
    git_protocol: https
EOF
    cp /root/.config/gh/hosts.yml "${DATA_DIR}/.config/gh/hosts.yml" 2>/dev/null || true
    cp /root/.config/gh/hosts.yml /home/hermes/.config/gh/hosts.yml 2>/dev/null || true
    chmod -R 777 "${DATA_DIR}/.config" /home/hermes/.config 2>/dev/null || true
fi

echo "  Persistent dirs OK ✓"
echo ""

# Hand off to the Hermes gateway (runs agent + Telegram/Discord + dashboard)
if [ -x "/opt/hermes/docker/entrypoint-dispatch.sh" ]; then
    exec /opt/hermes/docker/entrypoint-dispatch.sh gateway run
else
    exec hermes gateway run
fi
