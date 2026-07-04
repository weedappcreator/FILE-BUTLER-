#!/bin/bash

set -e

echo "🚀 Installing file-butler dependencies..."
echo ""

# Create ~/bin directory
mkdir -p ~/bin

# ─────────────────────────────────
# Install F2 (batch rename)
# ─────────────────────────────────
echo "📦 Installing F2 (batch rename)..."
ARCH=$(uname -m)
F2_VERSION="v2.2.2"

if [ "$ARCH" = "arm64" ]; then
    F2_URL="https://github.com/ayoisaiah/f2/releases/download/${F2_VERSION}/f2_2.2.2_darwin_arm64.tar.gz"
else
    F2_URL="https://github.com/ayoisaiah/f2/releases/download/${F2_VERSION}/f2_2.2.2_darwin_amd64.tar.gz"
fi

curl -sL "$F2_URL" -o /tmp/f2.tar.gz
tar -xzf /tmp/f2.tar.gz -C /tmp
mv /tmp/f2 ~/bin/f2
chmod +x ~/bin/f2
echo "✅ F2 installed"

# ─────────────────────────────────
# Install RnR (regex rename)
# ─────────────────────────────────
echo "📦 Installing RnR (regex rename)..."
RNR_VERSION="v0.5.1"

if [ "$ARCH" = "arm64" ]; then
    RNR_URL="https://github.com/ismaelgv/rnr/releases/download/${RNR_VERSION}/rnr-${RNR_VERSION}-aarch64-apple-darwin.tar.gz"
else
    RNR_URL="https://github.com/ismaelgv/rnr/releases/download/${RNR_VERSION}/rnr-${RNR_VERSION}-x86_64-apple-darwin.tar.gz"
fi

curl -sL "$RNR_URL" -o /tmp/rnr.tar.gz
mkdir -p /tmp/rnr_extract
tar -xzf /tmp/rnr.tar.gz -C /tmp/rnr_extract
cp $(find /tmp/rnr_extract -type f -name "rnr" | head -1) ~/bin/rnr
chmod +x ~/bin/rnr
rm -rf /tmp/rnr_extract /tmp/rnr.tar.gz
echo "✅ RnR installed"

# ─────────────────────────────────
# Install Organize (rule-based)
# ─────────────────────────────────
echo "📦 Installing Organize (rule-based organization)..."
pip3 install --user organize-tool
echo "✅ Organize installed"

# ─────────────────────────────────
# Add ~/bin to PATH
# ─────────────────────────────────
SHELL_RC=""
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_RC"; then
        echo '' >> "$SHELL_RC"
        echo '# file-butler tools' >> "$SHELL_RC"
        echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
        echo "✅ Added ~/bin to PATH in $SHELL_RC"
    fi
fi

echo ""
echo "✅ All dependencies installed!"
echo ""
echo "Next steps:"
echo "1. Run: source ~/.zshrc  (or open a new terminal)"
echo "2. Edit config/projects.conf — add your project folders"
echo "3. Run: ./file-butler.sh --dry-run"
echo "4. Run: ./file-butler.sh --execute"
