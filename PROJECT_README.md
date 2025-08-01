# 🚀 GitHub Profile README Generator

> **⚠️ Note**: This is the project README. Your GitHub profile README is generated at `README.md`.

A self-updating GitHub profile README that automatically refreshes with your latest activity, blog posts, and GitHub statistics.

## ✨ Features

- **🔄 Auto-updating**: Refreshes every 6 hours via GitHub Actions
- **📊 Real-time Stats**: Dynamic GitHub statistics and contribution graphs  
- **📝 Blog Integration**: Automatically pulls latest blog posts from RSS feeds
- **🎨 Beautiful Design**: Modern UI with animations and responsive layout
- **🛠️ Easy Customization**: Template-based system with marked sections
- **🐳 Docker Support**: Run locally or in CI/CD environments
- **📦 Make Commands**: Convenient build automation

## 🚀 Quick Start

```bash
# 1. Set your GitHub token
export GITHUB_TOKEN='your_token_here'

# 2. Initialize project  
make init

# 3. Generate your README
make update
```

**→ See [docs/QUICK_START.md](docs/QUICK_START.md) for detailed setup instructions**

## 📁 Project Structure

```
program247365/
├── src/                    # Source code
├── templates/              # README template
├── scripts/                # Utility scripts  
├── config/                 # Configuration files
├── docs/                   # Documentation
├── .github/workflows/      # GitHub Actions
└── README.md              # 🎯 Your generated profile
```

**→ See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for complete structure details**

## 🎯 Available Commands

```bash
make help        # Show all available commands
make init        # Initialize project dependencies
make update      # Update README with latest content  
make clean       # Clean up generated files
```

## 📚 Documentation

- **[Quick Start Guide](docs/QUICK_START.md)** - Get up and running in 5 minutes
- **[Project Documentation](docs/PROJECT_README.md)** - Complete feature overview
- **[Architecture Guide](docs/ARCHITECTURE.md)** - Project structure and data flow

## 🎨 Customization

Edit `templates/README_TEMPLATE.md` to customize your profile:

```markdown
<!-- section_name starts -->
Content here will be auto-replaced
<!-- section_name ends -->
```

Available sections: `greeting`, `github_stats`, `featured_projects`, `recent_blog_posts`, `recent_releases`, `recent_commits`, `last_updated`

## 🔧 Configuration

Required environment variables:
- `GITHUB_TOKEN` - GitHub Personal Access Token ([get one here](https://github.com/settings/tokens))

Optional integrations:
- `SPOTIFY_CLIENT_ID/SECRET` - Spotify integration

## 🐳 Docker Support

```bash
# Using Docker Compose
docker-compose up

# Using Docker directly  
docker build -t github-readme .
docker run -e GITHUB_TOKEN='your_token' github-readme
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test: `make update`
4. Commit and push: `git commit -am 'Add feature'`
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

## 🎉 Acknowledgments

- GitHub API for repository data
- Various README stats services (github-readme-stats, etc.)
- GitHub Actions for automation

---

<p align="center">
  <i>Built with ❤️ for the developer community</i>
</p>