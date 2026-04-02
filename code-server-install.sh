#!/usr/bin/env bash

# Copyright (c) 2021-2026 tteck
# Author: Lino (your-github-username)
# License: MIT
# Source: https://coder.com/docs/code-server

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing code-server"
$STD curl -fsSL https://code-server.dev/install.sh | sh
msg_ok "Installed code-server"

msg_info "Configuring code-server"

# Generate a random password
PASSWORD=$(openssl rand -base64 12)

# Create config directory
mkdir -p /root/.config/code-server

# Write config file
cat <<EOF > /root/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASSWORD}
cert: true
EOF

# Enable and start the service
$STD systemctl enable --now code-server@root
msg_ok "Configured code-server"

msg_info "Installing SSH FS extension"
$STD code-server --install-extension Kelvin.vscode-sshfs
msg_ok "Installed SSH FS extension"

# Save password to a readable file for the user
echo "${PASSWORD}" > /root/.config/code-server/password.txt
chmod 600 /root/.config/code-server/password.txt

msg_ok "Completed Successfully!\n"
echo -e "${INFO}${YW} code-server password: ${BGN}${PASSWORD}${CL}"
echo -e "${INFO}${YW} Password also saved in: ${BGN}/root/.config/code-server/password.txt${CL}"
