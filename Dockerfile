ARG SWD=/home/tools
ARG PREFIX=${SWD}/cross

FROM ubuntu:22.04 as BUILD
ARG SWD
ARG PREFIX

# Install dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install build-essential libncurses5-dev \
    texinfo xz-utils libgmp-dev libmpfr-dev libmpc-dev wget curl

# Set up build environment variables
RUN mkdir ${SWD}

WORKDIR ${SWD}
# Build Binutils
RUN mkdir binutils &&\
    cd ${SWD}/binutils &&\
    wget -nv https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.xz && tar -xJf binutils-2.38.tar.xz &&\
    mkdir -p ${SWD}/binutils/build/binutils &&\
    # Build
    cd ${SWD}/binutils/build/binutils &&\
    ../../binutils-2.38/configure --prefix=$PREFIX --target=i386-elf \
    --disable-multilib --disable-nls --disable-werror &&\
    make -j8 &&\
    make install &&\
    # Clean up
    cd ${SWD} &&\
    rm -rf binutils

# Build GCC
RUN mkdir gcc &&\
    cd ${SWD}/gcc &&\
    wget -nv https://ftp.gnu.org/gnu/gcc/gcc-12.1.0/gcc-12.1.0.tar.xz && tar -xJf gcc-12.1.0.tar.xz &&\
    mkdir -p ${SWD}/gcc/build/gcc &&\
    # Build
    cd ${SWD}/gcc/build/gcc &&\
    ../../gcc-12.1.0/configure --prefix=$PREFIX --target=i386-elf \
    --disable-multilib --disable-nls --disable-werror --disable-libssp \
    --disable-libmudflap --with-newlib --without-headers --enable-languages=c,c++ &&\
    make -j8 all-gcc &&\
    make install-gcc &&\
    make all-target-libgcc &&\
    make install-target-libgcc &&\
    # Clean up
    cd ${SWD} &&\
    rm -rf gcc

# Build GDB
RUN mkdir ${SWD}/gdb &&\
    cd ${SWD}/gdb &&\
    wget -nv https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.xz && tar -xJf gdb-12.1.tar.xz &&\
    mkdir -p ${SWD}/gdb/build/gdb &&\
    # Build
    cd ${SWD}/gdb/build/gdb &&\
    ../../gdb-12.1/configure --prefix=$PREFIX --target=i386-elf --disable-werror &&\
    make -j8 &&\
    make install &&\
    # Clean up
    cd ${SWD} &&\
    rm -rf gdb

# Build Bochs
RUN mkdir ${SWD}/bochs &&\
    cd ${SWD}/bochs &&\
    wget -nv https://versaweb.dl.sourceforge.net/project/bochs/bochs/2.6.2/bochs-2.6.2.tar.gz && tar -xvzf bochs-2.6.2.tar.gz &&\
    # Apply patches to Bochs
    cd ${SWD}/bochs/bochs-2.6.2 &&\
    curl https://raw.githubusercontent.com/caltech-cs124-2023sp/container/main/bochs-2.6.2-banner-stderr.patch | patch -p1 &&\
    curl https://raw.githubusercontent.com/caltech-cs124-2023sp/container/main/bochs-2.6.2-block-device-check.patch | patch -p1 &&\
    curl https://raw.githubusercontent.com/caltech-cs124-2023sp/container/main/bochs-2.6.2-jitter-plus-segv.patch | patch -p1 &&\
    curl https://raw.githubusercontent.com/caltech-cs124-2023sp/container/main/bochs-2.6.2-link-tinfo.patch | patch -p1 &&\
    curl https://raw.githubusercontent.com/caltech-cs124-2023sp/container/main/bochs-2.6.2-xrandr-pkgconfig.patch | patch -p1 &&\
    cd ${SWD}/bochs &&\
    # Build a normal version of Bochs
    mkdir -p build/bochs &&\
    cd ${SWD}/bochs/build/bochs &&\
    ../../bochs-2.6.2/configure --with-term --with-nogui --prefix=$PREFIX --enable-gdb-stub CFLAGS="-w -fpermissive" CXXFLAGS="-w -fpermissive" &&\
    make -j8 &&\
    make install &&\
    cd ${SWD}/bochs/build/ &&\
    mkdir -p bochs-dbg &&\
    # Build a debug version of Bochs
    cd ${SWD}/bochs/build/bochs-dbg &&\
    ../../bochs-2.6.2/configure --with-term --with-nogui --enable-debugger --disable-debugger-gui --prefix=$PREFIX CFLAGS="-w -fpermissive" CXXFLAGS="-w -fpermissive" &&\
    make -j8 &&\
    cp ./bochs ${PREFIX}/bin/bochs-dbg &&\
    # Clean up
    cd ${SWD} &&\
    rm -rf bochs

# Assembly stage
# Only copy over what is purely needed
FROM ubuntu:22.04
ARG SWD
ARG PREFIX

# Install dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install build-essential \
    libvirt-daemon-system libvirt-clients qemu-system-i386

COPY --from=BUILD ${SWD} ${SWD}

# Fix locale settings for Perl
RUN /bin/sh -c "echo 'export LC_ALL=C' >> ~/.bashrc"
RUN /bin/sh -c "echo 'export PATH=$PATH:${PREFIX}/bin' >> ~/.bashrc"