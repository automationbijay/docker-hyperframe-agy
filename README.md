# docker-hyperframe-agy

Production-grade Docker container for rendering [HyperFrames](https://hyperframes.dev) videos with headless Chromium, FFmpeg, and Google Antigravity CLI (`agy`).

## Features

- **Node.js 22 (Bookworm)** runtime.
- **Headless Chromium & FFmpeg** with complete font suites (Liberation, Noto Core, Noto Color Emoji).
- **Antigravity CLI (`agy`)** pre-installed and authenticated headlessly via `GEMINI_API_KEY` or Google sign-in.
- **HyperFrames agent skills** pre-bundled for autonomous video creation and editing.
- **Optimized for Rendering**:
  - `shm_size: 2gb` to eliminate Chromium frame buffer crashes.
  - RAM-backed `tmpfs` `/tmp` buffer for fast frame stitching.
  - `seccomp:unconfined` for reliable Chromium sandbox execution on VPS / Coolify hosts.
  - Studio preview port `4567` exposed.

---

## Quick Start (Local)

1. **Clone and enter directory:**
   ```bash
   git clone https://github.com/<your-username>/docker-hyperframe-agy.git
   cd docker-hyperframe-agy
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Add your GEMINI_API_KEY if desired
   ```

3. **Start container:**
   ```bash
   docker compose up -d --build
   ```

4. **Verify installation:**
   ```bash
   docker exec -it docker-hyperframe-agy npx hyperframes doctor
   ```

5. **Launch Antigravity CLI (`agy`):**
   ```bash
   docker exec -it docker-hyperframe-agy agy
   ```

---

## Deploying to Coolify

1. Push this repository to GitHub or GitLab.
2. In Coolify, click **+ New Resource** ➔ **Public/Private Repository**.
3. Select this repository and set Build Pack to **Docker Compose**.
4. In the Coolify application settings:
   - (Optional) Set your Domain / FQDN and route port **4567**.
   - Add `GEMINI_API_KEY` under Environment Variables.
5. Click **Deploy**.

---

## Directory Structure

```
docker-hyperframe-agy/
├── Dockerfile              # Node 22, Chromium, FFmpeg, agy & hyperframes
├── docker-compose.yml      # Orchestration, volumes, memory limits
├── .env.example            # Environment variables template
├── .gitignore              # Ignores credentials, renders, and local caches
├── README.md               # Documentation
└── workspace/              # Persistent project workspace (mounted to /workspace)
    ├── .gemini/            # Isolated agy CLI credentials & skills
    └── .hyperframes/       # Isolated HyperFrames ONNX model cache
```

---

## SSH Access (n8n)

The container runs an OpenSSH server as its main process, so n8n's **SSH** node can run `agy` / `hyperframes` commands in it.

### Setup

1. In `.env`, set `ROOT_PASSWORD` (`openssl rand -base64 24`). On Coolify, add it under **Environment Variables** instead.
2. Set `N8N_NETWORK` to the Docker network n8n is on:
   ```bash
   docker inspect <n8n-container> --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'
   ```
   Under Coolify this is usually `coolify` (enable **Connect to Predefined Network** on both resources).
3. Rebuild: `docker compose up -d --build`

### n8n SSH credential

| Field | Value |
| :--- | :--- |
| Host | `hyperframes` |
| Port | `22` |
| Username | `root` |
| Password | `ROOT_PASSWORD` from `.env` |

`hyperframes` is a network alias on the n8n network, so the name stays the same across reboots, rebuilds and Coolify redeploys. Don't use the container name or IP.

Test from the host: `ssh -p 2222 root@127.0.0.1`

### Notes

- SSH host keys are stored in `./ssh-host-keys/` (gitignored), so they don't change on rebuild.
- `PATH`, `GEMINI_API_KEY`, `NODE_OPTIONS` and `HYPERFRAMES_*` are copied into SSH sessions, so `agy` and `npx hyperframes` work in n8n commands.
- SSH is not published to the LAN. Port `2222` binds to `BIND_IP` (`127.0.0.1` by default).
