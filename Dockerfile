# =============================================================================
# Hermes Agent — Railway Deployment Image
# Extends the official image with Playwright (Chromium only) for browser tasks.
# =============================================================================
# Pin to a specific digest when moving to production. For now, track latest.
FROM nousresearch/hermes-agent:latest

# --- Playwright browser dependencies (Chromium only, keeps image ~400 MB smaller than all browsers) ---
# Install system-level libs required by Chromium, then Playwright itself.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libnss3 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libpango-1.0-0 \
        libcairo2 \
        libasound2 \
        libxshmfence1 \
        fonts-liberation \
        fonts-noto-color-emoji \
        xdg-utils \
        wget \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Ensure Hermes venv and local bin are in PATH ---
ENV PATH="/usr/local/bin:/opt/hermes/.venv/bin:/opt/hermes/bin:${PATH}"

# Install uv, then install Playwright Python package + Chromium into Hermes venv
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh \
    && uv pip install --python /opt/hermes/.venv/bin/python playwright==1.49.1 \
    && /opt/hermes/.venv/bin/playwright install chromium \
    && /opt/hermes/.venv/bin/playwright install-deps chromium

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
