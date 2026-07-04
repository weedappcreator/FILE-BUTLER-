#!/bin/bash

echo "🚀 Installing file-butler dependencies..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first:"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "📦 Installing F2 (batch rename)..."
brew install f2

echo "📦 Installing RnR (regex rename)..."
brew install rnr

echo "📦 Installing Organize (rule-based organization)..."
pip install organize

echo "✅ All dependencies installed!"
echo ""
echo "Next steps:"
echo "1. Edit config/file-types.conf - define your file categories"
echo "2. Edit config/projects.conf - define your project folders"
echo "3. Edit config/organize-rules.yaml - customize organization rules"
echo "4. Run: ./file-butler.sh --dry-run"
echo "5. Run: ./file-butler.sh --execute"
