#!/bin/sh

# Function to display a prompt before executing a command
prompt_execute() {
    echo "================================================================================"
    echo "Press ENTER to proceed with the next step."
    echo "================================================================================"
    read -r
    echo "================================================================================"
    echo "Executing: $@"
    echo "================================================================================"
    "$@"
}

# Function to execute a command with confirmation using Gum
execute_with_confirmation() {
    echo "================================================================================"
    echo "Do you want to execute the following command? (y/n)"
    echo "$@"
    echo "================================================================================"
    read -r choice
    if [ "$choice" = "y" ]; then
        echo "================================================================================"
        echo "Executing: $@"
        echo "================================================================================"
        "$@"
    else
        echo "================================================================================"
        echo "Skipping: $@"
        echo "================================================================================"
    fi
}

# Install gum
execute_with_confirmation sudo npm install -g @dillonkearns/gum

# Set up the command-line interface using gum
execute_with_confirmation gum setup

# Add latest stable PPAs for Ubuntu
execute_with_confirmation sudo add-apt-repository -y ppa:git-core/ppa
execute_with_confirmation sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
execute_with_confirmation sudo add-apt-repository -y ppa:ansible/ansible

# Update and upgrade the system
execute_with_confirmation sudo apt update && sudo apt upgrade -y

# Install required packages
execute_with_confirmation sudo apt install -y curl git zsh jq peco exa apt-transport-https ca-certificates software-properties-common zip unzip tar bzip2 wget

# Download Nerd Fonts
execute_with_confirmation mkdir -p ~/.nerd-fonts
execute_with_confirmation wget -qO ~/.nerd-fonts/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
execute_with_confirmation unzip -q ~/.nerd-fonts/Hack.zip -d ~/.nerd-fonts

# Install Docker
execute_with_confirmation sudo apt-get remove docker docker-engine docker.io containerd runc
execute_with_confirmation sudo apt-get update
execute_with_confirmation sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
execute_with_confirmation curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
execute_with_confirmation echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
execute_with_confirmation sudo apt-get update
execute_with_confirmation sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
execute_with_confirmation sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
execute_with_confirmation sudo chmod +x /usr/local/bin/docker-compose
execute_with_confirmation sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Vagrant and VirtualBox
execute_with_confirmation sudo apt install -y vagrant virtualbox

# Install Homebrew
execute_with_confirmation /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
execute_with_confirmation eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Add Homebrew to PATH in .zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# Install other tools via Homebrew
execute_with_confirmation brew tap homebrew/cask-fonts
execute_with_confirmation brew install --cask font-hack-nerd-font
execute_with_confirmation brew install awscli terraform tfenv kubectx minikube helm krew derailed/k9s/k9s

# Install kubectl
execute_with_confirmation sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg
execute_with_confirmation curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
execute_with_confirmation echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
execute_with_confirmation sudo apt-get update
execute_with_confirmation sudo apt-get install -y kubectl

# Install Lens
execute_with_confirmation curl -fsSL https://dl.k8slens.dev/Lens-5.2.0.deb -o lens.deb
execute_with_confirmation sudo dpkg -i lens.deb
execute_with_confirmation rm lens.deb

# Install Helm
execute_with_confirmation curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Kustomize
execute_with_confirmation curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
execute_with_confirmation sudo mv kustomize /usr/local/bin/

# Install Oh My Zsh
execute_with_confirmation sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set up .zshrc
execute_with_confirmation cp ~/.zshrc ~/.zshrc.bak # Backup current .zshrc
cat <<EOT >> ~/.zshrc
# Custom Zsh configurations

# Add Homebrew to PATH
eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Load kubectx and kubens
source <(kubectl completion zsh)
alias k=kubectl
complete -F __start_kubectl k

# Other Aliases
alias ll='exa -lh --group-directories-first'
alias la='exa -lha --group-directories-first'

# Load tfenv
if [ -d "\$HOME/.tfenv" ]; then
  export PATH="\$HOME/.tfenv/bin:\$PATH"
fi
EOT

# Set up Starship prompt with custom config
mkdir -p ~/.config
cat <<'EOF' > ~/.config/starship.toml
# Inserts a blank line between shell prompts
add_newline = true

# Change the default prompt format
format = '''\
\$env_var\
\$all \$character'''

# Change the default prompt characters
[character]
success_symbol = "[](green)"
error_symbol = "[](red)"

# Shows an icon depending on what distro it is running on
[env_var.STARSHIP_DISTRO]
format = '[$env_value](bold white) '
variable = "STARSHIP_DISTRO"
disabled = false

# Shows an icon depending on what device it is running on
[env_var.STARSHIP_DEVICE]
format = '[$env_value](bold yellow)'
variable = "STARSHIP_DEVICE"
disabled = false

# ---

[aws]
format = ''
style = 'bold blue'
[aws.region_aliases]
ap-southeast-2 = 'au'
us-east-1 = 'va'

# Shows current directory
[directory]
truncation_length = 20
truncation_symbol = "…/"
home_symbol = " ~"
read_only_style = "197"
read_only = "  "
format = "[$path](\$style)[$read_only](\$read_only_style) "

# Shows current git branch
[git_branch]
symbol = " "
format = "[$symbol\$branch](\$style) "
# truncation_length = 4
truncation_symbol = "…/"
style = "bold green"

# Shows current git status
[git_status]
format = '[\(\$all_status\$ahead_behind\)](\$style) '
style = "bold green"
conflicted = "🏳"
up_to_date = ""
untracked = " "
ahead = "⇡\${count}"
diverged = "⇕⇡\${ahead_count}⇣\${behind_count}"
behind = "⇣\${count}"
stashed = " "
modified = " "
staged = '[++\(\$count\)](green)'
renamed = "襁 "
deleted = " "

# Shows kubernetes context and namespace
[kubernetes]
format = '[󱃾 \$context\(\$namespace\)](bold purple) '
disabled = false

# ---

# Disable some modules that aren't needed anymore
[username]
disabled = true

[vagrant]
disabled = true

[docker_context]
disabled = true

[helm]
disabled = false

[python]
disabled = true

[nodejs]
disabled = true

[ruby]
disabled = true

[terraform]
disabled = false
EOF

# Change default shell to zsh
execute_with_confirmation chsh -s $(which zsh)

# Install Chrome
execute_with_confirmation wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
execute_with_confirmation sudo dpkg -i google-chrome-stable_current_amd64.deb
execute_with_confirmation sudo apt --fix-broken install -y
execute_with_confirmation rm google-chrome-stable_current_amd64.deb

# Install Firefox
execute_with_confirmation sudo apt install -y firefox

# Install VS Code
execute_with_confirmation wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
execute_with_confirmation sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
execute_with_confirmation sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
execute_with_confirmation sudo apt update
execute_with_confirmation sudo apt install -y code
execute_with_confirmation rm packages.microsoft.gpg

# Install VS Code extensions
execute_with_confirmation code --install-extension ms-azuretools.vscode-docker
execute_with_confirmation code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
execute_with_confirmation code --install-extension hashicorp.terraform
execute_with_confirmation code --install-extension ms-python.python
execute_with_confirmation code --install-extension eamodio.gitlens
execute_with_confirmation code --install-extension esbenp.prettier-vscode

# Install Podman
. /etc/os-release
execute_with_confirmation sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_\$VERSION_ID/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
execute_with_confirmation wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_\$VERSION_ID/Release.key -O Release.key
execute_with_confirmation sudo apt-key add - < Release.key
execute_with_confirmation sudo apt update
execute_with_confirmation sudo apt -y install podman

# Reload zsh configuration
execute_with_confirmation source ~/.zshrc

# Apply Fira Code font with ligatures support to VS Code
execute_with_confirmation sed -i 's/"editor.fontFamily": ".*"/"editor.fontFamily": "Fira Code",/g' ~/.config/Code/User/settings.json
execute_with_confirmation sed -i 's/"editor.fontLigatures": .*/"editor.fontLigatures": true,/g' ~/.config/Code/User/settings.json

# Set VS Code theme
cat <<EOT >> ~/.config/Code/User/settings.json
"workbench.colorTheme": "Material Theme Palenight High Contrast",
"workbench.iconTheme": "material-icon-theme",
EOT

echo "Installation and setup complete. Please restart your terminal."
