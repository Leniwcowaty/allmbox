#!/bin/bash

image="ubuntu:noble"

# For future use
models=("deepseek-r1" "deepseek-r1:671b" "llama3.3" "llama3.2:1b" "llama3.2-vision" "llama3.2-vision:90b"
        "llama3.1" "llama3.1:405b" "phi4" "phi3" "gemma2" "gemma2:2b" "gemma2:27b" "mistral" "moodream"
        "neural-chat" "starling-lm" "codellama" "llama2-uncensored" "llava" "solar")


if [ "$1" = "remove" ]; then
    distrobox ls | grep allmbox

    echo "Which container you want to remove?"
    while [ -z "$container_name" ]; do
        read container_name
        if [ -z "$container_name" ]; then
            echo "Please provide container name"
        fi
    done

    distrobox rm $container_name -f

    rm -rf $HOME/.allmbox/$container_name
    echo "Application config removed"
    if [ -z "$(distrobox ls | grep allmbox)" ]; then
        rm -rf $HOME/.allmbox
    fi

    rm -rf $HOME/.local/share/applications/AnythingLLM-$container_name.desktop

else
    echo "What model do you want to run? [llama3.2]"
    echo "List of models available on Ollama Github page: https://github.com/ollama/ollama"
    read model

    if [ -z "$model" ]; then
        model="llama3.2"
    fi

    echo "Selected model: $model"

    container_name="allmbox-${model//:/_}"

    mkdir -p $HOME/.allmbox
    mkdir -p $HOME/.allmbox/$container_name

    distrobox create --image $image --name $container_name --home $HOME/.allmbox/$container_name -ap "lshw libnss3 alsa cron curl" -a "--env SHELL=/bin/bash" --init --yes --no-entry
    
    distrobox enter $container_name -- << EOF
curl -fsSL https://ollama.com/install.sh | sh
sleep 3
sudo /usr/bin/systemctl start ollama.service
sleep 3
echo "/bye" | /usr/local/bin/ollama run $model
curl -fsSL https://cdn.anythingllm.com/latest/installer.sh | sh

echo "@reboot root /usr/bin/systemctl start ollama.service && /usr/share/ollama run llama:3.2" | sudo tee -a /etc/crontab
EOF

    echo "Do you want to create .destkop entry? (Y/n)"
    read response

    echo "[Desktop Entry]
Name=AnythingLLM ($container_name)
Exec=distrobox enter $container_name -- \$HOME/.allmbox/$container_name/AnythingLLMDesktop/start && distrobox stop $container_name -Y
Type=Application
Terminal=false" | tee $HOME/.local/share/applications/AnythingLLM-$container_name.desktop

    # Make the file executable
    chmod +x $HOME/.local/share/applications/AnythingLLM-$container_name.desktop

    distrobox stop $container_name -Y
fi