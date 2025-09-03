#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GitHub repository details
REPO_URL="https://raw.githubusercontent.com/jwhutchison/docker-service/main/docker-service"
SCRIPT_NAME="docker-service"

echo "🚀 Docker Service Installer"
echo "=========================="
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}🛑 $1${NC}"
}

# Determine installation directory
determine_install_dir() {
    local install_dir=""

    # First choice: ~/.local/bin (XDG Base Directory standard)
    if [[ -d "$HOME/.local/bin" ]] || mkdir -p "$HOME/.local/bin" 2>/dev/null; then
        install_dir="$HOME/.local/bin"
    # Second choice: ~/bin (traditional Unix)
    elif [[ -d "$HOME/bin" ]] || mkdir -p "$HOME/bin" 2>/dev/null; then
        install_dir="$HOME/bin"
        print_warning "Using ~/bin instead of ~/.local/bin"
    else
        # Ask user for custom location
        echo "Unable to create ~/.local/bin or ~/bin directories."
        echo "Please specify a directory where you have write access:"
        read -p "Install directory: " -r custom_dir

        if [[ -z "$custom_dir" ]]; then
            print_error "No directory specified. Installation cancelled."
            exit 1
        fi

        # Expand tilde
        custom_dir="${custom_dir/#\~/$HOME}"

        if [[ ! -d "$custom_dir" ]] && ! mkdir -p "$custom_dir" 2>/dev/null; then
            print_error "Cannot create or access directory: $custom_dir"
            exit 1
        fi

        install_dir="$custom_dir"
        print_warning "Using custom directory: $install_dir"
    fi

    echo "$install_dir"
}

# Check if curl or wget is available
check_download_tool() {
    if command -v curl &> /dev/null; then
        echo "curl"
    elif command -v wget &> /dev/null; then
        echo "wget"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
}

# Download the script
download_script() {
    local url="$1"
    local output_file="$2"
    local tool="$3"

    echo "📥 Downloading $SCRIPT_NAME from GitHub..."

    if [[ "$tool" == "curl" ]]; then
        if ! curl -fsSL "$url" -o "$output_file"; then
            print_error "Failed to download script using curl"
            exit 1
        fi
    else
        if ! wget -q "$url" -O "$output_file"; then
            print_error "Failed to download script using wget"
            exit 1
        fi
    fi
}

# Main installation process
main() {
    # Determine installation directory
    INSTALL_DIR=$(determine_install_dir)
    SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

    echo "📍 Installation directory: $INSTALL_DIR"
    echo

    # Check for download tool
    DOWNLOAD_TOOL=$(check_download_tool)
    print_status "Using $DOWNLOAD_TOOL for download"

    # Download the script
    download_script "$REPO_URL" "$SCRIPT_PATH" "$DOWNLOAD_TOOL"
    print_status "Downloaded script to $SCRIPT_PATH"

    # Make executable
    chmod +x "$SCRIPT_PATH"
    print_status "Made script executable"

    # Check if directory is in PATH
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_status "Installation directory is already in PATH"
        echo
        echo "🎉 Installation complete! You can now use:"
        echo "   $SCRIPT_NAME"
    else
        print_warning "Installation directory is not in PATH"
        echo
        echo "To add it to your PATH, run:"
        echo "   $SCRIPT_PATH ensure-path"
        echo
        echo "Or manually add this line to your shell profile:"
        echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
        echo
        echo "For now, you can use the full path:"
        echo "   $SCRIPT_PATH"
    fi

    echo
    echo "📖 Get started with $SCRIPT_NAME help or see https://raw.githubusercontent.com/jwhutchison/docker-service"
}

# Run main function
main "$@"