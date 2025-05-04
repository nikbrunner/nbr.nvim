#!/bin/bash

echo "Installing servers..."

# Check if `npm` is installed
if ! command -v "npm" &>/dev/null; then
    echo "Missing npm, installing..."

    # Check if MacOS or Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected MacOS, installing Homebrew..."
        # Install Homebrew
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Install Node.js
        echo "Installing Node.js..."
        brew install node
    fi

    # Check if Arch Linux
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "Detected Arch Linux, installing npm with pacman..."
        # Install Node.js
        echo "Installing Node.js..."
        sudo pacman -S nodejs
    fi
fi

function install_server() {
    local server=$1
    local package_name=$2

    if ! command -v "$server" &>/dev/null; then
        echo "Missing $server language server, installing..."
        npm install -g "$package_name"
    fi
}

# https://github.com/yioneko/vtsls/blob/main/packages/server/package.json
install_server "vtsls" "@vtsls/language-server"

# https://github.com/withastro/language-tools/blob/main/packages/language-server/package.json
install_server "astro-ls" "@astrojs/language-server"

# TODO: Migrate all other `ensure_installed` servers from config to this script
