#!/bin/bash

# Pre-Push Security Checklist for Food App
# Run this before pushing to GitHub

echo "🔐 SECURITY CHECK - Food App"
echo "=============================="
echo ""

# Check for sensitive files
echo "1️⃣ Checking for sensitive files in Git..."
SENSITIVE_FILES=$(git ls-files | grep -E "(cookvision.*\.json|\.env$|firebase-adminsdk.*\.json)" | grep -v "\.example$" | grep -v "\.template$")

if [ -n "$SENSITIVE_FILES" ]; then
    echo "❌ ERROR: Found sensitive files tracked by Git:"
    echo "$SENSITIVE_FILES"
    echo ""
    echo "Run this to remove them:"
    echo "  git rm --cached <filename>"
    exit 1
else
    echo "✅ No sensitive files found in Git"
fi

echo ""

# Check .gitignore
echo "2️⃣ Checking .gitignore..."
if grep -q "cookvision.*firebase-adminsdk.*\.json" .gitignore; then
    echo "✅ Firebase credentials are ignored"
else
    echo "⚠️  Warning: Firebase credentials might not be properly ignored"
fi

if grep -q "\.env" .gitignore; then
    echo "✅ .env files are ignored"
else
    echo "❌ ERROR: .env not in .gitignore!"
    exit 1
fi

echo ""

# Check for API keys in code
echo "3️⃣ Scanning for hardcoded API keys..."
API_KEY_FOUND=$(git diff --cached | grep -iE "(api.*key.*=|gemini_api_key|openweather.*key)" | grep -v ".gitignore" | grep -v "your_api_key_here" | grep -v "example" | grep -v "template")

if [ -n "$API_KEY_FOUND" ]; then
    echo "❌ ERROR: Possible API keys found in staged changes!"
    echo "$API_KEY_FOUND"
    echo ""
    echo "Use environment variables instead!"
    exit 1
else
    echo "✅ No hardcoded API keys detected"
fi

echo ""

# Check staged files
echo "4️⃣ Checking staged files..."
STAGED=$(git diff --cached --name-only)
if [ -z "$STAGED" ]; then
    echo "⚠️  No files staged for commit"
else
    echo "Files to be committed:"
    git diff --cached --name-only | sed 's/^/  ✓ /'
fi

echo ""

# Final checklist
echo "📝 Manual Checklist:"
echo "  [ ] Tested on simulator/device"
echo "  [ ] Backend running on localhost:8000"
echo "  [ ] All API endpoints working"
echo "  [ ] No console errors in Flutter"
echo "  [ ] README updated with changes"
echo ""

echo "✅ SECURITY CHECK PASSED"
echo ""
echo "Ready to push? Run:"
echo "  git push origin main"
