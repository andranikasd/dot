#!/bin/bash

# Function to print a fancy log message
fancy_log() {
    gum style --foreground 212 --bold -- "$1"
}

# Function to install gum
install_gum() {
    if ! command -v gum &> /dev/null; then
        mkdir -p ~/.local/bin
        wget -qO- https://github.com/charmbracelet/gum/releases/download/v0.8.0/gum_0.8.0_Linux_x86_64.tar.gz | tar xvz -C ~/.local/bin gum
        export PATH=$PATH:~/.local/bin
    fi
}

setup_prereq() {
    install_gum
    fancy_log "Setting up prerequisites..."
    sudo apt update -qq
    sudo apt upgrade -y -qq
    sudo apt install wget curl git ca-certificates software-properties-common dirmngr apt-transport-https lsb-release -y -qq
}

# Function to install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        fancy_log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

# Function to install a package via apt
install_apt_package() {
    if ! dpkg -s "$1" &> /dev/null; then
        fancy_log "Installing $1 via apt..."
        sudo apt-get install -y -qq "$1"
    fi
}

# Function to install a package via brew
install_brew_package() {
    if ! brew list "$1" &> /dev/null; then
        fancy_log "Installing $1 via brew..."
        brew install "$1"
    fi
}

# Function to setup a PPA and update
setup_ppa() {
    fancy_log "Setting up PPA $1..."
    sudo add-apt-repository "$1" -y -qq
    sudo apt-get update -qq
}

# Setup prereq, Install Homebrew & gum
setup_prereq
install_gum
install_homebrew

# Prompt user for tools to install
options=("Browsers" "Slack" "PyCharm" "VSCode" "Tilix Terminal" "Kitty" "Docker" "Git" "CodeCommit" "wget" "curl" "Python3" "pip" "venv" "Zsh" "Starship" "AWS CLI" "Terraform CLI" "kubectl" "fzf" "Vim" "jq" "yq" "Golang" "VirtualBox" "Nerd Fonts" "Homebrew" "Git-Cola" "Node.js" "Postman" "Insomnia" "Ansible" "Azure CLI" "Google Cloud SDK" "Minikube" "Helm")
choices=$(gum choose --no-limit "${options[@]}")

# Convert the choices into an array
IFS=$'\n' read -r -d '' -a selected_choices <<< "$choices"
 
# Add latest stable PPAs and update
# setup_ppa "ppa:deadsnakes/ppa"

# Install selected tools
for choice in "${selected_choices[@]}"; do
    case $choice in
        "Browsers")
            install_apt_package firefox
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
            sudo apt-get update -qq
            install_apt_package google-chrome-stable
            ;;
        "Slack")
            sudo snap install slack --classic
            ;;
        "PyCharm")
            curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
            echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null
            sudo apt update -qq
            install_apt_package pycharm-community
            ;;
        "VSCode")
            sudo snap install code --classic
            ;;
        "Tilix Terminal")
            install_apt_package tilix
            ;;
        "Docker")
            install_apt_package docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        "Kitty")
            install_apt_package kitty
            ;;
        "Git")
            install_apt_package git
            ;;
        "CodeCommit")
            install_brew_package git-remote-codecommit
            ;;
        "wget")
            install_apt_package wget
            ;;
        "curl")
            install_apt_package curl
            ;;
        "Python3, pip, venv")
            install_apt_package python3
            install_apt_package python3-pip
            install_apt_package python3-venv
            ;;
        "Zsh")
            install_apt_package zsh
            chsh -s $(which zsh)
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
            ;;
        "Starship")
            install_brew_package starship
            ;;
        "AWS CLI")
            install_brew_package awscli
            ;;
        "Terraform CLI")
            install_brew_package terraform
            ;;
        "kubectl")
            install_brew_package kubectl
            echo 'source <(kubectl completion zsh)' >>~/.zshrc
            ;;
        "fzf")
            install_apt_package fzf
            ;;
        "Vim")
            install_apt_package vim
            mkdir -p ~/.vim/pack/plugins/start
            git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/plugins/start/nerdtree
            git clone https://github.com/vim-scripts/python.vim.git ~/.vim/pack/plugins/start/python
            git clone https://github.com/chase/vim-ansible-yaml.git ~/.vim/pack/plugins/start/vim-ansible-yaml
            git clone https://github.com/vim-scripts/bash-support.vim.git ~/.vim/pack/plugins/start/bash-support
            ;;
        "jq")
            install_apt_package jq
            ;;
        "yq")
            install_brew_package yq
            ;;
        "Golang")
            install_brew_package go
            ;;
        "VirtualBox")
            install_apt_package virtualbox
            ;;
        "Nerd Fonts")
            brew install font-fira-code
            ;;
        "Git-Cola")
            setup_ppa "ppa:git-core/ppa"
            install_apt_package git-cola
            ;;
        "Node.js")
            install_brew_package node
            ;;
        "Postman")
            brew install postman
            ;;
        "Insomnia")
            brew install insomnia
            ;;
        "Ansible")
            install_brew_package ansible
            ;;
        "Azure CLI")
            install_brew_package azure-cli
            ;;
        "Google Cloud SDK")
            install_brew_package google-cloud-sdk
            ;;
        "Minikube")
            install_brew_package minikube
            ;;
        "Helm")
            install_brew_package helm
            ;;
    esac
done

# Setup Zsh and Starship
if [[ " ${selected_choices[@]} " =~ "Zsh" ]]; then
    fancy_log "Setting up Zsh and Starship..."
    mkdir -p ~/.zsh
    cp .zsh/aliases.zsh ~/.zsh/
    cp .zsh/env.zsh ~/.zsh/
    cp .zsh/functions.zsh ~/.zsh/
    cp .zsh/starship.zsh ~/.zsh/
    mkdir -p ~/.config
    cp .zsh/starship.toml ~/.config/starship.toml
    cp .zshrc ~/
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# Setup git global user profile
if [[ " ${selected_choices[@]} " =~ "Git" ]]; then
    fancy_log "Setting up Git global user profile..."
    git config --global user.name "$(gum input --placeholder 'Enter your git username')"
    git config --global user.email "$(gum input --placeholder 'Enter your git email')"
fi

# Final system update
fancy_log "Final system update..."
sudo apt-get update && sudo apt-get upgrade -y
sudo systemctl daemon-reload
# Final setup
fancy_log "Setup complete. Please restart your terminal or source your .zshrc file to apply changes."
