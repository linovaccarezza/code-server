#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# code-server-install.sh
# Runs inside the LXC container
# Author: Lino Vaccarezza
# License: MIT
# ============================================================

echo "[INFO] Updating system packages..."
apt-get update -qq > /dev/null 2>&1
apt-get upgrade -y -qq > /dev/null 2>&1
echo "[OK] System updated"

echo "[INFO] Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh > /dev/null 2>&1
echo "[OK] code-server installed"

echo "[INFO] Enabling code-server service..."
systemctl enable --now code-server@root
echo "[OK] code-server service enabled"

echo "[INFO] Configuring code-server..."
mkdir -p /root/.config/code-server

# Generate a random password
PASSWORD=$(openssl rand -base64 12)

cat <<EOF > /root/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASSWORD}
cert: true
EOF

# Save password to file
echo "${PASSWORD}" > /root/.config/code-server/password.txt
chmod 600 /root/.config/code-server/password.txt

systemctl restart code-server@root
echo "[OK] code-server configured"

echo "[INFO] Installing SSH FS extension..."
code-server --install-extension Kelvin.vscode-sshfs > /dev/null 2>&1
echo "[OK] SSH FS extension installed"

echo ""
echo "============================================"
echo " code-server installation complete!"
echo " Password: ${PASSWORD}"
echo " Password also saved in:"
echo " /root/.config/code-server/password.txt"
echo "============================================"
