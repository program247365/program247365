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

## 📁 Project Structure

- `README.md` - Your actual GitHub profile README
- `src/build_readme.py` - Main script that generates content
- `templates/README_TEMPLATE.md` - Template with placeholder sections
- `scripts/` - Utility scripts (dev.sh, sync_blog.py, etc.)
- `config/` - Configuration files (requirements.txt, .dockerignore)
- `docs/` - Project documentation
- `.github/workflows/update-readme.yml` - GitHub Action for auto-updates
- `Makefile` - Convenience commands

See `docs/ARCHITECTURE.md` for detailed project structure.

## 🎨 Customization

Edit `templates/README_TEMPLATE.md` to customize your profile. Look for sections like:

```markdown
<!-- section_name starts -->
Content here will be auto-replaced
<!-- section_name ends -->
```

## 🚨 Troubleshooting

- **Token not set locally**: Run `export GITHUB_TOKEN='your_token'`
- **GitHub Actions not working**: Set up `README_GITHUB_TOKEN` secret in repository Settings → Secrets and variables → Actions
- **403 Permission errors**: The built-in `GITHUB_TOKEN` has limited permissions - use a Personal Access Token instead
- **Permission errors**: Check repository Settings → Actions → General
- **Not updating**: Check Actions tab for error logs

---

Made with ❤️ for the developer community
