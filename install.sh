#!/usr/bin/env bash

# TODO: Test everything
# TODO: Error checks

# -------------------------- #
# ---- Global Variables ---- #
# -------------------------- #

# Path of this script
_CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# -------------------------- #
# ----- Program configs ---- #
# -------------------------- #

# ------- Vim stuff -------- #

inst_vim () {
    sudo apt install vim
}

config_vim () {
    # Installing deps
    sudo apt install -y ctags # For tagbar plugin

    git clone --depth=1 --recursive https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
}

# ---------- i3wm ---------- #

config_i3 () {
    # Intall config deps
    sudo apt install feh \
        rofi

    # Back up the existing config file, if there is one
    if [ -d "$HOME/.i3/config" ]; then
       mv -b "$HOME/.i3/config" "$HOME/.i3/config.bkp"
    fi

    # Set the new config file
    cp "$_CURR_DIR/.i3/config" "$HOME/.i3/config"
}

inst_i3 () {
    /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2018.01.30_all.deb keyring.deb SHA256:baa43dbbd7232ea2b5444cae238d53bebb9d34601cc000e82f11111b1889078a
    sudo dpkg -i ./keyring.deb
    sudo echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list
    sudo apt update
    sudo apt install i3
}

inst_i3_gaps () {
    # Install deps

    sudo add-apt-repository ppa:aguignard/ppa
    sudo apt-get update
    sudo apt install -y libxcb1-dev \
        libxcb-keysyms1-dev \
        libpango1.0-dev \
        libxcb-util0-dev \
        libxcb-icccm4-dev \
        libyajl-dev \
        libstartup-notification0-dev \
        libxcb-randr0-dev \
        libev-dev \
        libxcb-cursor-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        autoconf \
        libxcb-xrm-dev

    # Create dir for the project and go to there
    old_dir="$PWD"
    mkdir -p "$HOME/projects"
    cd "$HOME/projects"

    # clone the repository
    git clone https://www.github.com/Airblader/i3 i3-gaps
    cd i3-gaps

    # compile & install
    autoreconf --force --install
    rm -rf build/
    mkdir -p build && cd build/

    # Disabling sanitizers is important for release versions!
    # The prefix and sysconfdir are, obviously, dependent on the distribution.
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
    make
    sudo make install

    # Go back
    cd "$old_dir"
}


# -------------------------- #
# ----- Main Workflows ----- #
# -------------------------- #

config_all () {
    config_vim
    config_i3
}

inst_all () {
    inst_vim
    inst_i3
    inst_i3_gaps
}

# Only config the programs
main () {
    config_all
}

main
