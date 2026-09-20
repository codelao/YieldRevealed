#!/usr/bin/env bash

set -eu

LINUX_INSTALL_DIR="$HOME/.local/share"
MACOS_INSTALL_DIR="$HOME/Applications"


banner() {                                              
    printf " __ __ _     _   _ _____                 _       _   \n"
    printf "|  |  |_|___| |_| | __  |___ _ _ ___ ___| |___ _| |  \n"
    printf "|_   _| | -_| | . |    -| -_| | | -_| .'| | -_| . |  \n"
    printf "  |_| |_|___|_|___|__|__|___|\_/|___|__,|_|___|___|  \n"
    printf "                     by CodeLao                      \n"
    printf "                  ~~~ Installer ~~~                  \n"  
}

error() {
    printf "\033[31m[ERROR]\033[0m %s\n" "$1" >&2
    exit 1
}

info() {
    printf "\033[33m[INFO]\033[0m %s\n" "$1"
}


OS="$(uname -s)"
case $OS in
    Darwin)
        INSTALL_DIR=$MACOS_INSTALL_DIR
        ;;

    Linux)
        INSTALL_DIR=$LINUX_INSTALL_DIR
        ;;

    *)
        error "Unsupported operating system: $OS"
        ;;
esac


banner


if ! command -v git >/dev/null 2>&1; then
    error "Git is not installed."
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null; then
    error "Node.js is not installed."
fi

if ! command -v python3 >/dev/null 2>&1; then
    error "Python 3 is not installed."
fi


if [ -e "$INSTALL_DIR/YieldRevealed" ]; then
    error "Installation directory already exists."
fi


info "Cloning project repository..."

git clone https://github.com/codelao/YieldRevealed.git $INSTALL_DIR


cd "$INSTALL_DIR/YieldRevealed"


info "Removing unnecessary files..."

rm -rf "setup"
rm -rf "tests"
rm -f "README.md"
rm -f ".gitignore"
rm -f "bin/YieldRevealed.cmd"


info "Creating Python virtual environment..."

python3 -m venv .venv
if [ ! -f ".venv/bin/python" ]; then
    error "Failed to create Python virtual environment."
fi


info "Installing Python dependencies..."

.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt


info "Installing Node.js dependencies..."

npm ci


info "Installing launcher..."

sudo install -m 755 "$INSTALL_DIR/YieldRevealed/bin/YieldRevealed.sh" /usr/local/bin/YieldRevealed


printf "\n\n\033[32mInstallation successful.\n"
printf "Application installed to: $INSTALL_DIR\n\n"
printf "To start the application, run \033[34mYieldRevealed\033[0m\n"


exit 0
