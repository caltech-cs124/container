# Pre-built Containers Instructions for VSCode
1. Install Docker Desktop for your platform.
   1. Instructions are available [here](https://docs.docker.com/engine/install/)
2. Install Dev Containers extension for VSCode.
   1. Further reading on developing inside a container can be found [on VSCode's official documentation](https://code.visualstudio.com/docs/devcontainers/containers).
3. Download the course-provided Docker container tarball for your system:
   1. **X86_64:** `ubuntu_i386cross_x86_64.tar.gz` (not yet available)
   2. **ARM64:** `ubuntu_i386cross_arm64.tar.gz` (not yet available)
4. Load the Docker container tarball using the following command:
   1. `docker load --input ubuntu_i386_gcc_{ARCH}` where `{ARCH}` is `x86_64` or `arm64` respectively.
5. In your checked out Pintos Git repository (the folder that contains `./specs`, `./src`, `./tests`, `LICENSE`, etc.), create two new files:
   1. `.devcontainer/Dockerfile`
    ```Dockerfile
    FROM ubuntu_i386cross_{ARCH}
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
7. You can use the green remote button on the bottom left of the VSCode window, or open up the Command Palette and search for “Dev Containers: Rebuild and Reopen in Container.”
8.  You don’t have to rebuild the container after you build it for the first time; you can just use “Dev Containers: Reopen in Container.”
9.  Edit your `~/.bashrc` file such that the PATH includes your project’s src/utils folder. An example of doing that would to be append this to your `~/.bashrc` file:
    ```sh
    export PATH=/home/tools/bin:$PATH:/workspaces/${PROJECT}/src/utils
    ```
    You should replace `${PROJECT}` with whatever your repository name is.
10. You should be good to go! Try out `make check` or `pintos` commands to make sure it works.
    1.  This is the **minimum viable tools** that you need to compile and run Pintos. You may want to install other useful system tools such
        as `git`, `vim`, `hh`, etc. in the container. This can be done with `apt install git` for example.
    2.  Afterwards, you may also need to apply the `cross-container.patch` to fix the project for the new tools to accept them.
        1.  This can be done with `cat cross-container.patch | patch -p1`.

# Building Containers
There is a provided `Dockerfile` in this repository that can be used to build the container. You can build it using this command. Keep in note that the `Dockerfile` must be in the `.` (current) directory.
```sh
docker build -t ubuntu_i386cross --progress=plain .
```
This can take up to 20 minutes or longer to build (i9-9880H CPU @ 2.30GHz, 16GB RAM) and can take up to 3GB of storage. The build process requires 7GB of storage. Docker will build the tools in 2 stages:
1. Build the cross-compilation tools to the `i386-elf` architecture with all of the dependencies.
2. Transfer only the build artifacts and installs the necessary tools for development (`build-essential` and `qemu-system-i386`).

The versions of tools being used are:
* Binutils 2.38
* GCC 12.1.0
* GDB 12.1.0
* Bochs 2.6.2

Once it is complete, you should run `docker image ls` to find an entry with the name `ubuntu_i386cross`.
```
REPOSITORY                                                                                TAG       IMAGE ID       CREATED          SIZE
ubuntu_i386cross                                                                          latest    1d5542e7ef09   11 seconds ago   2.27GB
```

You can then integrate it into your editor of choice. Instructions for VSCode are the same as step 5 and beyond from this point.