#!/bin/bash

imageSource="docker.io/leniwcowaty"
image="allmbox:latest"

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

    echo "Do you want to remove podman image? (y/N)"
    read response

    if [ "${response,,}" = "y" ]; then
        podman image rm $image --force
        echo "Podman image removed"
    else
        echo "Podman image preserved, you can remove it by yourself by esecuting 'podman image rm $image'"
    fi

    echo "Do you want to remove AnythingLLM application config? (y/N)"
    read response

    if [ "${response,,}" = "y" ]; then
        rm -rf $HOME/.allmbox/$container_name
        echo "Application config removed"
    else
        echo "Application config image preserved, located in $HOME/.allmbox/$container_name"
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

    echo "Provide name for your container: [allmbox]"
    read container_name

    if [ -z "$container_name" ]; then
        container_name="allmbox"
    fi

    mkdir -p $HOME/.allmbox
    mkdir -p $HOME/.allmbox/$container_name
    mkdir -p $HOME/.allmbox/$container_name/anythingllm-desktop

    distrobox create --image $imageSource/$image --name $container_name --volume $HOME/.allmbox/$container_name/anythingllm-desktop:$HOME/.config/anythingllm-desktop:rw --init --no-entry --yes
    distrobox enter $container_name -- /setup_env.sh $model
    # Create the .desktop file

    echo "Do you want to create .destkop entry? (Y/n)"
    read response

    if [ "${response,,}" = "n" ]; then
        echo "Entry not created"
    else
        echo "[Desktop Entry]
Name=AnythingLLM ($container_name)
Exec=distrobox enter $container_name -- \$HOME/AnythingLLMDesktop/start && distrobox stop $container_name -Y
Type=Application
Terminal=false" | tee $HOME/.local/share/applications/AnythingLLM-$container_name.desktop

        # Make the file executable
        chmod +x $HOME/.local/share/applications/AnythingLLM-$container_name.desktop
    fi
    distrobox stop $container_name -Y
fi




