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
OnBootSec=1h
OnUnitInactiveSec=2d

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

podman run -d -p 5000:5000 --restart=always --name registry registry:latest
podman push localhost/atom-atic:latest localhost:5000/atom-atic:latest
rpm-ostree rebase ostree-unverified-registry:localhost:5000/atom-atic:latest
notify-send "atom-atic" "Rebase done, check 'rpm-ostree status'"
