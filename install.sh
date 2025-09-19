#!/usr/bin/env bash

set -e

# Function to install openssl based on package manager and show version
install_openssl() {
  if command -v apt >/dev/null 2>&1; then
    echo "Detected apt (Debian/Ubuntu)"
    apt update
    apt install -y openssl
    echo -n "openssl version: "
    openssl version
  elif command -v dnf >/dev/null 2>&1; then
    echo "Detected dnf (Fedora/RHEL)"
    dnf install -y openssl
    echo -n "openssl version: "
    openssl version
  elif command -v yum >/dev/null 2>&1; then
    echo "Detected yum (CentOS/Older RHEL)"
    yum install -y openssl
    echo -n "openssl version: "
    openssl version
  elif command -v zypper >/dev/null 2>&1; then
    echo "Detected zypper (openSUSE/SUSE)"
    zypper --non-interactive install openssl
    echo -n "openssl version: "
    openssl version
  elif command -v pacman >/dev/null 2>&1; then
    echo "Detected pacman (Arch/Manjaro)"
    pacman -Sy --noconfirm openssl
    echo -n "openssl version: "
    openssl version
  elif command -v apk >/dev/null 2>&1; then
    echo "Detected apk (Alpine)"
    apk add --no-cache openssl
    echo -n "openssl version: "
    openssl version
  elif command -v brew >/dev/null 2>&1; then
    echo "Detected brew (macOS/Homebrew/Linuxbrew)"
    brew install openssl
    echo -n "openssl version: "
    openssl version
  else
    echo "Unsupported package manager. Please install openssl manually."
    exit 2
  fi
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This installer must be run as root (try: sudo bash install.sh)"
  exit 1
fi

# Install openssl if not present
if ! command -v openssl >/dev/null 2>&1; then
  echo "OpenSSL not found. Installing..."
  install_openssl
else
  echo -n "OpenSSL is already installed: "
  openssl version
fi

# Find the directory of this script (assumes likrura.sh is in same dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/likrura.sh" ]]; then
  echo "likrura.sh not found in $SCRIPT_DIR"
  exit 3
fi

cp "$SCRIPT_DIR/likrura.sh" /usr/local/bin/likrura
chmod +x /usr/local/bin/likrura

echo "likrura installed! Now you can use the 'likrura' command anywhere."
