#!/usr/bin/env bash

set -eu

LINUX_INSTALL_DIR="$HOME/.local/share/YieldRevealed"
MACOS_INSTALL_DIR="$HOME/Applications/YieldRevealed"


error() {
    printf "\033[31m[ERROR]\033[0m %s\n" "$1" >&2
    exit 1
}

info() {
    printf "\033[33m[INFO]\033[0m %s\n" "$1"
}

success() {
    printf "\033[32m[SUCCESS]\033[0m Application uninstalled.\n"
    exit 0
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


info "Removing application folder..."

rm -rf "$INSTALL_DIR"


info "Removing launcher..."

sudo rm -f /usr/local/bin/YieldRevealed


success
