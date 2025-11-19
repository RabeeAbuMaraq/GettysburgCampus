#!/bin/bash

# Auto-save and commit script for Gettysburg Campus App
# This script will automatically commit changes with timestamps

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[AUTO-COMMIT]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Initializing git..."
    git init
    git add .
    git commit -m "Initial commit - $TIMESTAMP"
    print_success "Git repository initialized and first commit created"
    exit 0
fi

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    print_status "No changes to commit"
    exit 0
fi

# Get list of changed files
CHANGED_FILES=$(git diff --name-only)
print_status "Changes detected in:"
echo "$CHANGED_FILES" | while read file; do
    if [ ! -z "$file" ]; then
        echo "  - $file"
    fi
done

# Add all changes
print_status "Adding changes to staging area..."
git add .

# Create commit message with timestamp and file summary
COMMIT_MSG="Auto-save: $TIMESTAMP

Changed files:"
COMMIT_MSG+="\n$(echo "$CHANGED_FILES" | while read file; do
    if [ ! -z "$file" ]; then
        echo "  - $file"
    fi
done)"

# Commit changes
print_status "Committing changes..."
git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    print_success "Changes committed successfully at $TIMESTAMP"
    
    # Show commit hash
    COMMIT_HASH=$(git rev-parse --short HEAD)
    print_status "Commit hash: $COMMIT_HASH"
else
    print_error "Failed to commit changes"
    exit 1
fi

# Check if remote exists and push if needed
if git remote -v | grep -q origin; then
    print_status "Pushing to remote repository..."
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Changes pushed to remote repository"
    else
        print_warning "Failed to push to remote repository (this is normal if no remote is configured)"
    fi
else
    print_warning "No remote repository configured"
fi

print_success "Auto-save and commit completed!" 
