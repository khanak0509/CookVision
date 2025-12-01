# 🔒 SECURITY GUIDE - Food App

## ⚠️ CRITICAL: Files You Must NEVER Commit to GitHub

### 🔥 Firebase Configuration Files
These files contain your Firebase API keys and project credentials:

```
✅ ALREADY PROTECTED (in .gitignore):
├── lib/firebase_options.dart
├── android/app/google-services.json
├── ios/Runner/GoogleService-Info.plist
└── macos/Runner/GoogleService-Info.plist
```

### 🐍 Python Backend Files
```
✅ ALREADY PROTECTED:
├── __pycache__/
├── *.sqlite (including checkpoints.sqlite)
├── .env files
└── venv/ or env/
```

### 🔑 API Keys & Secrets
```
✅ ALREADY PROTECTED:
├── api_keys.dart
├── secrets.dart
├── *.keystore
├── *.jks
└── key.properties
```

---

## 🛠️ Security Tools Provided

### 1. `cleanup_sensitive_files.sh`
Removes already-tracked sensitive files from git.

**Usage:**
```bash
./cleanup_sensitive_files.sh
```

**What it does:**
- Scans for sensitive files in git
- Removes them from tracking (keeps local copies)
- Shows you next steps

### 2. `check_secrets.sh`
Pre-commit security scanner.

**Usage:**
```bash
./check_secrets.sh
```

**What it does:**
- Scans staged files for API keys
- Checks for sensitive file patterns
- Prevents accidental commits of secrets

---

## 📋 Quick Start Checklist

### ✅ Before Your First Push to GitHub:

1. **Remove tracked sensitive file:**
   ```bash
   ./cleanup_sensitive_files.sh
   ```

2. **Commit the security updates:**
   ```bash
   git add .gitignore
   git commit -m "🔒 Update .gitignore for security"
   ```

3. **Always check before committing:**
   ```bash
   ./check_secrets.sh
   git add <your-files>
   git commit -m "Your message"
   ```

---

## 🚨 Current Status

### Files Currently Tracked (NEEDS CLEANUP):
- ❌ `macos/Runner/GoogleService-Info.plist` - **Contains Firebase API keys**

### Files Protected (Not Tracked):
- ✅ `lib/firebase_options.dart`
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`
- ✅ All `.sqlite` files
- ✅ Python `__pycache__`
- ✅ `.env` files

---

## 🔧 Manual Cleanup Commands

If you prefer to do it manually:

```bash
# Remove the sensitive file from git
git rm --cached macos/Runner/GoogleService-Info.plist

# Commit the changes
git add .gitignore
git commit -m "🔒 Remove sensitive files from git"

# Push to GitHub
git push origin main
```

---

## 📖 Important Notes

### ⚠️ Files Are NOT Deleted!
When you run `git rm --cached`, files remain on your disk. They're just removed from git tracking.

### 💾 Keep Local Backups
These files are needed for your app to run:
- Keep them in your local project
- Don't delete them
- Just don't commit them to GitHub

### 🔄 Regenerating Config Files
If you accidentally lose these files:
1. **Firebase**: Re-download from Firebase Console
2. **Environment files**: Recreate manually or from backups

---

## 🎯 Best Practices

### DO:
✅ Run `./check_secrets.sh` before every commit  
✅ Keep `.gitignore` updated  
✅ Review files before staging  
✅ Use environment variables for secrets  

### DON'T:
❌ Commit API keys or passwords  
❌ Share `google-services.json` or `GoogleService-Info.plist`  
❌ Push `.env` files  
❌ Hardcode secrets in code  

---

## 🆘 Emergency: Secret Already Pushed?

If you accidentally pushed secrets to GitHub:

### 1. **Remove from git history:**
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch macos/Runner/GoogleService-Info.plist" \
  --prune-empty --tag-name-filter cat -- --all
```

### 2. **Force push:**
```bash
git push origin --force --all
```

### 3. **Rotate ALL secrets immediately:**
- Regenerate Firebase API keys
- Create new project if necessary
- Update all config files locally

---

## 📞 Need Help?

- Firebase Console: https://console.firebase.google.com
- GitHub Security: https://docs.github.com/en/code-security
- Git Secrets Tool: https://github.com/awslabs/git-secrets

---

**Last Updated:** December 1, 2025  
**Project:** CookVision Food App
