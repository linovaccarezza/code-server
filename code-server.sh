#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Author: Lino Vaccarezza
# License: MIT
# Source: https://coder.com/docs/code-server

APP="code-server"
var_tags="${var_tags:-development;ide}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_features="${var_features:-fuse=1,nesting=1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /usr/bin/code-server ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Updating Debian packages"
  $STD apt-get update
  $STD apt-get upgrade -y
  msg_ok "Updated Debian packages"

  msg_info "Updating code-server"
  $STD curl -fsSL https://code-server.dev/install.sh | sh
  $STD systemctl restart code-server@root
  msg_ok "Updated code-server"

  msg_info "Updating SSH FS extension"
  $STD code-server --install-extension Kelvin.vscode-sshfs --force
  msg_ok "Updated SSH FS extension"

  msg_ok "Updated successfully!"
  exit
}

start
build_container
pct set "${CTID}" --features "fuse=1,nesting=1,keyctl=1"
description

msg_info "Running code-server installation inside LXC ${CTID}"
lxc-attach -n "${CTID}" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/linovaccarezza/code-server/refs/heads/main/code-server-install.sh)"
INSTALL_EXIT=$?

if [[ $INSTALL_EXIT -eq 0 ]]; then
  msg_ok "Completed successfully!\n"
  echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
  echo -e "${INFO}${YW} Access it using the following URL:${CL}"
  echo -e "${TAB}${GATEWAY}${BGN}https://${IP}:8080${CL}"
  echo -e "${INFO}${YW} The password is shown above in the installation log.${CL}"
else
  msg_error "Installation failed! Check the log above for details."
fi
