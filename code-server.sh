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
  msg_info "Updating ${APP}"
  $STD bash /usr/bin/update
  msg_ok "Updated ${APP}"
  exit
}

start
build_container
pct set "${CTID}" --features "fuse=1,nesting=1,keyctl=1"

# Override description with our own branding
pct set "${CTID}" --description "<div align='center'>%0A  <a href='https%3A//github.com/linovaccarezza/code-server' target='_blank' rel='noopener noreferrer'>%0A    <img src='https%3A//raw.githubusercontent.com/linovaccarezza/code-server/main/docs/assets/logo.png' alt='Logo' style='width%3A112px;height%3A112px;'/>%0A  </a>%0A%0A  <h2 style='font-size%3A 24px; margin%3A 20px 0;'>code-server LXC</h2>%0A  <p style='margin%3A 8px 0;'>VS Code in the browser — with SSH remote editing</p>%0A%0A  <p style='margin%3A 16px 0;'>%0A    <a href='https%3A//ko-fi.com/linovaccarezza' target='_blank' rel='noopener noreferrer'>%0A      <img src='https%3A//img.shields.io/badge/&#x2615;-Buy me a coffee-blue' alt='Ko-fi' />%0A    </a>%0A  </p>%0A%0A  <span style='margin%3A 0 10px;'>%0A    <a href='https%3A//github.com/linovaccarezza/code-server' target='_blank' rel='noopener noreferrer' style='text-decoration%3A none; color%3A #00617f;'>GitHub</a>%0A  </span>%0A</div>"

description

msg_info "Running code-server installation inside LXC ${CTID}"
lxc-attach -n "${CTID}" -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/linovaccarezza/code-server/main/code-server-install.sh)"
INSTALL_EXIT=$?

if [[ $INSTALL_EXIT -eq 0 ]]; then
  msg_ok "Completed successfully!\n"
  echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
  echo -e "${INFO}${YW} Access it using the following URL:${CL}"
  echo -e "${TAB}${GATEWAY}${BGN}https://${IP}:8080${CL}"
  echo -e "${INFO}${YW} The password is shown above in the installation log.${CL}"
  echo -e "${INFO}${YW} To update, run ${BGN}update${YW} from inside the container shell.${CL}"
else
  msg_error "Installation failed! Check the log above for details."
fi
