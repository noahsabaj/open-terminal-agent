#!/bin/bash
# Terminal Agent - One-line installer
# curl -fsSL https://raw.githubusercontent.com/noahsabaj/terminal-agent/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "  ╭─────╮"
echo "  │ ◠ ◠ │   Terminal Agent Installer"
echo "  │  ▽  │"
echo "  ╰─────╯"
echo -e "${NC}"

# Check for podman
if ! command -v podman &> /dev/null; then
    echo -e "${RED}Error: Podman is required but not installed.${NC}"
    echo ""
    echo "Install Podman first:"
    echo "  Ubuntu/Debian: sudo apt install podman"
    echo "  Fedora:        sudo dnf install podman"
    echo "  Arch:          sudo pacman -S podman"
    echo "  macOS:         brew install podman"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Podman found"

# Create directories
INSTALL_DIR="$HOME/.terminal-agent"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

echo -e "${GREEN}✓${NC} Created directories"

# Download files from GitHub
REPO_URL="https://raw.githubusercontent.com/noahsabaj/terminal-agent/main"

echo -e "${YELLOW}↓${NC} Downloading agent.py..."
curl -fsSL "$REPO_URL/agent.py" -o "$INSTALL_DIR/agent.py"

echo -e "${YELLOW}↓${NC} Downloading Containerfile..."
curl -fsSL "$REPO_URL/Containerfile" -o "$INSTALL_DIR/Containerfile"

echo -e "${YELLOW}↓${NC} Downloading requirements.txt..."
curl -fsSL "$REPO_URL/requirements.txt" -o "$INSTALL_DIR/requirements.txt"

echo -e "${GREEN}✓${NC} Downloaded all files"

# Create the agent wrapper script
cat > "$BIN_DIR/agent" << 'WRAPPER'
#!/bin/bash
# Terminal Agent - Sandboxed in Podman (transparent to user)

set -e

IMAGE_NAME="terminal-agent"
AGENT_DIR="$HOME/.terminal-agent"

# Build image if it doesn't exist (first run only)
if ! podman image exists "$IMAGE_NAME" 2>/dev/null; then
    echo "Setting up Terminal Agent (first run only)..."
    podman build -t "$IMAGE_NAME" -f "$AGENT_DIR/Containerfile" "$AGENT_DIR" 2>&1 | while read line; do
        echo -ne "\r\033[K  $line"
    done
    echo -e "\r\033[K\033[32m✓\033[0m Container ready"
    echo ""
fi

# Run sandboxed
exec podman run --rm -it \
    -v "$(pwd):/workspace/project:Z" \
    --workdir /workspace/project \
    --tmpfs /tmp \
    --security-opt=no-new-privileges \
    --hostname terminal-agent \
    -e TERM="$TERM" \
    "$IMAGE_NAME" "$@"
WRAPPER

chmod +x "$BIN_DIR/agent"

echo -e "${GREEN}✓${NC} Installed agent command"

# Add to PATH if needed
SHELL_RC=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]] && ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# Terminal Agent' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo -e "${GREEN}✓${NC} Added to PATH in $SHELL_RC"
    NEED_SOURCE=true
else
    echo -e "${GREEN}✓${NC} PATH already configured"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""

# Check if we need to source or if it's already in PATH
if command -v agent &> /dev/null; then
    echo -e "Run ${CYAN}agent${NC} to start."
elif [[ "$NEED_SOURCE" == true ]]; then
    echo -e "Run ${CYAN}source $SHELL_RC${NC} then ${CYAN}agent${NC} to start."
    echo -e "  (or open a new terminal)"
else
    echo -e "Run ${CYAN}$BIN_DIR/agent${NC} to start."
    echo -e "  (or open a new terminal for PATH to update)"
fi

echo ""
echo -e "Options:"
echo -e "  ${CYAN}agent${NC}          Start normally"
echo -e "  ${CYAN}agent --yolo${NC}   Autonomous mode (no prompts)"
echo ""
