#!/bin/bash

# ================================================
# 🛡️ PRE-COMMIT SECURITY CHECK
# ================================================
# Run this before committing to check for secrets
# ================================================

echo "🔍 Scanning for potential secrets and API keys..."
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ISSUES_FOUND=0

# Check for staged files with potential secrets
echo "📂 Checking staged files..."

# Patterns to search for
DANGEROUS_PATTERNS=(
    "AIza[0-9A-Za-z-_]{35}"  # Google API keys
    "api[_-]?key['\"]?\s*[:=]\s*['\"][^'\"]{10,}['\"]"  # Generic API keys
    "secret['\"]?\s*[:=]\s*['\"][^'\"]{10,}['\"]"  # Secrets
    "password['\"]?\s*[:=]\s*['\"][^'\"]{10,}['\"]"  # Passwords
    "firebase[_-]?api[_-]?key"  # Firebase keys
    "[0-9]+-[0-9A-Za-z_]{32}\.apps\.googleusercontent\.com"  # OAuth Client IDs
)

STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${YELLOW}⚠️  No files staged for commit${NC}"
    exit 0
fi

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Skip binary files
        if file "$file" | grep -q "text"; then
            for pattern in "${DANGEROUS_PATTERNS[@]}"; do
                if grep -qE "$pattern" "$file" 2>/dev/null; then
                    echo -e "${RED}⚠️  DANGER: Potential secret found in: $file${NC}"
                    echo "   Pattern: $pattern"
                    ISSUES_FOUND=$((ISSUES_FOUND + 1))
                fi
            done
        fi
    fi
done

# Check for specific sensitive files
echo ""
echo "🔒 Checking for sensitive config files..."

SENSITIVE_FILENAMES=(
    "firebase_options.dart"
    "google-services.json"
    "GoogleService-Info.plist"
    ".env"
    "api_keys.dart"
    "secrets.dart"
)

for file in $STAGED_FILES; do
    basename=$(basename "$file")
    for sensitive in "${SENSITIVE_FILENAMES[@]}"; do
        if [ "$basename" = "$sensitive" ]; then
            echo -e "${RED}⚠️  DANGER: Sensitive file staged: $file${NC}"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done
done

echo ""
echo "================================================"

if [ $ISSUES_FOUND -gt 0 ]; then
    echo -e "${RED}❌ FOUND $ISSUES_FOUND POTENTIAL SECURITY ISSUE(S)!${NC}"
    echo ""
    echo "⚠️  DO NOT COMMIT!"
    echo ""
    echo "Actions to take:"
    echo "  1. Unstage sensitive files: git restore --staged <file>"
    echo "  2. Add them to .gitignore"
    echo "  3. Run this check again"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ No security issues found!${NC}"
    echo "Safe to commit."
    exit 0
fi
