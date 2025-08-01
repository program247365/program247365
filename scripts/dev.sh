#!/bin/bash
# dev.sh - Local development helper script

echo "🚀 GitHub Profile README Development Helper"
echo "=========================================="

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install/update dependencies
echo "📚 Installing dependencies..."
pip install -r config/requirements.txt --quiet

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  Warning: GITHUB_TOKEN not set!"
    echo "   Set it with: export GITHUB_TOKEN='your_token_here'"
    exit 1
fi

# Run the build script
echo "🏗️  Building README..."
python src/build_readme.py

echo "✅ Done! Check your README.md"
