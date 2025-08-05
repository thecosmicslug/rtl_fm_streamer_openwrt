## rtl_fm_streamer_openwrt


This is my attempt at porting rtl_fm_streamer to the OpenWRT platform.

I had plans to use an old OpenWRT router to stream FM radio via wireless, to kodi devices in my home.

So far its just producing static, seems like a cpu bottleneck on my BT-HomeHub5 router but I have included instructions how to compile, incase others want to try!

This code was taken from https://github.com/AlbrechtL/rtl_fm_streamer and adapted for OpenWRT.

[Original README from rtl_fm_streamer](/README_ORIGINAL.md)


### Setting up the OpenWRT Buildsystem
---------------------------
First we need to setup the OpenWRT build system, these are the basic steps to build your own OpenWrt images/packages.

Install the build prerequisites: (Ubuntu 24.04)

    sudo apt update
    sudo apt install build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
    python3-setuptools rsync swig unzip zlib1g-dev file wget

Download the sources:

    git clone https://git.openwrt.org/openwrt/openwrt.git
    cd openwrt

View the available releases:

    git branch -a

Then pick a version to checkout:

    git checkout openwrt-24.10


### Adding rtl_fm_streamer to OpenWRT
-------------------------------------

Retrieve the software feeds:

    ./scripts/feeds update -a && ./scripts/feeds install -a

Add this repo to `feeds/packages/utils/`

    cd feeds/packages/utils/
    git clone git@github.com:thecosmicslug/rtl_fm_streamer_openwrt.git

Return to the main openwrt directory:

    cd ../../../

Update Feeds again to include rtl_fm_streamer in menuconfig

    ./scripts/feeds update -a && ./scripts/feeds install -a
    
Configure the build by selecting target router and the our package at `utils/rtl_fm_streamer`

    make defconfig
    make menuconfig

Save the configuration as `.config` to exit menuconfig.

Download needed files:

    make download

### Building rtl_fm_streamer
-------------------------------------

Build the packages, log output to `build.log`: (Grab a coffee, this will take a while!)

    make V=s 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)"


The package will be located in:

    bin/packages/<TARGET-ARCH>/packages/
