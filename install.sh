#!/bin/bash
# Terminal Agent - One-line installer
# curl -fsSL https://raw.githubusercontent.com/noahsabaj/open-terminal-agent/main/install.sh | bash

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

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

# Check for Python 3.10+
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is required but not installed.${NC}"
    echo ""
    echo "Install Python 3.10+ first:"
    echo "  Ubuntu/Debian: sudo apt install python3 python3-pip"
    echo "  Fedora:        sudo dnf install python3 python3-pip"
    echo "  Arch:          sudo pacman -S python python-pip"
    echo "  macOS:         brew install python3"
    echo ""
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [[ "$PYTHON_MAJOR" -lt 3 ]] || [[ "$PYTHON_MAJOR" -eq 3 && "$PYTHON_MINOR" -lt 10 ]]; then
    echo -e "${RED}Error: Python 3.10+ is required (found $PYTHON_VERSION)${NC}"
    echo ""
    echo "Please upgrade Python to version 3.10 or later."
    exit 1
fi

echo -e "${GREEN}✓${NC} Python $PYTHON_VERSION found"

# Check for pip
if ! command -v pip3 &> /dev/null && ! python3 -m pip --version &> /dev/null; then
    echo -e "${RED}Error: pip is required but not installed.${NC}"
    echo ""
    echo "Install pip:"
    echo "  Ubuntu/Debian: sudo apt install python3-pip"
    echo "  macOS:         python3 -m ensurepip"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} pip found"

# Check for ollama
if ! command -v ollama &> /dev/null; then
    if [[ "$OS" == "linux" ]]; then
        echo -e "${YELLOW}!${NC} Ollama not found - installing..."
        curl -fsSL https://ollama.com/install.sh | sh
        echo -e "${GREEN}✓${NC} Ollama installed"
    else
        echo -e "${RED}!${NC} Ollama not found"
        echo ""
        echo "  Download Ollama from: ${CYAN}https://ollama.com/download${NC}"
        echo "  Install it, then run this script again."
        echo ""
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} Ollama found"
fi

# Check if user needs to sign in to Ollama (for cloud models)
echo ""
echo -e "${YELLOW}!${NC} Terminal Agent uses cloud models (e.g., minimax-m2.1:cloud)"
echo -e "  If you haven't already, sign in to Ollama:"
echo ""
echo -e "  ${CYAN}ollama signin${NC}"
echo ""
read -p "Press Enter to continue (or Ctrl+C to sign in first)..."
echo ""

# Install terminal-agent via pip
echo -e "${YELLOW}↓${NC} Installing open-terminal-agent..."
pip3 install --user open-terminal-agent

echo -e "${GREEN}✓${NC} Installed terminal-agent"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
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
    fi
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""

# Check if we need to source or if it's already in PATH
if command -v terminal-agent &> /dev/null; then
    echo -e "Run ${CYAN}terminal-agent${NC} to start."
elif [[ "$NEED_SOURCE" == true ]]; then
    echo -e "Run ${CYAN}source $SHELL_RC${NC} then ${CYAN}terminal-agent${NC} to start."
    echo -e "  (or open a new terminal)"
else
    echo -e "Run ${CYAN}~/.local/bin/terminal-agent${NC} to start."
    echo -e "  (or open a new terminal for PATH to update)"
fi

echo ""
echo -e "Options:"
echo -e "  ${CYAN}terminal-agent${NC}                Start normally (prompts for permission)"
echo -e "  ${CYAN}terminal-agent --accept-edits${NC} Auto-approve file edits"
echo -e "  ${CYAN}terminal-agent --yolo${NC}         Full autonomous mode (no prompts)"
echo ""
