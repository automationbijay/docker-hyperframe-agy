FROM node:22-bookworm-slim

# Prevent interactive prompts during apt installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Chromium, FFmpeg, curl, and essential font/compositor libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    ffmpeg \
    curl \
    ca-certificates \
    git \
    procps \
    fonts-liberation \
    fonts-noto-core \
    fonts-noto-color-emoji \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 2. Install HyperFrames CLI globally
RUN npm install -g hyperframes

# 3. Install Antigravity CLI (agy) -> installs to /root/.local/bin/agy
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"

# 4. Pre-install the official HyperFrames skills for coding agents
RUN npx hyperframes skills update || true

# 5. Configure HyperFrames environment variables for Docker
ENV HYPERFRAMES_BROWSER_PATH=/usr/bin/chromium
ENV HYPERFRAMES_AGENT=1
ENV HYPERFRAMES_NO_TELEMETRY=1

WORKDIR /workspace

CMD ["sleep", "infinity"]
