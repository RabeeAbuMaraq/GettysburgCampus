#!/bin/bash

# Quick commit script for immediate commits
# Usage: ./commit-now.sh [optional commit message]

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[QUICK COMMIT]${NC} Running immediate commit..."

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo -e "${BLUE}[QUICK COMMIT]${NC} No changes to commit"
    exit 0
fi

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Use provided message or default
if [ $# -eq 0 ]; then
    COMMIT_MSG="Quick commit: $TIMESTAMP"
else
    COMMIT_MSG="$1 - $TIMESTAMP"
fi

# Add and commit
git add .
git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} Committed: $COMMIT_MSG"
    
    # Try to push
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Pushed to remote"
    fi
else
    echo -e "${RED}[ERROR]${NC} Failed to commit"
    exit 1
fi 