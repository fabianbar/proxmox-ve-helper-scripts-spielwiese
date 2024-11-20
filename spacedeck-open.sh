#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/fabianbar/proxmox-ve-helper-scripts-spielwiese/refs/heads/main/build.func)
# Copyright (c) 2021-2024 tteck
# Author: faba
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
Spacedeck-open
EOF
}
header_info
echo -e "Loading..."
APP="Spacedeck-open"
var_disk="4"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
check_container_storage
check_container_resources
if [[ ! -d /opt/spacedeck-open ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP}"
systemctl stop spacedeck-open.service
cd /opt/spacedeck-open
git pull &>/dev/null
yarn install &>/dev/null
systemctl start spacedeck-open.service
msg_ok "Successfully Updated ${APP}"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:54321${CL} \n"
