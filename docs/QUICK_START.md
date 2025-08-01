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
chmod +x scripts/init-script.sh
./scripts/init-script.sh
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

2. **Set up GitHub Action Secret** (Required for auto-updates):
   - Go to your repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `README_GITHUB_TOKEN`
   - Value: Your Personal Access Token from step 1
   - Click "Add secret"

3. Push:
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

Need help? Check `docs/PROJECT_README.md` for full documentation!
