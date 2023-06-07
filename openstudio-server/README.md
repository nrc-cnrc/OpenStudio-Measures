# Set up, configure, and deploy the OpenStudio-Server
This folder contains the scripts used to create a local OpenStudio-Server. The server will run inside a [Docker container](https://www.docker.com/resources/what-container/) and is usually interfaced using [OpenStudio-PAT](https://nrel.github.io/OpenStudio-user-documentation/reference/parametric_analysis_tool_2/).

## Hardware requirements
The server will be configured to use 1/2 of the available cores on the host machine (or "total number of CPU - 5", whichever is less). The minimum number of 
cores suggested is eight but more is better, likewise with memory (at least 16 GB is recommended). 

## Required software
** We're currently running on Windows 10. Although Linux/macOS versions of these applications are available, we are unable to confirm their compatibility.**
1. [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. [Git](https://git-scm.com/downloads)
3. [OpenStudio-PAT v3.2.1](https://github.com/NREL/OpenStudio-PAT/releases/tag/v3.2.1)

## Installation notes
1. During the installation for Git, select the option to include "Git Bash".


## Initial set up of the server
1. After installing Docker and opening it for the first time on Windows, you may be prompted to download WSL2, follow the link provided or download the package (.msi) [here](https://learn.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package). This will install a compatibility layer to allow your windows machine to run linux applications (Docker Desktop).
2. Set the max CPU and RAM usage by creating a file called `.wslconfig` (yes, it has "no name" and just a ".wslconfig" extension) and saving it at `C:/Users/<insert_your_name>/`. Within the file, copy the following text and replace the number value for memory (RAM) or processors (CPU) if needed:

```
[wsl2] 
memory=8GB # Max 8 GB RAM
processors=6 # 6 CPU
```

3. Environment variables for the server(OpenStudio version, shared path, git repository etc.) are set in the [env.sh](env.sh) file. Subsequent scripts will reference them. In the env file, change the location in the variable `docker_win_root="D:\Docker\OS"` to a location that you want to store server files at (e.g. `C:\Docker\OS`)

## Deploy/stop the server

1. Start Docker Desktop (wait for it load)
2. Open a git bash terminal at this [directory](/openstudio-server) and run the command:

    `./1-configure-start-server.sh`

    Running this script for the first time will download the server images, gems, and dependencies needed by the server and will take time. Subsequent runs will only need to restart the containers and be much faster. 

3. To stop the server, run 

    `./2-stop-server.sh`

4. Exit Docker Desktop and run the following command to shutdown the virtual machine (otherwise it will continue to take up RAM)

    `wsl --shutdown`

## How to use the server/link to the server from PAT
The server is where the simulations will run, we suggest familiarizing yourself with [OpenStudio-PAT](https://nrel.github.io/OpenStudio-user-documentation/reference/parametric_analysis_tool_2/) as the tool to define simulation jobs to be sent to the server.

1) If using PAT on the same machine as the server is running, link to 'https://localhost/:8080'

2) If using PAT from a remote machine, link to 'https:/IP_address_of_remote_machine/:8080'

## Advance configurations
Additional commands/instructions for configuring the server (e.g. changing the openstudio-standards version/branch, cleaning the files, changing the location of the VM image, removing the files etc.) can be found in the wiki.
