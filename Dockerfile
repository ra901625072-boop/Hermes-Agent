# =============================================================================
# Hermes Agent — Railway Deployment Image
# Extends the official image with Chromium and GitHub CLI for automation tasks.
# =============================================================================
FROM nousresearch/hermes-agent:latest

# Install Chromium, fonts, and GitHub CLI (gh)
RUN apt-get update && apt-get install -y --no-install-recommends \
        chromium \
        chromium-sandbox \
        fonts-liberation \
        fonts-noto-color-emoji \
        ca-certificates \
        git \
        gh \
    && rm -rf /var/lib/apt/lists/*

# Tell Hermes / Chromium to run headless in container with no sandbox
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium
ENV AGENT_BROWSER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu"
ENV AGENT_BROWSER_CHROME_FLAGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu"
ENV CHROME_FLAGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu"
ENV PLAYWRIGHT_CHROMIUM_SANDBOX=0

# --- Timezone (for cron scheduling) ---
ENV TZ=Asia/Kolkata
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

# --- Seed config and starter skills ---
COPY seed-config.yaml /opt/hermes/seed-config.yaml
COPY skills/ /opt/hermes/starter-skills/

# --- Entrypoint ---
COPY entrypoint.sh /opt/hermes/entrypoint.sh
RUN chmod +x /opt/hermes/entrypoint.sh

# Railway injects PORT; Hermes dashboard listens on 9119 by default.
EXPOSE 9119

ENTRYPOINT ["/opt/hermes/entrypoint.sh"]
