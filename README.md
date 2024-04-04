# Containers Instructions for VSCode

1.  Install Docker Desktop for your platform.

    *   Instructions are available [here](https://docs.docker.com/engine/install/).

    *   Make sure that the Docker Engine/daemon is updated and running.

    *   Make these OS-specific configuration changes:
        *   On macOS:  **enable the VirtioFS file sharing implementation** in the settings
        *   On Windows:  **enable the WSL2 engine** in the settings

2.  Install Dev Containers extension for VSCode.

    *   Further reading on developing inside a container can be found on
        [VSCode's official documentation](https://code.visualstudio.com/docs/devcontainers/containers).

    *   This is also a part of the Remote Development extension pack for
        VSCode, which you may find useful.

3.  Obtain a compatible Docker container for your system, by either:

    *   **Recommended:** Use one of the [pre-built Docker containers](https://github.com/caltech-cs124/container/releases/)
        provided by the course:

        *   **X86_64:** `ubuntu_i386cross-x86_64.tar.xz`

        *   **ARM64:** `ubuntu_i386cross-arm64.tar.gz`

    *   **Alternatively:**  Build your own container from the `Dockerfile`
        provided in this repository, instructions available [below](#building-containers).

4.  Load the Docker container tarball using a command like this:

    *   For Intel x86 platform:  `docker load --input ubuntu_i386cross-x86_64.tgz`

    *   For ARM-based platform:  `docker load --input ubuntu_i386cross-arm64.tgz`

    You can run `docker image ls` to check that the image is correctly loaded.
    Check for a tag that says `ubuntu_i386cross...`; this will be relevant
    when setting up a Dockerfile for your development container.

    Once you load the tarball, you can delete it to reclaim storage space.

5.  In the root folder of your checked-out Pintos Git repository
    `cs124-YYYYsp-TEAMNAME` folder (the folder that contains `./specs`,
    `./src`, `./tests`, `LICENSE`, etc.), create two new files:

    1.  File `.devcontainer/Dockerfile` with contents:

        ```Dockerfile
        FROM ubuntu_i386cross
        ```

    2.  File `.devcontainer/devcontainer.json` with contents:

        ```json
        {
            "name": "Ubuntu",
            "build": {
                "dockerfile": "Dockerfile"
            }
        }
        ```

6.  Using the VSCode Dev Containers plugin, reopen the project in the container.
    **If you have completed the previous steps before opening the project in
    VSCode, you may be prompted to do this automatically.**

    *   You can use the blue remote button `><` on the **bottom left of the
        VSCode window**, or open up the `View > Command Palette` and search for
        `Dev Containers: Reopen in Container`.

    *   When this is successfully done and you are inside the Docker container
        in VSCode, you will see `Dev Container: Ubuntu` in the blue ribbon on
        the bottom left.

7.  You can now open a Terminal window in VSCode, and you should see a prompt
    like `root@<somehash>:/workspaces/<your_project_path>`.

8.  **Inside your Docker container instance (i.e. in this Terminal window),**
    edit your `~/.bashrc` file such that the PATH includes your project’s
    `src/utils` folder. An example of doing that would to be **append this**
    to your `~/.bashrc` file:

    ```sh
    export PATH=$PATH:/workspaces/<your_project_path>/src/utils
    ```

    (Replace `<your_project_path>` with whatever your repository name is.

    After this, **reload your `~/.bashrc`** using the command `source ~/.bashrc`.

9.  From now on, you can do all your testing in the container.  Try `make check`
    or `pintos` commands to make sure it works.

    **NOTE:**  Use the non-GUI invocation of `pintos` within the container to
    avoid confusing output.  For example, to run the `alarm-multiple` test,
    use `pintos -v -- run alarm-multiple`, _not_ `pintos run alarm-multiple`.

    *   The provided container only has the minimum necessary tools to compile
        and test PintOS.  You may want to install other useful system tools
        such as `git`, `vim`, `hh`, etc. in the container.  This can be done
        with `apt install git` for example. If you believe that we should
        bundle other packages in the image, please let us know.

    *   To make sure everything works fine, you should `cd src/threads` and
        run `make check`.

# Building Containers

| Tools    |            Version |
| -------- | -----------------: |
| Binutils |             `2.38` |
| GCC      |           `12.1.0` |
| GDB      |           `12.1.0` |
| Bochs    | `2.6.11` + Patches |

This repository includes a `Dockerfile` that is used to build the container.

1.  You can build it using this command.  Keep in note that the corresponding
    `Dockerfile` must be in the `.` (current) directory.

    ```sh
    docker build -t ubuntu_i386cross --progress=plain .
    ```

    This can take up to 20 minutes or longer to build (i9-9880H CPU @ 2.30GHz,
    16GB RAM) and can take up to 3GB of storage.  The build process requires
    7GB of storage.  Docker will build the tools in 2 stages:

    1.  Build the cross-compilation tools to the `i386-elf` architecture with
        all of the dependencies.

    2.  Transfer only the build artifacts and installs the necessary tools for
        development (`build-essential` and `qemu-system-i386`).

2.  Once it is complete, you should run `docker image ls` to find an entry
    with the name `ubuntu_i386cross`.  (**NOTE:**  The "IMAGE ID" value will
    be different.)

    ```
    REPOSITORY                     TAG       IMAGE ID       CREATED          SIZE
    ubuntu_i386cross               latest    1d5542e7ef09   11 seconds ago   2.27GB
    ```

3.  The image can be saved into a compressed tarball using the following
    command.  Note the use of `uname -m` to incorporate the machine
    architecture into the generated filename; you can run `uname -m` by
    itself first to see if it generates reasonable and expected output.

    ```sh
    # Create a gzipped tarball (worse compression ratio, faster)
    docker save ubuntu_i386cross | gzip > ubuntu_i386cross-`uname -m`.tgz
    ```

    Gzip is fast and achieves a reasonable compression level; if you want
    to achieve higher compression rates then use the `xz` compression utility.

    ```sh
    # Create a xz-compressed tarball (high compression ratio, slower, requires xz-tools)
    docker save ubuntu_i386cross | xz > ubuntu_i386cross-`uname -m`.txz
    ```

4.  You can then integrate the container into your workflow of choice.

