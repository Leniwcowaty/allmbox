#!/bin/bash

# Base image
image="ubuntu:noble"

# List of models available for Ollama
models=("gemma3:1b" "gemma3" "gemma3:12b" "gemma3:27b" "qwq" "deepseek-r1" "deepseek-r1:671b" "llama4:scout" "llama4:maverick" "llama3.3" "llama3.2:1b" "llama3.2-vision" "llama3.2-vision:90b"
        "llama3.1" "llama3.1:405b" "phi4" "phi4-mini" "phi3" "mistral" "moondream"
        "neural-chat" "starling-lm" "codellama" "llama2-uncensored" "llava" "granite3.3")

# Default model
default="llama3.2"

# Create list of existing containers
list_containers() {
    container_list=()
    for box in $(distrobox ls | grep allmbox | awk '{print $3}'); do
        container_list+=($box)
    done
    echo "${container_list[@]}"
}

if [ "$1" = "remove" ]; then # Remove container
    container_list=($(list_containers))

    # Check if there's only one container, if so set it's name as variable to remove - when using install.sh remove without -c option
    if [[ ${#container_list[@]} -eq 1 ]]; then
        container_name=$(distrobox ls | grep allmbox | awk '{print $3}')
    fi

    # If options provided, shift them to $1
    if [[ "$2" ]]; then
        shift $((--$2))
    fi

    # Options selection: -h for help, -c for selecting container to remove, -l to list containers
    while getopts ":hlc:" opt; do
        case $opt in
        h)
            echo "Usage: $0 remove [options]"
            echo "Options:"
            echo "  -c container    Which container you want to remove"
            echo "  -l              List all allmbox containers"
            echo "  -h              Print this help message"
            exit 0
            ;;
        l)
            distrobox ls | grep allmbox | awk '{print $3}'
            exit 0
            ;;
        c)
            container_name=$OPTARG
            ;;
        :)
            # No argument given to -c, exit 128
            echo "Option -$OPTARG requires an argument."
            exit 128
            ;;
        *)
            # Invalid option, exit 128
            echo "Invalid option: -$OPTARG"
            exit 128
            ;;
        esac
        
    done

    # Error if more than one container exists and no -c option was given
    if [[ -z $container_name && ${#container_list[@]} -gt 1 ]]; then
        echo "More than one allmbox container exists, use option -c (-h for help)"
        exit 128
    fi

    # Check if container with given name exists
    if [[ ${container_list[@]} =~ $container_name ]]; then
        echo "Selected container: $container_name"

        # Remove container itself
        distrobox rm $container_name -f

        # Remove container artificial home and desktop entry
        rm -rf $HOME/.allmbox/$container_name
        echo "Application config removed"

        # If this is the only container, remove also .allmbox directory
        container_list=($(list_containers))
        if [[ ${#container_list[@]} -eq 0 ]]; then
            rm -rf $HOME/.allmbox
        fi

        rm -rf $HOME/.local/share/applications/AnythingLLM-$container_name.desktop
        echo -e "\nApplication menu entry removed"
    else
        echo "There is no container named $container_name"
        exit 128
    fi

else # Install container
    container_list=($(list_containers))
    # If no option -m given, set model to default 
    model=$default

    # Options selection: -h for help, -m for selecting model
    while getopts ":hlm:" opt; do
        case $opt in
        h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -m model        Which model to use "
            echo "  -l              List available models
                    The list of available models is also available on Ollama Github page: https://github.com/ollama/ollama"
            echo "  -h              Print this help message"
            echo -e "\nAdditional commands:"
            echo "  remove          Remove container 
                    If you have only one container, you can run "install.sh remove", with multiple containers use -c option (see install.sh remove -h for help)"
            exit 0
            ;;
        l)
            echo "Available Ollama LLM models:"
            for item in "${models[@]}"; do
                echo "$item"
            done
            exit 0
            ;;
        m)
            # Check if model is in the supported list, if not exit 128
            if [[ ${models[@]} =~ ${OPTARG,,} ]]; then
                model=${OPTARG}
            else
                echo "Invalid model, please refer to Ollama Github page: https://github.com/ollama/ollama"
                exit 128
            fi
            ;;
        :)
            # No argument given to -m, exit 128
            echo "Option -$OPTARG requires an argument."
            exit 128
            ;;
        *)
            # Invalid option, exit 128
            echo "Invalid option: -$OPTARG"
            exit 128
            ;;
        esac

    done

    echo "Selected model: $model"

    # Create container name "allmbox-[model] and strip : from model names, replace them with _ - messes with distrobox create
    container_name="allmbox-${model//:/_}"

    # Check if container with that name already exists, if so exit 128
    if [[ ${container_list[@]} =~ $container_name ]]; then
        echo "Container with that name "$container_name" already exists!"
        exit 128
    fi

    mkdir -p $HOME/.allmbox
    mkdir -p $HOME/.allmbox/$container_name

    # Create a base container based on $image with $container_name, install additional dependencies, create artificial home directory to separate instances, set default shell to bash, don't create menu entry for bare container, use systemd
    distrobox create --image $image --name $container_name --home $HOME/.allmbox/$container_name -ap "lshw libnss3 alsa cron curl" -a "--env SHELL=/bin/bash" --init --yes --no-entry
    
    # Configure container - install ollama, start it and download selected model, install AnythingLLM and add ollama model autostart at container boot to cron
    distrobox enter $container_name -- << EOF
curl -fsSL https://ollama.com/install.sh | sh
sleep 3
echo "Downloading and installing model $model"
sudo /usr/bin/systemctl start ollama.service
sleep 3
echo "/bye" | /usr/local/bin/ollama run $model
curl -fsSL https://cdn.anythingllm.com/latest/installer.sh | sh

echo "@reboot root /usr/bin/systemctl start ollama.service" | sudo tee -a /etc/crontab
EOF

    # Link themes and icons so that the application doesn't look out of date
    echo "Linking user themes and icons to container home"
    ln -s $HOME/.icons $HOME/.allmbox/$container_name/.icons
    ln -s $HOME/.themes $HOME/.allmbox/$container_name/.themes

    echo "Creating AnythingLLM ($container_name) entry in application menu"

    # Generate .desktop entry with container name, so it's easy to differenciate
    echo "[Desktop Entry]
Name=AnythingLLM ($container_name)
Exec=sh -c \"distrobox enter $container_name -- \\\\\$HOME/.allmbox/$container_name/AnythingLLMDesktop/start && distrobox stop $container_name -Y\"
Type=Application
Terminal=false" | tee $HOME/.local/share/applications/AnythingLLM-$container_name.desktop >> /dev/null

    # Make the .desktop file executable
    chmod +x $HOME/.local/share/applications/AnythingLLM-$container_name.desktop

    # Stop the container to prevent performance impact with LLM running in the background
    distrobox stop $container_name -Y >> /dev/null
fi
