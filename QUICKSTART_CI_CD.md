# 🚀 Quick Start: CI/CD Pipeline

## 📌 Document Metadata
* **Document Version**: 1.1.0
* **Date**: May 2026
* **Scope**: Automated Actions Deployment Quickstart

---

## ⚡ One-Time Repository Binding

Ensure your local repository is correctly mapped to your active GitHub account:

```bash
# 1. Verify existing remote bindings
git remote -v

# 2. If mapping is missing or incorrect, bind to the target URL:
git remote remove origin
git remote add origin https://github.com/ahad324/Serviq.git

# 3. Securely add your core CI/CD directories
git add .github/workflows/build-and-release.yml
git add CI_CD_SETUP.md QUICKSTART_CI_CD.md
git commit -m "ci: initialize high-fidelity github actions build and release workflow"
git push -u origin main
```

---

## 🔄 Automated Deployment Loop

Every subsequent push to the default branch will automatically trigger the compilation, testing, and release cycle:

```bash
# 1. Save and commit code modifications
git add .
git commit -m "feat: enhance real-time status trackers and location permission dialogs"

# 2. Transmit to GitHub default branch
git push origin main
```

---

## 📊 Pipeline Status Monitoring

* **Active Progress**: Navigate to **Actions** tab on your GitHub repository page to watch the runner execute lints, Android gradle builds, and web builds in real-time.
* **Success Verification**:
  * **Web Application (GitHub Pages)**: Automatically compiled and deployed within 1-2 minutes to:  
    👉 **[https://ahad324.github.io/Serviq/](https://ahad324.github.io/Serviq/)**
  * **Android APK (GitHub Releases)**: Automatically packaged and published to:  
    👉 **[https://github.com/ahad324/Serviq/releases](https://github.com/ahad324/Serviq/releases)**
* **Failed Statuses**: In case of a red status indicator, click the specific running action job inside the Actions tab to investigate console logs. Common fails are usually caused by incorrect package signatures or missing Supabase environment variables.
