# GitHub Profile README Makefile
# Usage: make [target]

# Variables
PYTHON := python3
PIP := pip3
VENV := venv
GITHUB_USERNAME := program247365

# Color output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

.PHONY: help
help: ## Show this help message
	@echo '${YELLOW}GitHub Profile README Makefile${NC}'
	@echo ''
	@echo 'Usage:'
	@echo '  ${GREEN}make${NC} ${YELLOW}<target>${NC}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${GREEN}%-15s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: init
init: ## Initialize the project (create venv, install deps)
	@echo "${GREEN}Creating virtual environment...${NC}"
	@$(PYTHON) -m venv $(VENV)
	@echo "${GREEN}Activating virtual environment and installing dependencies...${NC}"
	@. $(VENV)/bin/activate && $(PIP) install --upgrade pip
	@. $(VENV)/bin/activate && $(PIP) install -r config/requirements.txt
	@echo "${GREEN}✅ Project initialized! Run 'make activate' to activate the virtual environment${NC}"

.PHONY: update
update: check-token ## Update README with latest content
	@echo "${GREEN}Updating README...${NC}"
	@. $(VENV)/bin/activate && $(PYTHON) src/build_readme.py
	@echo "${GREEN}✅ README updated successfully!${NC}"

.PHONY: check-token
check-token: ## Check if GITHUB_TOKEN is set
	@if [ -z "$$GITHUB_TOKEN" ]; then \
		echo "${RED}❌ Error: GITHUB_TOKEN is not set${NC}"; \
		echo "${YELLOW}Set it with: export GITHUB_TOKEN='your_token_here'${NC}"; \
		exit 1; \
	else \
		echo "${GREEN}✅ GITHUB_TOKEN is set${NC}"; \
	fi

.PHONY: clean
clean: ## Clean up generated files and cache
	@echo "${GREEN}Cleaning up...${NC}"
	@rm -rf $(VENV)
	@rm -rf __pycache__
	@rm -rf *.pyc
	@echo "${GREEN}✅ Cleanup complete${NC}"

.DEFAULT_GOAL := help
