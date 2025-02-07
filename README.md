# README.md
## Allmbox
A self-hosted chatbot with graphical frontend using Distrobox container and hardware acceleration. It can run all the models available for Ollama and allows to create multiple instances for different models.

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

The script will pull Podman image, then ask you for model you want to use. List of models is available on [Ollama Github page](https://github.com/ollama/ollama). The default model is **llama3.2**. 

*Keep in mind - for now it doesn't have any "idiot-proofing", so if you input wrong model name the installation will continue, but the model won't be installed.*

Next step, the script will ask for container name. This name will also be in .desktop entry name to make it easier to differenciate between instances. The default name is **allmbox**.

Following that the script will continue to set up container and prompt you if you want to create .desktop entry. The default is **Yes**.

*You can install multiple instances of allmbox by re-running install.sh and providing different container name. This allows you to have multiple AnythingLLM entries, each using different model. The names will be reflected in .desktop entries.*

### Running the Chatbot
You can run AnythingLLM from your application launcher if you opted into adding .desktop entry. If not (or you prefer command line) you can run it from terminal with:

```bash
distrobox enter allmbox -- $HOME/AnythingLLMDesktop/start
```

If you use .desktop entry the container will be stopped after you exit the application. Due to this launching the app takes a bit longer, but if it's not stopped it may impact your performance, since you have an LLM running in the background at all times. If you use CLI command, you have to remember to stop it yourself.

Upon first launch you will be greeted by AnythingLLM welcome screen and will be prompted to choose the backend, as shown below.

![](images/choose_backend.png)

Choose of course **Ollama**. The app should automatically detect local installation of **llama3.2** and allow you to continue. Next steps include summary, opt-in AnythingLLM telemetry and naming your workspace. After that you're good to go.

Per-container AnythingLLM configs are located in `$HOME/.allmbox/[container name]/anythingllm-desktop`

### Removing the Chatbot
To remove the chatbot use the installation script with keyword `remove`:
```bash
./install.sh remove
```

This will display list of all containers using **allmbox** image and then ask for name of the container you want to remove. Next it will ask if you want to delete Podman image, AnythingLLM config files. In both cases the default is **No**. 

*If you opt in to delete config files and this was the only instance, the main allbox config folder will also be deleted.*

### Contributing to the Project
Contributions are welcome! If you'd like to help with the project, please fork this repository and submit a pull request. If you want you can rebase it to other distro, or provide a build Dockerfile which will work for NVidia (I don't have NVidia card, so I can't test).

### License
This repository is hosted under the [MIT license](https://opensource.org/licenses/MIT) created by leniwcowaty. By contributing to this project, you agree to be bound by the terms of the MIT license.

### Important notice about this project!
This is my personal passion/learning project. I'm in no shape or form a developer, Docker/Podman specialist, and have very basic knowledge about Bash scripting. As a result - this is not 100% guaranteed to be fool-proof, stable and reliable. I will try to learn, evolve and make this project better, but as of right now - it's just a hobby for me.