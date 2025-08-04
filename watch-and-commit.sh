#!/bin/bash

# File watcher script that automatically commits changes
# This script monitors file changes and runs auto-commit.sh

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[WATCHER]${NC} $1"
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

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    print_error "fswatch is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install fswatch
    else
        print_error "Homebrew is not installed. Please install fswatch manually:"
        print_error "brew install fswatch"
        exit 1
    fi
fi

print_status "Starting file watcher..."
print_status "Monitoring for changes in Swift files, JSON files, and other project files..."
print_status "Press Ctrl+C to stop watching"

# Monitor for changes and run auto-commit
fswatch -o . | while read f; do
    # Check if there are actual changes (not just file system events)
    if ! git diff-index --quiet HEAD --; then
        print_status "Changes detected! Running auto-commit..."
        ./auto-commit.sh
        print_status "Watching for more changes..."
    fi
done 