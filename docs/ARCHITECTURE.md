# 🏗️ Project Architecture

## 📁 Directory Structure

```
program247365/
├── .github/                 # GitHub configuration
│   └── workflows/          # GitHub Actions workflows
│       └── update-readme.yml
├── config/                  # Configuration files
│   ├── .dockerignore       # Docker ignore patterns
│   └── requirements.txt    # Python dependencies
├── docs/                    # Project documentation
│   ├── ARCHITECTURE.md     # This file - project structure
│   ├── PROJECT_README.md   # Main project documentation
│   └── QUICK_START.md      # Quick start guide
├── scripts/                 # Utility scripts
│   ├── dev.sh              # Development helper script
│   ├── init-script.sh      # Project initialization script
│   └── sync_blog.py        # Blog synchronization utility
├── src/                     # Source code
│   └── build_readme.py     # Main README builder script
├── templates/               # Template files
│   └── README_TEMPLATE.md  # README template with placeholders
├── venv/                    # Python virtual environment (ignored)
├── .env.example            # Environment variables example
├── .gitignore              # Git ignore patterns
├── docker-compose.yml      # Docker Compose configuration
├── Dockerfile              # Docker container definition
├── Makefile                # Build automation commands
└── README.md               # Generated profile README
```

## 📋 File Descriptions

### Core Files
- **`README.md`** - The generated GitHub profile README (auto-updated)
- **`Makefile`** - Convenient commands for project management
- **`Dockerfile`** - Container definition for running the project
- **`docker-compose.yml`** - Multi-container Docker application

### Source Code (`src/`)
- **`build_readme.py`** - Main script that generates the README with progress tracking

### Templates (`templates/`)
- **`README_TEMPLATE.md`** - Template with placeholder sections that get replaced with dynamic content

### Scripts (`scripts/`)
- **`dev.sh`** - Development helper for local setup and execution
- **`init-script.sh`** - Complete project initialization script
- **`sync_blog.py`** - Utility for syncing blog posts from RSS feeds

### Configuration (`config/`)
- **`requirements.txt`** - Python package dependencies
- **`.dockerignore`** - Files to exclude from Docker builds

### Documentation (`docs/`)
- **`PROJECT_README.md`** - Comprehensive project documentation
- **`QUICK_START.md`** - Quick setup and usage guide
- **`ARCHITECTURE.md`** - This file describing project structure

### GitHub Integration (`.github/`)
- **`workflows/update-readme.yml`** - GitHub Action for automatic README updates

## 🔄 Data Flow

1. **Template Reading**: `build_readme.py` reads `templates/README_TEMPLATE.md`
2. **Data Fetching**: Script fetches data from GitHub API, RSS feeds, etc.
3. **Content Generation**: Dynamic content replaces placeholder sections
4. **Output**: Updated `README.md` is written to project root
5. **Automation**: GitHub Actions runs this process every 6 hours

## 🛠️ Build Process

The build process is orchestrated by `src/build_readme.py` with these steps:

1. **Template Loading** - Read the README template
2. **Data Collection** - Fetch GitHub stats, releases, commits
3. **External APIs** - Pull blog posts from RSS feeds
4. **Content Formatting** - Format all data into markdown sections
5. **Template Replacement** - Replace placeholder sections with dynamic content
6. **File Output** - Write the final README.md

## 🎯 Entry Points

- **Local Development**: `make update` or `scripts/dev.sh`
- **Docker**: `docker-compose up` or `docker build . && docker run`
- **CI/CD**: GitHub Actions runs `src/build_readme.py` automatically

## 📦 Dependencies

All Python dependencies are centralized in `config/requirements.txt`:
- `requests` - HTTP client for API calls
- `feedparser` - RSS feed parsing
- `python-dateutil` - Date parsing utilities
- `PyGithub` - GitHub API client

## 🔧 Configuration

Environment variables:
- `GITHUB_TOKEN` - Required for GitHub API access
- `SPOTIFY_CLIENT_ID/SECRET` - Optional for Spotify integration