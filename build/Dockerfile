FROM ubuntu:noble AS builder

# Update and upgrade system
RUN apt update && apt upgrade -y

# Install packages
RUN apt install -y lshw libnss3 alsa cron curl

# Run script1 (assuming it's in the current directory)
COPY setup_env.sh /setup_env.sh
RUN chmod +x /setup_env.sh