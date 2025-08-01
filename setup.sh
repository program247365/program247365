#!/bin/bash

# GitHub Profile README Generator - Setup Script
# This script helps set up the project with the new organized structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GitHub Profile README Generator${NC}"
echo -e "${BLUE}=================================${NC}\n"

# Check if we're in the right directory by looking for key files
if [[ ! -f "Makefile" ]] || [[ ! -d "src" ]]; then
    echo -e "${RED}❌ Error: Please run this script from the project root directory${NC}"
    echo -e "${YELLOW}Expected files: Makefile, src/, templates/, etc.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project structure detected${NC}"

# Check for GitHub token
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo -e "${YELLOW}⚠️  GitHub token not set!${NC}"
    echo -e "${BLUE}Please set your GitHub token:${NC}"
    echo -e "   export GITHUB_TOKEN='your_token_here'"
    echo -e "   ${YELLOW}Get one at: https://github.com/settings/tokens${NC}\n"
    read -p "Do you want to continue without setting the token? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Setup cancelled. Set your token and try again.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ GitHub token is set${NC}"
fi

# Initialize the project
echo -e "${BLUE}📦 Initializing project...${NC}"
make init

# Test the setup
echo -e "${BLUE}🧪 Testing the setup...${NC}"
if [[ -n "$GITHUB_TOKEN" ]]; then
    echo -e "${GREEN}Running README update test...${NC}"
    make update
    if [[ -f "README.md" ]]; then
        echo -e "${GREEN}✅ README.md generated successfully!${NC}"
    else
        echo -e "${RED}❌ README.md was not generated${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏭️  Skipping README generation (no GitHub token)${NC}"
fi

# Show next steps
echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}\n"
echo -e "${BLUE}📋 Next Steps:${NC}"
echo -e "1. ${GREEN}View your generated README:${NC} cat README.md"
echo -e "2. ${GREEN}Customize your profile:${NC} edit templates/README_TEMPLATE.md"
echo -e "3. ${GREEN}Update README:${NC} make update"
echo -e "4. ${GREEN}View all commands:${NC} make help"
echo -e "5. ${GREEN}Read documentation:${NC} docs/PROJECT_README.md\n"

echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "   - Quick Start: ${YELLOW}docs/QUICK_START.md${NC}"
echo -e "   - Full Docs: ${YELLOW}docs/PROJECT_README.md${NC}"
echo -e "   - Architecture: ${YELLOW}docs/ARCHITECTURE.md${NC}\n"

echo -e "${GREEN}Happy coding! 🚀${NC}"