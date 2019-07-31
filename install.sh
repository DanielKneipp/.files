#!/usr/bin/env bash

# NOTE: Tested with Ubuntu 16.04

# -------------------------- #
# ---- Global Variables ---- #
# -------------------------- #

# Path of this script
_CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Specifies if the config folder was updated
_DOTCONFIG_UPDATED=false

# -------------------------- #
# ---- Global Functions ---- #
# -------------------------- #

update_dotconfig () {
    # Don't update more than once
    if [ "$_DOTCONFIG_UPDATED" = true ]; then
	    echo_info ".config folder is already updated"
        return
    fi
    _DOTCONFIG_UPDATED=true
	echo "Updating .config folder"

    # Back up the existing .config folder, if there is one
    if [ -d "$HOME/.config" ]; then
        local suffix="$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 5 | head -n 1)"
        echo_info "Backing up existent .config folder to ~/.config_bkp_$suffix"
        cp -r "$HOME/.config" "$HOME/.config_bkp_$suffix" \
            && echo_succ "Original $HOME/.config folder backed up" \
            || on_error "Failed to create a backup of the existent $HOME/.config"
    fi

    # Installing rsync, if need it
    if ! [ -x "$(command -v rsync)" ]; then
        echo_info "Installing rsync (to sync folders)"
        sudo apt install rsync \
            && echo_succ "Rsync installed" \
            || on_error "Failed to install rsync"
    fi

    echo_info "Starting update"
    # Set the new config folder
    rsync -avhu --progress "$_CURR_DIR/.config" "$HOME/"  \
        && echo_succ "New $HOME/.config folder defined" \
        || on_error "Failed to copy the new $HOME/.config folder"
}

# -------------------------- #
# --- Including external --- #
# ------ resources --------- #
# -------------------------- #

source "$_CURR_DIR/msg.sh" \
    || (>&2 echo "Failed to source $_CURR_DIR/msg.sh"; exit 1)

# -------------------------- #
# ----- Program configs ---- #
# -------------------------- #

# ------- Vim stuff -------- #

inst_vim () {
    echo_info "Installing vim"
    sudo apt install -y vim \
        && echo_succ "Vim installed" \
        || on_error "Failed to install Vim"
}

config_vim () {
    echo_info "Configuring vim"

    # Installing deps
    # ctags: for tagbar plugin
    # silversearcher: for Ack
    # cmake: for YouCompleteMe
    sudo apt install -y ctags silversearcher-ag cmake \
        && echo_succ "Dependencies for vim config installed" \
        || on_error "Failed to install dependencies for vim config"

    git clone --depth=1 --recursive https://github.com/DanielKneipp/vimrc.git ~/.vim_runtime \
        && sh ~/.vim_runtime/install_awesome_vimrc.sh \
        && echo_succ "Vimrc downloaded and installed" \
        || on_error "Failed to install vimrc"

    echo_info "Vim configured"
}

# ---------- i3wm ---------- #

config_i3 () {
    echo_info "Configuring i3"

    # Intall config deps
    sudo apt install -y feh scrot paman pavucontrol pavumeter paprefs pasystray rofi \
        && echo_succ "Dependencies for i3 config installed" \
        || on_error "Failed to install i3 config dependencies"

    # Back up the existing i3 folder, if there is one
    if [ -d "$HOME/.i3" ]; then
        local suffix="$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 5 | head -n 1)"
        mv "$HOME/.i3" "$HOME/.i3_bkp_$suffix" \
            && echo_succ "Original $HOME/.i3 folder backed up" \
            || on_error "Failed to create a backup of the existent $HOME/.i3"
    fi

    # Set the new config file
    mkdir -p "$HOME/Pictures/screenshots/"
    cp -r "$_CURR_DIR/.i3" "$HOME/.i3" \
        && echo_succ "New $HOME/.i3 folder defined" \
        || on_error "Failed to copy the new $HOME/.i3 folder"

    echo_info "i3 configured"
}

inst_i3 () {
    echo_info "Installing i3"

    /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2018.01.30_all.deb keyring.deb SHA256:baa43dbbd7232ea2b5444cae238d53bebb9d34601cc000e82f11111b1889078a \
        && sudo dpkg -i ./keyring.deb \
        && sudo su -c "echo \"deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe\" >> /etc/apt/sources.list.d/sur5r-i3.list" \
        && sudo apt update \
        && sudo apt install -y i3 \
        && echo_succ "i3 installed" \
        || on_error "Failed to install i3"
}

inst_i3_gaps () {
    echo_info "Installing i3-gaps"

    # Install deps
    sudo add-apt-repository -y ppa:aguignard/ppa \
        && sudo apt-get update \
        && sudo apt install -y libxcb1-dev \
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
            libxcb-xrm-dev \
        && echo_succ "Dependencies for i3-gaps installed" \
        || on_error "Failed to install dependencies of i3"

    # Create dir for the project and clone i3-gaps there
    old_dir="$PWD"
    mkdir -p "$HOME/projects" \
        && cd "$HOME/projects" \
        && git clone https://www.github.com/Airblader/i3 i3-gaps \
        && echo_succ "i3-gaps cloned into $HOME/projects" \
        || on_error "Failed to clone i3-gaps into $HOME/projects"

    # compile & install
    cd "$HOME/projects/i3-gaps"
    autoreconf --force --install
    rm -rf build/
    mkdir -p build && cd build/

    # Disabling sanitizers is important for release versions!
    # The prefix and sysconfdir are, obviously, dependent on the distribution.
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers \
        && make \
        && sudo make install \
        && echo_succ "i3-gaps configured, compiled and installed" \
        || on_error "Failed to install i3-gaps"

    # Go back
    cd "$old_dir"

    echo_info "i3-gaps installed"
}

# ---------- tmux ---------- #

inst_tmux () {
    echo_info "Installing tmux"

    # Install tmux and Tmux Plugin Manager
    sudo apt install -y tmux \
        && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
        && echo_succ "Tmux installed" \
        || on_error "Failed to install tmux"
}

config_tmux () {
    echo_info "Configuring tmux"

    # Put the config file in the right place
    cp "$_CURR_DIR/.tmux.conf" "$HOME/.tmux.conf" \
        && echo_succ "Configuration file copied" \
        || on_error "Failed to copy configuration file"

    echo_info "tmux configured"
}

# ---------- fish ---------- #

inst_fish () {
    echo_info "Installing fish"

    sudo apt install -y fish \
        && echo_succ "fish installed" \
        || on_error "Failed to install fish"
}

config_fish () {
    echo_info "Configuring fish"

    # Set fish as the default shell
    chsh -s /usr/bin/fish \
        && echo_succ "Fish is now the default shell" \
        || echo_warn "Failed to set fish as the default shell"

    # Update the .config file
    update_dotconfig

    echo_info "fish configured"
}

# ---------- git ---------- #

config_git () {
    echo_info "Configuring git"

    cp "$_CURR_DIR/.gitconfig" "$HOME/.gitconfig" \
        && echo_succ "Configuration file copied" \
        || on_error "Failed to copy configuration file"

    echo_info "git configured"
}

# -------------------------- #
# ----- Main Workflows ----- #
# -------------------------- #

config_all () {
    echo_info "Configuring all"
    config_vim
    config_tmux
    config_fish
    config_i3
    config_git
    echo_info "All things configured"
}

inst_all () {
    echo_info "Installing all"
    inst_vim
    inst_tmux
    inst_fish
    inst_i3
    inst_i3_gaps
    echo_info "All things installed"
}

# Only config the programs
main () {
    inst_fish
    config_fish
    config_tmux
}

main
