# 🚀 CI/CD Setup Guide for Serviq

**Updated with Latest GitHub Actions (May 2026)**

## ✅ What's Been Set Up

A GitHub Actions workflow that automatically:
1. **Builds Android APK** on every push to `main` branch (with optimized compression)
2. **Builds Web version** on every push to `main` branch (balanced compression)
3. **Creates GitHub Releases** with the APK download
4. **Stores artifacts** for 30 days in workflow runs

---

## 🔄 How It Works

### When You Push to Main:
```bash
git add .
git commit -m "your changes"
git push origin main
```

**The CI/CD pipeline will automatically:**
1. ✅ Check out your code
2. ✅ Setup Java 17 for Android build
3. ✅ Install Flutter & dependencies
4. ✅ Build Android APK (release, optimized)
5. ✅ Build Web (release, with compression)
6. ✅ Create a GitHub Release with:
   - Download link for APK
   - Download link for Web artifacts
   - Build date, version, commit info

---

## 📦 Latest Actions Used (May 2026)

| Action | Version | Purpose | Status |
|--------|---------|---------|--------|
| `actions/checkout` | v4 | Check out your code | ✅ Current |
| `actions/setup-java` | v4 | Setup Java for Android build | ✅ Current |
| `subosito/flutter-action` | v2 | Setup Flutter environment | ✅ Current |
| `softprops/action-gh-release` | **v3** | Create GitHub releases | ✨ Updated |
| `actions/upload-artifact` | **v7** | Upload build artifacts | ✨ Updated |

**✨ = Recently updated from v1/v3 to latest**

---

## 🎯 Compression Optimization

Your workflow uses smart compression settings:

- **APK**: `compression-level: 0` → No compression (APK is already compressed, saves upload time)
- **Web**: `compression-level: 6` → Balanced compression (reduces file size for web assets)

This ensures **faster upload times** while maintaining good file sizes.

---

## 📥 Where to Find Your Built App

### Option 1: GitHub Releases (Easiest for Users)
- Navigate to: `https://github.com/YOUR_USERNAME/serviq/releases`
- Your APK will be there with each build
- Users can download directly ⬇️

### Option 2: Workflow Artifacts
- Go to **Actions** tab in GitHub
- Click the latest workflow run
- Scroll to bottom → **Artifacts**
- Download `android-apk` or `web-build` (available for 30 days)

---

## 🔐 Optional: Android Signing (For Google Play)

Currently, the APK is unsigned. For **signed APKs** on Google Play:

### Step 1: Create a keystore locally
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Encode to base64
```bash
base64 -w 0 ~/key.jks > key.txt
```

### Step 3: Add to GitHub Secrets
1. Go to repo **Settings** → **Secrets and variables** → **Actions**
2. Add secret `ANDROID_KEYSTORE` with base64 content
3. Add secret `ANDROID_KEYSTORE_PASSWORD` with your password

### Step 4: Update workflow (when ready)
Add signing configuration to the APK build step

---

## ✅ Pre-Flight Checklist

- [ ] Code pushed to GitHub
- [ ] GitHub Actions enabled in Settings
- [ ] `main` branch exists and is default
- [ ] `pubspec.yaml` has version number
- [ ] Workflow file exists at `.github/workflows/build-and-release.yml`
- [ ] Ready to test the CI/CD pipeline

---

## 🚀 First Build

1. Make a small change to your code
2. Commit and push to main:
   ```bash
   git add .
   git commit -m "feat: test CI/CD pipeline"
   git push origin main
   ```
3. Go to **Actions** tab in GitHub
4. Watch the build in real-time (~5-10 minutes)
5. Check **Releases** tab when complete

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Actions don't run | Enable Actions in Settings → Actions → General |
| "Invalid action input" | Update action versions to v4/v7/v3 (already done) |
| Build fails | Check Actions tab for detailed error logs |
| Release not created | Verify `main` branch, check permissions |
| APK too large | Add obfuscation: `--obfuscate --split-debug-info` |
| Slow uploads | Reduce `compression-level` on web artifacts |

---

## 📚 Resources

- [Flutter Build Docs](https://docs.flutter.dev/deployment)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)
- [Latest upload-artifact@v7](https://github.com/actions/upload-artifact)
- [Latest action-gh-release@v3](https://github.com/softprops/action-gh-release)
- [GitHub Releases Docs](https://docs.github.com/en/repositories/releasing-projects-on-github/)

---

## 📊 Monitor Your Builds

- **Real-time logs**: GitHub Actions tab
- **Build status**: Green checkmark = success ✅
- **Failed builds**: Red X with error details ❌
- **Release status**: Check Releases tab

---

## 🎯 Next Steps

1. ✅ Commit and push the workflow updates
2. ✅ Make a test commit to `main`
3. ✅ Watch the build in Actions tab
4. ✅ Download the APK from Releases
5. ✅ Share with users for testing

