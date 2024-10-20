#!/bin/bash

# Install certbot for Let's Encrypt
sudo apt-get update -y
sudo apt-get install -y python
sudo apt-get install -y certbot
sudo mv /tmp/certbot/* /usr/local/bin/
sudo chmod 755 /usr/local/bin/certbot_initial.sh
sudo chmod 755 /usr/local/bin/certbot_renewal.sh

# Certbot service
sudo sh -c "echo '[Unit]
Description=Run Certbot Initial Script at Boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/certbot_init.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target' >> /lib/systemd/system/certbot.service"
sudo systemctl daemon-reload
sudo systemctl enable certbot

# Schedule Certbot renewal
sudo crontab -l > /tmp/cron
echo '0 3 * * * /usr/local/bin/certbot_renewal.sh' >> /tmp/cron
sudo crontab /tmp/cron

# Install Vault
sudo apt update && sudo apt install gpg wget -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault -y

# Write custom vault config
cat <<EOF > $CONFIG_FILE
storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/etc/ssl/certs/vault.crt"
  tls_key_file  = "/etc/ssl/private/vault.key"
}

api_addr = "https://vault.lokesh.cloud:8200"
cluster_addr = "https://vault.lokesh.cloud:8201"

ui = true
EOF

# Enable Vault
sudo systemctl enable vault
echo "All done"