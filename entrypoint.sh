#!/bin/sh
# Starts OpenSSH as the container's main process with:
#   - root password taken from $ROOT_PASSWORD (set in .env)
#   - host keys persisted in /etc/ssh/host-keys so they survive rebuilds/reboots
#   - the container's env vars exported to SSH sessions (PATH, HYPERFRAMES_*, ...)
set -eu

if [ -z "${ROOT_PASSWORD:-}" ]; then
  echo "ERROR: ROOT_PASSWORD is not set. Add it to .env (or Coolify env vars)." >&2
  exit 1
fi
echo "root:${ROOT_PASSWORD}" | chpasswd

# Persistent host keys: n8n won't see "host key changed" after a rebuild
KEYDIR=/etc/ssh/host-keys
mkdir -p "$KEYDIR" /run/sshd
[ -f "$KEYDIR/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -N '' -f "$KEYDIR/ssh_host_ed25519_key"
[ -f "$KEYDIR/ssh_host_rsa_key" ]     || ssh-keygen -q -t rsa -b 4096 -N '' -f "$KEYDIR/ssh_host_rsa_key"
chmod 600 "$KEYDIR"/*_key

# SSH sessions start with a clean environment. Copy the container env into
# /etc/environment (read by PAM) so agy, hyperframes and API keys work over SSH.
env | grep -E '^(PATH|TZ|NODE_OPTIONS|GEMINI_API_KEY|HYPERFRAMES_[A-Z_]*)=' > /etc/environment || true

exec /usr/sbin/sshd -D -e
