#!/usr/bin/env bash

# Check if XDG environment variables are set, otherwise set to defaults
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

SERVICE="$XDG_CONFIG_HOME/systemd/user/atom-atic.service"
TIMER="$XDG_CONFIG_HOME/systemd/user/atom-atic.timer"
SCRIPT="$HOME/.local/bin/atom-atic.sh"

# systemD service
mkdir -p "$(dirname "$SERVICE")"

tee "$SERVICE" > /dev/null <<EOL
[Unit]
Description=Run atom-atic.sh script

[Service]
Type=simple
ExecStart=$SCRIPT
EOL

# Create the systemd timer file
tee "$TIMER" > /dev/null <<EOL
[Unit]
Description=Run atom-atic.sh script three times a day

[Timer]
OnCalendar=*-*-* 00,11,17:00:00
Persistent=true

[Install]
WantedBy=default.target
EOL

systemctl --user daemon-reload
systemctl --user enable --now atom-atic.timer

# enable rebasing to insecure localhost image
sudo tee "/etc/containers/registries.conf.d/local.conf" > /dev/null <<EOL
[[registry]]
location = "localhost:5000"
insecure = true
EOL

cp ./atom-atic.sh ~/.local/bin
