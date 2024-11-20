#!/usr/bin/env bash

# Copyright (c) 2021-2024 community-scripts ORG
# Author: fabianbar
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gpg
$STD apt-get install -y git
$STD apt-get install -y npm
$STD apt-get install -y graphicsmagick
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install --global yarn
msg_ok "Installed Node.js"

msg_info "Installing Optional Packages"
$STD apt-get update
$STD apt-get install -y ffmpeg
$STD apt-get install -y ghostscript
msg_ok "Installed Node.js"

msg_info "Installing Spacedeck"
$STD git clone https://github.com/spacedeck/spacedeck-open.git /opt/spacedeck
mkdir -p /opt/spacedeck/server-files
chown -R root:root /opt/spacedeck/server-files
chmod 755 /opt/spacedeck/server-files
cat <<EOF > /opt/spacedeck/.env
ACTUAL_UPLOAD_DIR=/opt/spacedeck/server-files
PORT=50421
EOF
cd /opt/spacedeck
$STD yarn install
msg_ok "Installed Spacedeck"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/spacedeck.service
[Unit]
Description=Spacedeck Service
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/spacedeck
EnvironmentFile=/opt/spacedeck/.env
ExecStart=/usr/bin/yarn start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now spacedeck.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
