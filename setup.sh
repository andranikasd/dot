#!/bin/bash

# Function to install gum
install_gum() {
    if ! command -v gum &> /dev/null
    then
        echo "Installing gum..."
        mkdir -p ~/.local/bin
        wget -qO- https://github.com/charmbracelet/gum/releases/download/v0.8.0/gum_0.8.0_Linux_x86_64.tar.gz | tar xvz -C ~/.local/bin gum
        export PATH=$PATH:~/.local/bin
    fi
}

# Function to install a package via apt
install_apt_package() {
    if ! dpkg -s "$1" &> /dev/null
    then
        sudo apt-get install -y "$1"
    fi
}

# Function to install a package via curl and unzip
install_curl_unzip() {
    curl -sL "$1" -o "$2.zip"
    unzip -o "$2.zip" -d "$3"
    rm "$2.zip"
}

# Function to setup a PPA and update
setup_ppa() {
    sudo add-apt-repository "$1" -y
    sudo apt-get update
}

# Install gum
install_gum

# Prompt user for tools to install
options=("Browsers" "Slack" "PyCharm" "Sublime Text" "VSCode" "New Terminal" "Docker" "Git" "CodeCommit" "wget" "curl" "Python3, pip, venv" "Zsh" "Starship" "AWS CLI" "Terraform CLI" "kubectl" "fzf" "Vim" "jq" "yq" "Golang" "VirtualBox" "Nerd Fonts" "Homebrew" "Git-Cola")
choices=$(gum choose --no-limit "${options[@]}")

# Add latest stable PPAs and update
setup_ppa "ppa:deadsnakes/ppa"

# Install selected tools
for choice in $choices; do
    case $choice in
        "Browsers")
            install_apt_package firefox
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
            sudo apt-get update
            install_apt_package google-chrome-stable
            ;;
        "Slack")
            wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.20.0-amd64.deb
            sudo dpkg -i slack-desktop-*.deb
            sudo apt-get install -f -y
            ;;
        "PyCharm")
            setup_ppa "ppa:mmk2410/intellij-idea"
            install_apt_package intellij-idea-community
            ;;
        "Sublime Text")
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
            sudo apt-add-repository "deb https://download.sublimetext.com/ apt/stable/"
            sudo apt-get update
            install_apt_package sublime-text
            ;;
        "VSCode")
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            sudo apt-get update
            install_apt_package code
            code --install-extension ms-azuretools.vscode-docker
            code --install-extension aws-scripting-guy.cform
            code --install-extension amazonwebservices.aws-toolkit-vscode
            code --install-extension ms-python.python
            code --install-extension hashicorp.terraform
            ;;
        "New Terminal")
            install_apt_package tilix
            ;;
        "Docker")
            install_apt_package docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        "Git")
            install_apt_package git
            ;;
        "CodeCommit")
            install_apt_package git-remote-codecommit
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
            ;;
        "Starship")
            curl -fsSL https://starship.rs/install.sh | bash
            ;;
        "AWS CLI")
            install_curl_unzip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" "awscliv2" "."
            sudo ./aws/install
            ;;
        "Terraform CLI")
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
            sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
            sudo apt-get update && sudo apt-get install terraform
            ;;
        "kubectl")
            install_apt_package apt-transport-https
            curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
            echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
            sudo apt-get update
            install_apt_package kubectl
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
            setup_ppa "ppa:rmescandon/yq"
            install_apt_package yq
            ;;
        "Golang")
            wget https://dl.google.com/go/go1.17.6.linux-amd64.tar.gz
            sudo tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
            source ~/.zshrc
            ;;
        "VirtualBox")
            sudo apt-get update
            install_apt_package virtualbox
            ;;
        "Nerd Fonts")
            mkdir -p ~/.local/share/fonts
            wget -qO- https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip | bsdtar -xvf- -C ~/.local/share/fonts
            fc-cache -fv
            ;;
        "Homebrew")
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            ;;
        "Git-Cola")
            setup_ppa "ppa:git-core/ppa"
            install_apt_package git-cola
            ;;
    esac
done

# Setup Zsh and Starship
if [[ " ${choices[@]} " =~ "Zsh" ]]; then
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
if [[ " ${choices[@]} " =~ "Git" ]]; then
    git config --global user.name "$(gum input --placeholder 'Enter your git username')"
    git config --global user.email "$(gum input --placeholder 'Enter your git email')"
fi

# Prompt user for Slack login
if [[ " ${choices[@]} " =~ "Slack" ]]; then
    echo "Please log in to Slack using the GUI."
    slack &
fi

# Final system update
sudo apt-get update && sudo apt-get upgrade -y

# Final setup
echo "Setup complete. Please restart your terminal or source your .zshrc file to apply changes."