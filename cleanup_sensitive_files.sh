#!/bin/bash

# ================================================
# 🔒 SECURITY CLEANUP SCRIPT
# ================================================
# This script removes sensitive files from git history
# Run this BEFORE pushing to GitHub
# ================================================

echo "🔍 Checking for sensitive files in git..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a git repo
if [ ! -d .git ]; then
    echo "❌ Not in a git repository!"
    exit 1
fi

echo "📋 Currently tracked sensitive files:"
echo "================================================"

# List sensitive files that are tracked
SENSITIVE_FILES=(
    "macos/Runner/GoogleService-Info.plist"
    "ios/Runner/GoogleService-Info.plist"
    "android/app/google-services.json"
    "lib/firebase_options.dart"
    "firebase_options.dart"
    ".env"
    "*.keystore"
    "*.jks"
    "key.properties"
)

FOUND_FILES=()
for pattern in "${SENSITIVE_FILES[@]}"; do
    files=$(git ls-files | grep -E "$pattern" 2>/dev/null)
    if [ ! -z "$files" ]; then
        echo -e "${RED}⚠️  $files${NC}"
        FOUND_FILES+=("$files")
    fi
done

if [ ${#FOUND_FILES[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No sensitive files found in git!${NC}"
    exit 0
fi

echo ""
echo "================================================"
echo -e "${YELLOW}⚠️  WARNING: Sensitive files detected!${NC}"
echo "================================================"
echo ""
echo "These files contain API keys and should NOT be in git."
echo ""
read -p "Do you want to remove them from git? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🧹 Removing sensitive files from git..."
    
    # Remove each found file
    for file in "${FOUND_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  Removing: $file"
            git rm --cached "$file" 2>/dev/null || true
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Files removed from git tracking${NC}"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Commit the changes:"
    echo "     git add .gitignore"
    echo "     git commit -m '🔒 Remove sensitive files and update .gitignore'"
    echo ""
    echo "  2. Push to GitHub:"
    echo "     git push origin main"
    echo ""
    echo "  3. (IMPORTANT) Keep backup copies of these files locally!"
    echo "     They are needed for your app to work."
    echo ""
    echo "⚠️  NOTE: Files are still on disk (not deleted), just removed from git."
else
    echo ""
    echo "❌ Cancelled. No changes made."
    exit 1
fi
