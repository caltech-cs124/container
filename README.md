# Containers Instructions for VSCode
1. Install Docker Desktop for your platform.
   1. Instructions are available [here](https://docs.docker.com/engine/install/).
   2. Make sure that the Docker Engine/daemon is updated and running.
2. Install Dev Containers extension for VSCode.
   1. Further reading on developing inside a container can be found [on VSCode's official documentation](https://code.visualstudio.com/docs/devcontainers/containers).
   2. This is also a part of the Remote Development extension pack for VSCode, which you may find useful.
3. Obtain a compatible Docker container for your system, by either:
   1. **Recommended:** Use one of the [pre-built Docker containers](https://github.com/caltech-cs124-2023sp/container/releases/) provided by the course:
      1. **X86_64:** `ubuntu_i386cross_x86_64.tar.xz`
      2. **ARM64:** `ubuntu_i386cross_arm64.tar.gz`
   2. **Alternatively:** Build your own container from the provided `Dockerfile`, instructions available [below](#building-containers).
4. Load the Docker container tarball using the following command:
   1. `docker load --input ubuntu_i386cross_{x86_64.tar.xz|arm64.tar.gz}`.
   2. You can run `docker image ls` to check that the image is correctly loaded. Check for a tag that says `ubuntu_i386cross...`, this will be relevant when setting up a Dockerfile for your development container.
   3. Once you load the tarball, you can delete it to reclaim storage space.
5. In the root folder of your checked-out Pintos Git repository `cs124-2023sp-TEAMNAME` folder (the folder that contains `./specs`, `./src`, `./tests`, `LICENSE`, etc.), create two new files:
   1. `.devcontainer/Dockerfile`
    ```Dockerfile
    FROM ubuntu_i386cross
    ```
   2. `.devcontainer/devcontainer.json`
    ```json
    {
        "name": "Ubuntu",
        "build": {
            "dockerfile": "Dockerfile"
        }
    }
    ```
6. Using the VSCode Dev Containers plugin, rebuild and reopen the project in the container.
   1. You can use the green remote button `><` on the bottom left of the VSCode window, or open up the `View > Command Palette` and search for `Dev Containers: Rebuild and Reopen in Container`.
   2.  You don’t have to rebuild the container after you build it for the first time; you can just use `Dev Containers: Reopen in Container`.
   3.  When this is successfully done and you are inside the Docker container in VSCode, you will see `Dev Container: Ubuntu` in the green ribbon on the bottom left.
7.  Inside your Docker container instance:
    1.  Edit your `~/.bashrc` file such that the PATH includes your project’s `src/utils` folder. An example of doing that would to be **append this** to your `~/.bashrc` file:
        ```sh
        export PATH=$PATH:/workspaces/${PROJECT}/src/utils
        ```
        You should replace `${PROJECT}` with whatever your repository name is. You will need to **reload your `~/.bashrc`** using the command `source ~/.bashrc`.
8.  Apply the [`cross-container.patch`](./cross-container.patch) to fix the project for the container tools.
    1.  This can be done with `cat cross-container.patch | patch -p1` in the root folder of the repository.
9.  From now on, you should do all your development (or at least, testing) in the container. Try out `make check` or `pintos` commands to make sure it works.
    1.  The provided container only has the minimum viable tools to compile and test PintOS. You may want to install other useful system tools such as `git`, `vim`, `hh`, etc. in the container. This can be done with `apt install git` for example. If you believe that we should bundle other packages in the image, please let us know.
    2.  To make sure everything works fine, you should `cd src/threads` and run `make check`.

# Building Containers
| Tools    |            Version |
| -------- | -----------------: |
| Binutils |             `2.38` |
| GCC      |           `12.1.0` |
| GDB      |           `12.1.0` |
| Bochs    | `2.6.11` + Patches |

There is a provided `Dockerfile` in this repository that is used to build the container.
1. You can build it using this command. Keep in note that the corresponding `Dockerfile` must be in the `.` (current) directory.
    ```sh
    docker build -t ubuntu_i386cross --progress=plain .
    ```
2. This can take up to 20 minutes or longer to build (i9-9880H CPU @ 2.30GHz, 16GB RAM) and can take up to 3GB of storage. The build process requires 7GB of storage. Docker will build the tools in 2 stages:
   1. Build the cross-compilation tools to the `i386-elf` architecture with all of the dependencies.
   2. Transfer only the build artifacts and installs the necessary tools for development (`build-essential` and `qemu-system-i386`).

3. Once it is complete, you should run `docker image ls` to find an entry with the name `ubuntu_i386cross`.
    ```
    REPOSITORY                                                                                TAG       IMAGE ID       CREATED          SIZE
    ubuntu_i386cross                                                                          latest    1d5542e7ef09   11 seconds ago   2.27GB
    ```
4. The image can be saved into a compressed tarball using the following command.
    ```sh
    # Create a tar.xz (high compression ratio, slower, requires xz-tools)
    docker save ubuntu_i386cross | xz > ubuntu_i386cross.tar.xz
    # Create a tar.gz (worse compression ratio, faster)
    docker save ubuntu_i386cross | gzip > ubuntu_i386cross.tar.gz
    ```
5. You can then integrate the container into your workflow of choice.