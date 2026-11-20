# =============================================================================
# Hermes Agent — Railway Deployment Image
# Extends the official image with Chromium for browser automation tasks.
# =============================================================================
FROM nousresearch/hermes-agent:latest

# Install Chromium and fonts for browser automation & visual verification
RUN apt-get update && apt-get install -y --no-install-recommends \
        chromium \
        chromium-sandbox \
        fonts-liberation \
        fonts-noto-color-emoji \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Tell Hermes / Chromium to run headless in container
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# --- Timezone (for cron scheduling) ---
ENV TZ=Asia/Kolkata
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

# --- Seed config (copied to volume on first boot by entrypoint.sh) ---
COPY seed-config.yaml /opt/hermes/seed-config.yaml

# --- Entrypoint ---
COPY entrypoint.sh /opt/hermes/entrypoint.sh
RUN chmod +x /opt/hermes/entrypoint.sh

# Railway injects PORT; Hermes dashboard listens on 9119 by default.
EXPOSE 9119

ENTRYPOINT ["/opt/hermes/entrypoint.sh"]
