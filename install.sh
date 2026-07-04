#!/bin/bash
# One-command installer for file-butler
# Usage: curl -fsSL https://raw.githubusercontent.com/weedappcreator/FILE-BUTLER-/main/install.sh | bash

set -e
echo "🚀 Installing file-butler..."

# Download file-butler to ~/bin
mkdir -p ~/bin
curl -fsSL "https://raw.githubusercontent.com/weedappcreator/FILE-BUTLER-/main/file-butler" -o ~/bin/file-butler
chmod +x ~/bin/file-butler

# Add to PATH
SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
if ! grep -q 'file-butler' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# file-butler' >> "$SHELL_RC"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
fi

export PATH="$HOME/bin:$PATH"

# Install F2 + RnR
file-butler --install

echo ""
echo "✅ file-butler installed! Run: file-butler"
