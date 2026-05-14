# 🚀 Quick Start CI/CD

## One-Time Setup

```bash
# 1. Make sure repo is on GitHub
git remote -v  # Should show GitHub URL

# 2. If not, add it:
git remote add origin https://github.com/ahad324/serviq.git

# 3. Push the workflow files:
git add .github/
git add CI_CD_SETUP.md
git commit -m "feat: add CI/CD with GitHub Actions"
git push origin main
```

## After Each Change

```bash
# Standard push (will auto-build)
git add .
git commit -m "your message"
git push origin main
```

## Download Your App

Visit: **https://github.com/ahad324y/serviq/releases**

---

## Status Check

- **Building?** → Go to **Actions** tab
- **Built?** → Go to **Releases** tab
- **Issues?** → Check **Actions** tab for error logs
