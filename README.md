# README.md
## Allmbox
A self-hosted Llama3.2 chatbot with graphical frontend using Distrobox container and hardware acceleration.

### Dependencies
This repository uses the following dependencies:
- [Oolama](https://github.com/ollama/ollama) for the backend
- [AnythingLLM](https://github.com/Mintplex-Labs/anything-llm) for the frontend

The Podman image is based on Ubuntu 24.04 base image (ubuntu:noble tag) with added compatibility dependencies and Oolama + AnythingLLM setup script.

### Installation Requirements
Before running the installer, make sure you have the following requirements:
- A 64-bit operating system (tested on Fedora 41)
- Podman
- Distrobox
- (optional) AMD GPU for hardware acceleration (tested on series 7000 AMD GPUs, will probably run on older ones, but I'm 99% sure it won't work on NVidia, contributors welcomed)

### Installation Instructions
Make sure you have Podman and Distrobox installed. After that clone the repo from `master` branch and run `install.sh`

```bash
git clone https://github.com/Leniwcowaty/allmbox.git
cd allmbox
./install.sh
```

The script will pull Podman image, create the box named `allmbox` and setup both Ollama and AnythingLLM. In the end it will ask if you want to create .desktop entry - the default is Yes.

### Running the Chatbot
You can run AnythingLLM from your application launcher if you opted into adding .desktop entry. If not (or you prefer command line) you can run it from terminal with:

```bash
distrobox enter allmbox -- $HOME/AnythingLLMDesktop/start
```

If you use .desktop entry the container will be stopped after you exit the application. Due to this launching the app takes a bit longer, but if it's not stopped it may impact your performance, since you have an LLM running in the background at all times. If you use CLI command, you have to remember to stop it yourself.

Upon first launch you will be greeted by AnythingLLM welcome screen and will be prompted to choose the backend, as shown below.

[images/choose_backend.png]

Choose of course **Ollama**. The app should automatically detect local installation of **llama3.2** and allow you to continue. Next steps include summary, opt-in AnythingLLM telemetry and naming your workspace. After that you're good to go.

If you want to reset AnythingLLM config, it's located in `$HOME/.config/anythingllm-desktop`

### Removing the Chatbot
To remove the chatbot use the installation script with keyword `remove`:
```bash
./install.sh remove
```

It will ask if you want to delete Podman image, AnythingLLM config files. In both cases the default is No.

### Contributing to the Project
Contributions are welcome! If you'd like to help with the project, please fork this repository and submit a pull request. If you want you can rebase it to other distro, or provide a build Dockerfile which will work for NVidia (I don't have NVidia card, so I can't test).

### License
This repository is hosted under the [MIT license](https://opensource.org/licenses/MIT) created by leniwcowaty. By contributing to this project, you agree to be bound by the terms of the MIT license.

### Important notice about this project!
This is my personal passion/learning project. I'm in no shape or form a developer, Docker/Podman specialist, and have very basic knowledge about Bash scripting. As a result - this is not 100% guaranteed to be fool-proof, stable and reliable. I will try to learn, evolve and make this project better, but as of right now - it's just a hobby for me.