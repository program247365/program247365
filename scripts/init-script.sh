#!/bin/bash

# GitHub Profile README Project Initializer
# This script creates all necessary files for your self-updating GitHub profile

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art Header
echo -e "${BLUE}"
cat << "EOF"
   ______ _ _   _    _       _       _____             __ _ _      
  / _____|_) | | |  | |     | |     |  __ \           / _(_) |     
 | |  __  _| |_| |__| |_   _| |__   | |__) |_ __ ___ | |_ _| | ___ 
 | | |_ || | __|  __  | | | | '_ \  |  ___/| '__/ _ \|  _| | |/ _ \
 | |__| || | |_| |  | | |_| | |_) | | |    | | | (_) | | | | |  __/
  \_____|_|_\__|_|  |_|\__,_|_.__/  |_|    |_|  \___/|_| |_|_|\___|
                                                                    
EOF
echo -e "${NC}"

echo -e "${GREEN}🚀 Initializing GitHub Profile README Project${NC}\n"

# Check if we're in the right directory
read -p "Initialize in current directory $(pwd)? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Initialization cancelled${NC}"
    exit 1
fi

# Create directory structure
echo -e "${GREEN}📁 Creating directory structure...${NC}"
mkdir -p .github/workflows

# Create .gitignore
echo -e "${GREEN}📝 Creating .gitignore...${NC}"
cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
.env
.venv
venv/
.DS_Store
*.backup.*.md
blog_posts.json
language_distribution.png
weekly-digest.md
EOF

# Create requirements.txt
echo -e "${GREEN}📦 Creating requirements.txt...${NC}"
cat > requirements.txt << 'EOF'
requests==2.31.0
feedparser==6.0.10
python-dateutil==2.8.2
PyGithub==2.1.1
matplotlib==3.7.1
seaborn==0.12.2
EOF

# Create GitHub Action workflow
echo -e "${GREEN}🔧 Creating GitHub Action workflow...${NC}"
cat > .github/workflows/update-readme.yml << 'EOF'
name: Update README

on:
  schedule:
    # Runs every 6 hours
    - cron: '0 */6 * * *'
  workflow_dispatch:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Update README
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SPOTIFY_CLIENT_ID: ${{ secrets.SPOTIFY_CLIENT_ID }}  # Optional
        SPOTIFY_CLIENT_SECRET: ${{ secrets.SPOTIFY_CLIENT_SECRET }}  # Optional
      run: python build_readme.py
    
    - name: Commit and push if changed
      run: |
        git config --global user.email "action@github.com"
        git config --global user.name "GitHub Action"
        git add README.md
        git diff --quiet && git diff --staged --quiet || (git commit -m "Update README with latest content" && git push)
EOF

# Create build_readme.py
echo -e "${GREEN}🐍 Creating build_readme.py...${NC}"
cat > build_readme.py << 'EOF'
import os
import re
import json
import requests
import feedparser
from datetime import datetime, timedelta
from dateutil import parser
from github import Github
import random

# Initialize
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
g = Github(GITHUB_TOKEN)
user = g.get_user()

# Optional API keys
SPOTIFY_CLIENT_ID = os.environ.get("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.environ.get("SPOTIFY_CLIENT_SECRET")

def get_latest_releases(num=5):
    """Get latest releases from your repositories"""
    releases = []
    
    for repo in user.get_repos():
        if repo.private:
            continue
            
        try:
            latest_release = repo.get_latest_release()
            if latest_release:
                releases.append({
                    'name': repo.name,
                    'url': latest_release.html_url,
                    'description': latest_release.title or latest_release.tag_name,
                    'created_at': latest_release.created_at
                })
        except:
            pass
    
    # Sort by date and get latest
    releases.sort(key=lambda x: x['created_at'], reverse=True)
    return releases[:num]

def get_latest_commits(num=5):
    """Get latest commits from public repositories"""
    commits = []
    
    for repo in user.get_repos():
        if repo.private:
            continue
            
        try:
            repo_commits = repo.get_commits()
            for commit in repo_commits[:1]:  # Just latest from each repo
                commits.append({
                    'repo': repo.name,
                    'message': commit.commit.message.split('\n')[0],
                    'url': commit.html_url,
                    'date': commit.commit.author.date
                })
        except:
            pass
    
    commits.sort(key=lambda x: x['date'], reverse=True)
    return commits[:num]

def get_blog_posts(feed_url='https://kbr.sh/rss/', num=5):
    """Fetch latest blog posts from RSS feed"""
    try:
        feed = feedparser.parse(feed_url)
        posts = []
        
        for entry in feed.entries[:num]:
            posts.append({
                'title': entry.title,
                'url': entry.link,
                'date': parser.parse(entry.published).strftime('%b %d, %Y')
            })
        
        return posts
    except:
        return []

def get_github_stats():
    """Get GitHub statistics"""
    stats = {
        'public_repos': user.public_repos,
        'followers': user.followers,
        'following': user.following,
        'public_gists': user.public_gists
    }
    
    # Calculate total stars
    total_stars = sum(repo.stargazers_count for repo in user.get_repos() if not repo.private)
    stats['total_stars'] = total_stars
    
    # Get language stats
    languages = {}
    for repo in user.get_repos():
        if repo.private:
            continue
        
        repo_languages = repo.get_languages()
        for lang, bytes_count in repo_languages.items():
            languages[lang] = languages.get(lang, 0) + bytes_count
    
    # Get top 5 languages
    top_languages = sorted(languages.items(), key=lambda x: x[1], reverse=True)[:5]
    stats['top_languages'] = [lang[0] for lang in top_languages]
    
    # Calculate contribution stats
    stats['total_commits'] = sum(repo.get_commits().totalCount for repo in user.get_repos() if not repo.private)
    
    return stats

def get_featured_projects():
    """Get featured projects with more details"""
    featured = []
    
    # Define featured repos
    featured_repos = ['hackertuah', 'tailwindcss-now', 'dotfiles', 'random-quotes']
    
    for repo_name in featured_repos:
        try:
            repo = user.get_repo(repo_name)
            featured.append({
                'name': repo.name,
                'description': repo.description,
                'stars': repo.stargazers_count,
                'forks': repo.forks_count,
                'language': repo.language,
                'url': repo.html_url
            })
        except:
            pass
    
    return featured



def get_coding_stats():
    """Generate coding activity stats"""
    # This would integrate with WakaTime or similar service
    # For now, return mock data based on recent commits
    
    now = datetime.now()
    week_ago = now - timedelta(days=7)
    
    weekly_commits = 0
    for repo in user.get_repos():
        if repo.private:
            continue
        try:
            commits = repo.get_commits(since=week_ago)
            weekly_commits += sum(1 for _ in commits)
        except:
            pass
    
    return {
        'weekly_commits': weekly_commits,
        'daily_average': round(weekly_commits / 7, 1)
    }

def get_random_greeting():
    """Get a random greeting based on time of day"""
    hour = datetime.now().hour
    
    if 5 <= hour < 12:
        greetings = ["Good morning!", "Rise and shine!", "Morning, fellow developer!"]
    elif 12 <= hour < 17:
        greetings = ["Good afternoon!", "Hope you're having a great day!", "Afternoon vibes!"]
    elif 17 <= hour < 22:
        greetings = ["Good evening!", "Evening, coder!", "Hope you had a productive day!"]
    else:
        greetings = ["Hello, night owl!", "Burning the midnight oil?", "Late night coding session?"]
    
    return random.choice(greetings)

def format_featured_projects(projects):
    """Format featured projects as a grid"""
    if not projects:
        return ""
    
    markdown = '<p align="center">\n'
    
    for i, project in enumerate(projects):
        if i % 2 == 0 and i > 0:
            markdown += '</p>\n<p align="center">\n'
        
        markdown += f'''  <a href="{project['url']}">
    <img src="https://github-readme-stats.vercel.app/api/pin/?username=program247365&repo={project['name']}&theme=tokyonight" alt="{project['name']}" />
  </a>\n'''
    
    markdown += '</p>\n'
    return markdown

def replace_content(content, marker, replacement):
    """Replace content between markers"""
    pattern = f"<!-- {marker} starts -->.*<!-- {marker} ends -->"
    replacement_content = f"<!-- {marker} starts -->\n{replacement}\n<!-- {marker} ends -->"
    return re.sub(pattern, replacement_content, content, flags=re.DOTALL)

def main():
    # Read template
    with open('README_TEMPLATE.md', 'r') as f:
        readme = f.read()
    
    # Get data
    releases = get_latest_releases()
    commits = get_latest_commits()
    blog_posts = get_blog_posts()

    stats = get_github_stats()
    featured = get_featured_projects()
    coding_stats = get_coding_stats()
    greeting = get_random_greeting()
    
    # Format releases
    releases_md = ""
    if releases:
        for release in releases:
            releases_md += f"- 🚀 [{release['name']}]({release['url']}) - {release['description']}\n"
    else:
        releases_md = "- 🔜 No recent releases\n"
    
    # Format commits
    commits_md = ""
    for commit in commits[:5]:
        commit_date = commit['date'].strftime('%b %d')
        commits_md += f"- 💻 [{commit['repo']}]({commit['url']}) - {commit['message']} ({commit_date})\n"
    
    # Format blog posts
    blog_md = ""
    if blog_posts:
        blog_posts.sort(key=lambda x: parser.parse(x['date']), reverse=True)
        
        for post in blog_posts[:5]:
            blog_md += f"- 📝 [{post['title']}]({post['url']}) - {post['date']}\n"
    
    # Format stats
    stats_md = f"""
<p align="center">
  <img src="https://github-readme-stats.vercel.app/api?username=program247365&show_icons=true&theme=tokyonight&hide_border=true" alt="GitHub Stats" />
</p>

<p align="center">
  <img src="https://github-readme-streak-stats.herokuapp.com/?user=program247365&theme=tokyonight&hide_border=true" alt="GitHub Streak" />
</p>

<details>
<summary>📊 More Stats</summary>
<br>

- **Total Stars Earned:** {stats['total_stars']} ⭐
- **Total Commits (Public):** {stats['total_commits']} 
- **Followers:** {stats['followers']} 
- **Following:** {stats['following']}
- **Public Repositories:** {stats['public_repos']}
- **Public Gists:** {stats['public_gists']}
- **Top Languages:** {', '.join(stats['top_languages'][:3])}

</details>

### 📈 This Week's Coding Stats
- **Commits:** {coding_stats['weekly_commits']} total ({coding_stats['daily_average']} per day)
- **Most Active Language:** {stats['top_languages'][0] if stats['top_languages'] else 'N/A'}
"""
    
    # Format featured projects
    featured_md = format_featured_projects(featured)
    
    # Update README sections
    readme = replace_content(readme, "greeting", greeting)
    readme = replace_content(readme, "recent_releases", releases_md)
    readme = replace_content(readme, "recent_commits", commits_md)
    readme = replace_content(readme, "recent_blog_posts", blog_md)
    readme = replace_content(readme, "github_stats", stats_md)
    readme = replace_content(readme, "featured_projects", featured_md)
    
    # Add last updated timestamp
    readme = replace_content(readme, "last_updated", 
                           f"*Last updated: {datetime.now().strftime('%B %d, %Y at %I:%M %p')} EST*")
    
    # Write updated README
    with open('README.md', 'w') as f:
        f.write(readme)
    
    print(f"✅ README updated successfully at {datetime.now()}")

if __name__ == "__main__":
    main()
EOF

# Create README_TEMPLATE.md
echo -e "${GREEN}📄 Creating README_TEMPLATE.md...${NC}"
cat > README_TEMPLATE.md << 'EOF'
# Hey there! I'm Kevin 👋 

<!-- greeting starts -->
Good morning!
<!-- greeting ends -->

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&duration=3000&pause=1000&color=58A6FF&center=true&vCenter=true&width=435&lines=Senior+Software+Engineer;Full+Stack+Developer;Open+Source+Enthusiast;Tech+Blogger" alt="Typing SVG" />
</div>

<p align="center">
  <a href="https://kbr.sh"><img src="https://img.shields.io/badge/Blog-kbr.sh-blue?style=for-the-badge&logo=hashnode" alt="Blog"></a>
  <a href="https://www.linkedin.com/in/kevinridgway"><img src="https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin" alt="LinkedIn"></a>
  <a href="mailto:kridgway@gmail.com"><img src="https://img.shields.io/badge/Email-Contact-D14836?style=for-the-badge&logo=gmail&logoColor=white" alt="Email"></a>
  <a href="https://twitter.com/program247365"><img src="https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white" alt="Twitter"></a>
</p>

## 👨‍💻 About Me

🚀 Senior Software Dev Engineer at **Yahoo!** working on the Media Tools Team - Home Ecosystem

🏡 Based in Buffalo, NY

💡 Building scalable web applications, contributing to open source, and exploring the intersection of AI and development

🦀 Rust enthusiast - check out my CLI tools like [hackertuah](https://github.com/program247365/hackertuah) (Hacker News CLI)

✍️ I write about tech, coding practices, and personal projects on [my blog](https://kbr.sh)

## 🛠️ Tech Stack

<p align="center">
  <img src="https://skillicons.dev/icons?i=react,nextjs,typescript,rust,python,aws,docker,kubernetes&theme=dark" />
</p>

<details>
<summary>🔧 More Technologies & Tools</summary>
<br>

**Frontend:** React, Next.js, Vue.js, TypeScript, TailwindCSS, Storybook

**Backend:** Node.js, Python (FastAPI), Java (Spring), Rust, Go

**Cloud & DevOps:** AWS (Lambda, Glue, S3, ECS), Terraform, Docker, Kubernetes, GitHub Actions

**Databases:** PostgreSQL, MySQL, MongoDB, Redis

**Currently Exploring:** AI/LLMs integration, Web3 technologies

</details>

## 📊 GitHub Stats

<!-- github_stats starts -->
Loading stats...
<!-- github_stats ends -->

## 🎯 Current Focus

- 🔭 Working on data pipelines and content management systems at Yahoo!
- 🌱 Deep diving into AI integration and prompt engineering
- 👯 Looking to collaborate on Rust projects and developer tools
- 💬 Ask me about React performance optimization, AWS architecture, or building developer tools

## 🚀 Featured Projects

<!-- featured_projects starts -->
Loading projects...
<!-- featured_projects ends -->

## 📝 Latest Blog Posts

<!-- recent_blog_posts starts -->
Loading blog posts...
<!-- recent_blog_posts ends -->

## 🚀 Recent Activity

### 🏗️ Latest Releases
<!-- recent_releases starts -->
Loading releases...
<!-- recent_releases ends -->

### 💻 Recent Commits
<!-- recent_commits starts -->
Loading commits...
<!-- recent_commits ends -->

## 🎵 What I'm Vibing To

<p align="center">
  <img src="https://spotify-github-profile.vercel.app/api/view?uid=program247365&cover_image=true&theme=novatorem&bar_color=53b14f&bar_color_cover=false" alt="Spotify Now Playing" />
</p>

## 📈 Contribution Graph

<p align="center">
  <img src="https://github-readme-activity-graph.vercel.app/graph?username=program247365&theme=tokyo-night&hide_border=true" alt="Contribution Graph" />
</p>

## 🏆 GitHub Trophies

<p align="center">
  <img src="https://github-profile-trophy.vercel.app/?username=program247365&theme=tokyonight&no-frame=true&column=7" alt="GitHub Trophies" />
</p>

## 💼 Professional Experience Highlights

### Yahoo! - Senior Software Dev Engineer (2023 - Present)
- 🔧 Set up AWS Lambdas for LLM-based content autocategorization
- 🚀 Led React 18 upgrade for CMS, improving performance across 10+ engineers
- 📦 Created NPM package distribution process using Rollup.js
- 🎯 Built Python API endpoints with FastAPI framework

### Previous Roles
- **NFTco** - Senior Fullstack Engineer (Web3 startup)
- **ACV Auctions** - Senior Frontend Engineer (Performance optimization)
- **Nota** - Senior Fullstack Engineer (AWS infrastructure)

## 🏆 Achievements

- 🥉 **2021** - Third Place in ACV Auctions Hackathon
- 🥉 **2016** - Third Place in Synacor Hackathon  
- 🏅 **2013** - Engineering Award @ Synacor, Inc.

## 💡 Random Dev Quote

<p align="center">
  <img src="https://quotes-github-readme.vercel.app/api?type=horizontal&theme=tokyonight" alt="Random Dev Quote" />
</p>

---

<p align="center">
  <img src="https://komarev.com/ghpvc/?username=program247365&color=blueviolet&style=for-the-badge" alt="Profile Views" />
</p>

<p align="center">
  <i>⚡ Fun fact: I built an 8-bit spelling game for my daughter using retro-styled animations!</i>
</p>

<!-- last_updated starts -->
*Last updated: Loading...*
<!-- last_updated ends -->
EOF

# Create initial README.md
echo -e "${GREEN}📄 Creating initial README.md...${NC}"
cp README_TEMPLATE.md README.md

# Create dev.sh helper script
echo -e "${GREEN}🚀 Creating dev.sh helper script...${NC}"
cat > dev.sh << 'EOF'
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
pip install -r requirements.txt --quiet

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  Warning: GITHUB_TOKEN not set!"
    echo "   Set it with: export GITHUB_TOKEN='your_token_here'"
    exit 1
fi

# Run the build script
echo "🏗️  Building README..."
python build_readme.py

echo "✅ Done! Check your README.md"
EOF

# Create sync_blog.py
echo -e "${GREEN}📰 Creating sync_blog.py...${NC}"
cat > sync_blog.py << 'EOF'
import feedparser
import json
from datetime import datetime

def sync_blog_posts():
    """Sync blog posts and create a JSON cache"""
    
    sources = [
        {'name': 'Personal Blog', 'url': 'https://kbr.sh/index.xml'},
        # Add more RSS feeds here
    ]
    
    all_posts = []
    
    for source in sources:
        try:
            feed = feedparser.parse(source['url'])
            for entry in feed.entries[:10]:
                post = {
                    'title': entry.title,
                    'url': entry.link,
                    'date': entry.published,
                    'source': source['name'],
                    'summary': entry.get('summary', '')[:200] + '...'
                }
                all_posts.append(post)
        except Exception as e:
            print(f"Error fetching {source['name']}: {e}")
    
    # Sort by date
    all_posts.sort(key=lambda x: x['date'], reverse=True)
    
    # Save to JSON
    with open('blog_posts.json', 'w') as f:
        json.dump(all_posts, f, indent=2)
    
    print(f"✅ Synced {len(all_posts)} blog posts")

if __name__ == "__main__":
    sync_blog_posts()
EOF

# Create Docker files
echo -e "${GREEN}🐳 Creating Docker files...${NC}"

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1

CMD ["python", "build_readme.py"]
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  github-profile-readme:
    build: .
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - SPOTIFY_CLIENT_ID=${SPOTIFY_CLIENT_ID:-}
      - SPOTIFY_CLIENT_SECRET=${SPOTIFY_CLIENT_SECRET:-}
    volumes:
      - ./README.md:/app/README.md
      - ./README_TEMPLATE.md:/app/README_TEMPLATE.md
    command: python build_readme.py
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
venv/
.venv/
__pycache__/
*.pyc
*.pyo
*.pyd
.git/
.github/
.gitignore
README.md
*.backup.*.md
.env
.env.local
.DS_Store
Makefile
init.sh
dev.sh
docker-compose.yml
Dockerfile
.dockerignore
EOF

# Create Makefile
echo -e "${GREEN}🔨 Creating Makefile...${NC}"
# Note: Using printf to preserve tabs in Makefile
printf '%s\n' '# GitHub Profile README Makefile
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
	@echo '"'"'${YELLOW}GitHub Profile README Makefile${NC}'"'"'
	@echo '"'"''"'"'
	@echo '"'"'Usage:'"'"'
	@echo '"'"'  ${GREEN}make${NC} ${YELLOW}<target>${NC}'"'"'
	@echo '"'"''"'"'
	@echo '"'"'Targets:'"'"'
	@awk '"'"'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${GREEN}%-15s${NC} %s\n", $$1, $$2}'"'"' $(MAKEFILE_LIST)

.PHONY: init
init: ## Initialize the project (create venv, install deps)
	@echo "${GREEN}Creating virtual environment...${NC}"
	@$(PYTHON) -m venv $(VENV)
	@echo "${GREEN}Activating virtual environment and installing dependencies...${NC}"
	@. $(VENV)/bin/activate && $(PIP) install --upgrade pip
	@. $(VENV)/bin/activate && $(PIP) install -r requirements.txt
	@echo "${GREEN}✅ Project initialized! Run '"'"'make activate'"'"' to activate the virtual environment${NC}"

.PHONY: update
update: check-token ## Update README with latest content
	@echo "${GREEN}Updating README...${NC}"
	@. $(VENV)/bin/activate && $(PYTHON) build_readme.py
	@echo "${GREEN}✅ README updated successfully!${NC}"

.PHONY: check-token
check-token: ## Check if GITHUB_TOKEN is set
	@if [ -z "$$GITHUB_TOKEN" ]; then \
		echo "${RED}❌ Error: GITHUB_TOKEN is not set${NC}"; \
		echo "${YELLOW}Set it with: export GITHUB_TOKEN='"'"'your_token_here'"'"'${NC}"; \
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

.DEFAULT_GOAL := help' > Makefile

# Make scripts executable
chmod +x dev.sh

# Git initialization (if not already a git repo)
if [ ! -d ".git" ]; then
    echo -e "${GREEN}🎯 Initializing git repository...${NC}"
    git init
    git branch -M main
fi

# Create .env.example
echo -e "${GREEN}🔐 Creating .env.example...${NC}"
cat > .env.example << 'EOF'
# Required
GITHUB_TOKEN=your_github_personal_access_token

# Optional
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
EOF

# Create PROJECT_README.md
echo -e "${GREEN}📚 Creating PROJECT_README.md...${NC}"
cat > PROJECT_README.md << 'EOF'
# 🚀 GitHub Profile README Generator

A self-updating GitHub profile README that automatically refreshes with your latest activity, blog posts, and statistics.

## ✨ Features

- **🔄 Auto-updating**: GitHub Actions refresh your profile every 6 hours
- **📊 Dynamic Stats**: Real-time GitHub statistics and contribution graphs
- **📝 Blog Integration**: Automatically pulls your latest blog posts from RSS
- **🎨 Beautiful Design**: Modern UI with animations and responsive layout
- **🛠️ Easy Customization**: Simple template system with marked sections
- **🐳 Docker Support**: Run locally or in CI/CD with Docker
- **📦 Makefile Commands**: Convenient commands for common tasks

## 🚀 Quick Start

1. **Get a GitHub Personal Access Token**
   - Go to [GitHub Settings → Tokens](https://github.com/settings/tokens)
   - Generate new token with `repo` and `user` scopes

2. **Set Environment Variable**
   ```bash
   export GITHUB_TOKEN='your_token_here'
   ```

3. **Initialize and Run**
   ```bash
   make init
   make update
   ```

## 🎯 Available Commands

```bash
make help        # Show all available commands
make init        # Initialize project
make update      # Update README with latest content
make preview     # Preview README in terminal
make stats       # Show your GitHub statistics
make docker      # Run in Docker container
```

## 📁 Files Created

- `README.md` - Your actual GitHub profile README
- `README_TEMPLATE.md` - Template with placeholder sections
- `build_readme.py` - Main script that generates content
- `.github/workflows/update-readme.yml` - GitHub Action for auto-updates
- `Makefile` - Convenience commands
- `requirements.txt` - Python dependencies

## 🎨 Customization

Edit `README_TEMPLATE.md` to customize your profile. Look for sections like:

```markdown
<!-- section_name starts -->
Content here will be auto-replaced
<!-- section_name ends -->
```

## 🚨 Troubleshooting

- **Token not set**: Run `export GITHUB_TOKEN='your_token'`
- **Permission errors**: Check repository Settings → Actions → General
- **Not updating**: Check Actions tab for error logs

---

Made with ❤️ for the developer community
EOF

# Create QUICK_START.md
echo -e "${GREEN}⚡ Creating QUICK_START.md...${NC}"
cat > QUICK_START.md << 'EOF'
# 🚀 Quick Start Guide

## One-Line Setup

```bash
curl -fsSL https://raw.githubusercontent.com/program247365/program247365/main/init.sh | bash
```

## Manual Setup (5 Steps)

### 1️⃣ Get GitHub Token
Visit: https://github.com/settings/tokens
- Click "Generate new token (classic)"
- Select scopes: `repo`, `user`
- Copy token

### 2️⃣ Set Token
```bash
export GITHUB_TOKEN='ghp_your_token_here'
```

### 3️⃣ Initialize
```bash
chmod +x init.sh
./init.sh
make init
```

### 4️⃣ Test
```bash
make update
# Check README.md was created
```

### 5️⃣ Deploy
1. Create repo: https://github.com/new
   - Name: `program247365` (your username)
   - Public, no README

2. Push:
```bash
git add .
git commit -m "Initial profile"
git remote add origin https://github.com/program247365/program247365.git
git push -u origin main
```

## 🎯 Daily Commands

```bash
make update      # Update README now
make preview     # Preview in terminal
make stats       # Show GitHub stats
make backup      # Backup current README
make help        # Show all commands
```

## ⚡ Tips

- **Auto-commit**: `make push`
- **Watch mode**: `make watch`
- **Check limits**: `make stats`

---

Need help? Check `PROJECT_README.md` for full documentation!
EOF

# Final setup instructions
echo -e "\n${GREEN}✅ Project initialized successfully!${NC}\n"
echo -e "${YELLOW}📋 Next Steps:${NC}\n"
echo -e "1. ${BLUE}Set up your GitHub token:${NC}"
echo -e "   export GITHUB_TOKEN='your_personal_access_token'"
echo -e "   ${YELLOW}Get one at: https://github.com/settings/tokens${NC}\n"
echo -e "2. ${BLUE}Install dependencies:${NC}"
echo -e "   make init\n"
echo -e "3. ${BLUE}Test the setup:${NC}"
echo -e "   make update\n"
echo -e "4. ${BLUE}Create your GitHub profile repository:${NC}"
echo -e "   - Go to https://github.com/new"
echo -e "   - Name it: program247365 (your username)"
echo -e "   - Make it public"
echo -e "   - Initialize with README\n"
echo -e "5. ${BLUE}Push to GitHub:${NC}"
echo -e "   git add ."
echo -e "   git commit -m 'Initial self-updating profile README'"
echo -e "   git remote add origin https://github.com/program247365/program247365.git"
echo -e "   git push -u origin main\n"
echo -e "${GREEN}📚 Documentation:${NC}"
echo -e "   - Quick start: QUICK_START.md"
echo -e "   - Full documentation: PROJECT_README.md"
echo -e "   - Quick help: make help\n"
echo -e "${GREEN}Available Make commands:${NC}"
echo -e "   make help     - Show all available commands"
echo -e "   make init     - Initialize the project"
echo -e "   make update   - Update README with latest content"
echo -e "   make clean    - Clean up generated files\n"
echo -e "${BLUE}Happy coding! 🚀${NC}"
EOF

chmod +x init.sh