#!/bin/bash

curl -fsSL https://ollama.com/install.sh | sh
sleep 3
sudo /usr/bin/systemctl start ollama.service
sleep 3
echo "/bye" | /usr/local/bin/ollama run $1
curl -fsSL https://cdn.anythingllm.com/latest/installer.sh | sh

echo "@reboot root /usr/bin/systemctl start ollama.service && /usr/share/ollama run llama:3.2" | sudo tee -a /etc/crontab