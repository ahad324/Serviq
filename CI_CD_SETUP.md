# 🚀 CI/CD Pipeline Setup Guide for Serviq

## 📌 Document Metadata
* **Document Version**: 1.1.0
* **Date**: May 2026
* **Status**: Complete / Production-Ready
* **Automation Workflow**: [build-and-release.yml](./.github/workflows/build-and-release.yml)

---

## 🛠️ Automated CI/CD Actions Summary

Serviq integrates a highly optimized, modern GitHub Actions pipeline. On every code push to the `main` branch, the workflow runner automatically executes the following sequences:

1. **Strict Static Analysis**: Runs Dart static checkers and linter suites to ensure compliance with the repository's strict analysis options.
2. **Android Release Compilation**: Compiles the release-ready **Android APK** with optimized compression, bypassing overhead configurations.
3. **Web Release Compilation**: Builds the web package, injecting the correct case-sensitive base-href `/Serviq/`.
4. **Immediate Web Deployment (GitHub Pages)**: Deploys the built web artifacts directly to GitHub Pages, instantly updating live production code.
5. **Automatic GitHub Releases**: Packages and publishes the compiled Android APK inside a fresh GitHub Release tagged automatically with the `pubspec.yaml` version and commit SHA.
6. **Artifact Storage**: Caches and retains APK and web builds within the GitHub runner artifacts section for 30 days.

---

## 📦 Pipeline Actions & Node.js 24 Environment

To future-proof deployment pipelines against Node.js deprecations, the workflow centrally forces the use of **Node.js 24**:

```yaml
env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
```

The pipeline executes using the absolute latest, highly efficient GitHub Marketplace Actions:

| Action | Version | Primary Purpose | Node.js Support |
| :--- | :--- | :--- | :--- |
| `actions/checkout` | **v6** | Checks out repository code into the runner workspace. | ✅ Node.js 24 |
| `actions/setup-java` | **v5** | Sets up the Temurin Java 17 environment for Android Gradle builds. | ✅ Node.js 24 |
| `android-actions/setup-android` | **v3** | Installs and configures Android SDK and platform utilities. | ✅ Node.js 24 |
| `subosito/flutter-action` | **v2** | Downloads and caches the required Flutter environment. | ✅ Node.js 24 |
| `actions/configure-pages` | **v5** | Configures static asset structures for GitHub Pages. | ✅ Node.js 24 |
| `actions/upload-pages-artifact` | **v3** | Packages and uploads the web asset folder. | ✅ Node.js 24 |
| `actions/deploy-pages` | **v4** | Publishes the web package to the live GitHub Pages site. | ✅ Node.js 24 |
| `softprops/action-gh-release` | **v3** | Generates the release post and publishes the APK download. | ✅ Node.js 24 |
| `actions/upload-artifact` | **v7** | Backs up builds inside the actions workflow run directory. | ✅ Node.js 24 |

---

## 🎯 Compression & Performance Optimizations

The pipeline is optimized to reduce compile times and asset sizes:

* **Android APK**: Utilizes `compression-level: 0` (No compression). Since release APKs are already compiled and compressed via Gradle, this saves significant runner processor overhead during upload.
* **Web Build**: Utilizes `compression-level: 6` (Balanced compression). Compresses individual HTML, JS, CSS, and asset files to minimize loading times for web clients.

---

## 📥 Where to Download and Preview Your App

### 1. Instant Web App (GitHub Pages)
The web build is compiled and published automatically. Because GitHub Pages is case-sensitive, ensure the capitalization of the repo name `/Serviq/` matches exactly:  
👉 **[https://ahad324.github.io/Serviq/](https://ahad324.github.io/Serviq/)**

### 2. Android APK (GitHub Releases)
Every single push creates a new tag and release entry with the compiled `serviq.apk` attached directly in the Assets section:  
👉 **[https://github.com/ahad324/Serviq/releases](https://github.com/ahad324/Serviq/releases)**

### 3. Workflow Artifacts
During active runs, compiled files are cached under the Actions tab. Select the specific workflow run and scroll to the bottom to locate **android-apk** and **web-build** download options (valid for 30 days).

---

## 🔐 Production Android Keystore Signing Setup

Currently, the pipeline generates an unsigned debug/release APK. To compile a signed release APK suitable for publishing to the Google Play Console:

### Step 1: Generate Private Key Locally
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Encode to Base64 String
```bash
# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("~/key.jks")) > key_base64.txt

# macOS / Linux (Terminal)
base64 -w 0 ~/key.jks > key_base64.txt
```

### Step 3: Configure GitHub Secrets
Navigate to **Settings** ➔ **Secrets and variables** ➔ **Actions** in your GitHub repository and add:
1. `ANDROID_KEYSTORE`: Paste the encoded base64 string from `key_base64.txt`.
2. `ANDROID_KEYSTORE_PASSWORD`: Keystore passkey.
3. `ANDROID_KEY_ALIAS`: Alias name (e.g. `upload`).
4. `ANDROID_KEY_PASSWORD`: Key passkey.

---

## 🆘 Troubleshooting and Resolutions

| Issue | Technical Root Cause | Resolution Method |
| :--- | :--- | :--- |
| **Pages site displays 404** | Case sensitivity in repository naming paths. | Ensure URL uses `/Serviq/` with a capital **S** rather than `/serviq/`. |
| **Web App is blank on load** | Incorrect Base Href mapping. | Base Href in `flutter build web` must match the repository name exactly: `--base-href "/Serviq/"`. |
| **"Permission Denied" in Release** | GitHub token lacks repository write permissions. | Inside repo **Settings** ➔ **Actions** ➔ **General**, change Workflow Permissions to **Read and write permissions**. |
| **"Node.js 20 Deprecated"** | Outdated GitHub Marketplace Actions. | Already solved in Serviq pipeline. Uses `softprops/action-gh-release@v3` and `actions/checkout@v6`. |
| **Gradle compilation fails** | Java version mismatch. | Ensure `actions/setup-java` sets the Temurin distribution to Java version `17`. |
| **APK upload takes too long** | High runner compression overhead. | Set `compression-level: 0` for compiled APK uploads inside `upload-artifact` steps. |
