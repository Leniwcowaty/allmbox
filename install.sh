#!/bin/bash

imageSource="docker.io/leniwcowaty"
image="allmbox:latest"

if [ "$1" = "remove" ]; then
    distrobox enter allmbox -- /usr/local/bin/ollama rm llama3.2
    distrobox rm allmbox -f
    
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
        rm -rf $HOME/.config/anythingllm-desktop
        echo "Application config removed"
    else
        echo "Application config image preserved, located in $HOME/.config/anythingllm-desktop"
    fi

    rm -rf $HOME/.local/share/applications/AnythingLLM.desktop
    
else
    distrobox create --image $imageSource/$image --name allmbox --init
    distrobox enter allmbox -- /setup_env.sh
    # Create the .desktop file

    echo "Do you want to create .destkop entry? (Y/n)"
    read response

    if [ "${response,,}" = "n" ]; then
        echo "Entry not created"
    else
        echo "[Desktop Entry]
Name=AnythingLLM
Exec=distrobox enter allmbox -- \$HOME/AnythingLLMDesktop/start && distrobox stop allmbox -Y
Type=Application
Terminal=false" | tee $HOME/.local/share/applications/AnythingLLM.desktop

        # Make the file executable
        chmod +x $HOME/.local/share/applications/AnythingLLM.desktop
    fi
fi




