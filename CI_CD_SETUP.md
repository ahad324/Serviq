# 🚀 CI/CD Setup Guide for Serviq

## ✅ What's Been Set Up

A GitHub Actions workflow that automatically:
1. **Builds Android APK** on every push to `main` branch
2. **Builds Web version** on every push to `main` branch
3. **Creates GitHub Releases** with the APK download
4. **Stores artifacts** for 30 days in workflow runs

---

## 📋 Prerequisites

### 1. Push Code to GitHub
Your repository must be on GitHub. If you haven't already:

```bash
git remote add origin https://github.com/ahad324/serviq.git
git branch -M main
git push -u origin main
```

### 2. Enable GitHub Actions
- Go to your repo on GitHub → **Settings** → **Actions** → **General**
- Ensure "Allow all actions and reusable workflows" is selected
- Save

### 3. Update `pubspec.yaml` (Important!)

Your current version is `0.1.0+1`. Update it to trigger releases:

```yaml
version: 0.1.0+1  # This format is: VERSION+BUILD_NUMBER
```

---

## 🔄 How It Works

### When You Push to Main:
```
git add .
git commit -m "your changes"
git push origin main
```

**The CI/CD pipeline will:**
1. ✅ Check out your code
2. ✅ Install Flutter dependencies
3. ✅ Build Android APK (release)
4. ✅ Build Web (release)
5. ✅ Create a GitHub Release with:
   - Download link for APK
   - Download link for Web artifacts
   - Build date, version, commit info

### Where to Find Your Built App:

**Option 1: GitHub Releases (Easiest for Users)**
- Navigate to: `https://github.com/ahad324/serviq/releases`
- Your APK will be there with each build
- Users can download directly

**Option 2: Workflow Artifacts**
- Go to **Actions** tab in GitHub
- Click the latest workflow run
- Scroll to bottom → **Artifacts**
- Download `android-apk` or `web-build`

---

## 🔐 Optional: Android Signing (For Signed APKs)

Currently, the APK is unsigned. If you want **signed APKs** for Google Play:

### Step 1: Create a keystore (do this locally first time only)
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Convert to base64
```bash
base64 -w 0 ~/key.jks > key.txt
```
Copy the output.

### Step 3: Add to GitHub Secrets
- Go to repo **Settings** → **Secrets and variables** → **Actions**
- Click **New repository secret**
- Name: `ANDROID_KEYSTORE`
- Value: Paste the base64 output
- Add another secret:
  - Name: `ANDROID_KEYSTORE_PASSWORD`
  - Value: Your keystore password

### Step 4: Update workflow for signing
Uncomment the signing section in `build-and-release.yml` (when you're ready)

---

## 📊 Workflow Status

Monitor your builds:
1. Push code to `main` branch
2. Go to GitHub repo → **Actions** tab
3. Watch the workflow run
4. After ~5-10 minutes, release is created automatically

---

## 🎯 Next Steps

1. **Commit and Push** this workflow file
2. **Update version** in pubspec.yaml when you want releases
3. **Push to main** to trigger the pipeline
4. **Check Actions** tab to monitor build progress
5. **View Release** when complete

---

## ⚙️ Customization

### Change Build Triggers:
Edit `.github/workflows/build-and-release.yml`:
```yaml
on:
  push:
    branches: [ main, develop ]  # Add more branches
```

### Add More Platforms:
```yaml
- name: Build iOS
  run: flutter build ios --release
  
- name: Build Windows
  run: flutter build windows --release
```

### Customize Release Notes:
Edit the `body` section in the "Create Release" step

---

## 🆘 Troubleshooting

### Build fails with "Java not found"
- The workflow includes Java setup, but ensure Android SDK is properly configured locally first

### APK size too large
- Add obfuscation to `pubspec.yaml`:
```yaml
flutter build apk --release --obfuscate --split-debug-info=build/app/profile
```

### Release not created
- Check Actions tab for error logs
- Ensure you have write permissions to create releases
- Verify branch is `main` or `master`

---

## 📚 Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)
- [Github Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)

