#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl git zsh jq peco exa apt-transport-https ca-certificates software-properties-common zip unzip tar bzip2 wget

# Download Nerd Fonts
mkdir -p ~/.nerd-fonts
wget -qO ~/.nerd-fonts/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
unzip -q ~/.nerd-fonts/Hack.zip -d ~/.nerd-fonts

# Install Docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Vagrant and VirtualBox
sudo apt install -y vagrant virtualbox

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Add Homebrew to PATH in .zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# Install other tools via Homebrew
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
brew install awscli terraform tfenv kubectx minikube helm krew derailed/k9s/k9s

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set up .zshrc
cp ~/.zshrc ~/.zshrc.bak # Backup current .zshrc
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

# Change default shell to zsh
chsh -s $(which zsh)

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt --fix-broken install -y
rm google-chrome-stable_current_amd64.deb

# Install Firefox
sudo apt install -y firefox

# Install VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code
rm packages.microsoft.gpg

# Install VS Code extensions
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension hashicorp.terraform
code --install-extension ms-python.python
code --install-extension eamodio.gitlens
code --install-extension esbenp.prettier-vscode

# Install Podman
. /etc/os-release
sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_\$VERSION_ID/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_\$VERSION_ID/Release.key -O Release.key
sudo apt-key add - < Release.key
sudo apt update
sudo apt -y install podman

# Reload zsh configuration
source ~/.zshrc

# Apply Fira Code font with ligatures support to VS Code
sed -i 's/"editor.fontFamily": ".*"/"editor.fontFamily": "Fira Code",/g' ~/.config/Code/User/settings.json
sed -i 's/"editor.fontLigatures": .*/"editor.fontLigatures": true,/g' ~/.config/Code/User/settings.json

# Set VS Code theme
cat <<EOT >> ~/.config/Code/User/settings.json
"workbench.colorTheme": "Material Theme Palenight High Contrast",
"workbench.iconTheme": "material-icon-theme",
EOT

echo "Installation and setup complete. Please restart your terminal."
