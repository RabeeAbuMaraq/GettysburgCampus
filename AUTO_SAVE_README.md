# Auto-Save and Commit System

This project now includes an automated save and commit system to ensure your changes are always backed up.

## 📁 Available Scripts

### 1. `auto-commit.sh` - Manual Auto-Commit
Run this script whenever you want to commit your current changes:
```bash
./auto-commit.sh
```

**Features:**
- Automatically detects changed files
- Creates timestamped commit messages
- Lists all changed files in the commit
- Pushes to remote repository if configured
- Colored output for easy reading

### 2. `watch-and-commit.sh` - Automatic File Watcher
This script monitors your project files and automatically commits changes:
```bash
./watch-and-commit.sh
```

**Features:**
- Monitors all project files for changes
- Automatically runs `auto-commit.sh` when changes are detected
- Requires `fswatch` (will install via Homebrew if needed)
- Press `Ctrl+C` to stop watching

### 3. `commit-now.sh` - Quick Commit
For immediate commits with custom messages:
```bash
./commit-now.sh "Your custom message here"
```

**Features:**
- Quick commit with optional custom message
- Automatic timestamping
- Immediate push to remote

## 🚀 Getting Started

### Option 1: Manual Commits (Recommended)
```bash
# After making changes, run:
./auto-commit.sh
```

### Option 2: Automatic Watching
```bash
# Start the file watcher (runs in background)
./watch-and-commit.sh

# The script will automatically commit changes as you work
# Press Ctrl+C to stop watching
```

### Option 3: Quick Commits
```bash
# Quick commit with default message
./commit-now.sh

# Quick commit with custom message
./commit-now.sh "Fixed events loading bug"
```

## 📋 What Gets Committed

The scripts automatically:
- ✅ Add all changed files to staging
- ✅ Create descriptive commit messages with timestamps
- ✅ List all changed files in the commit
- ✅ Push to remote repository (if configured)
- ✅ Handle git initialization for new projects

## 🔧 Requirements

- **Git**: Must be installed and configured
- **fswatch**: Required for `watch-and-commit.sh` (auto-installs via Homebrew)
- **Homebrew**: Required for installing fswatch (macOS)

## 🎯 Best Practices

1. **Use `auto-commit.sh`** for regular development workflow
2. **Use `watch-and-commit.sh`** when working on large features
3. **Use `commit-now.sh`** for quick fixes or when you need custom commit messages
4. **Review commits** before pushing to ensure quality

## 📝 Example Output

```
[AUTO-COMMIT] Changes detected in:
  - Views/EventsView.swift
  - Services/EventsService.swift
  - Utilities/Color+Hex.swift
[AUTO-COMMIT] Adding changes to staging area...
[AUTO-COMMIT] Committing changes...
[SUCCESS] Changes committed successfully at 2025-08-04 13:04:11
[AUTO-COMMIT] Commit hash: 3e72084
[SUCCESS] Changes pushed to remote repository
[SUCCESS] Auto-save and commit completed!
```

## 🛠️ Troubleshooting

### "fswatch not found"
```bash
# Install fswatch manually:
brew install fswatch
```

### "Not in a git repository"
The script will automatically initialize git and create the first commit.

### "Failed to push to remote"
This is normal if no remote repository is configured. The script will still commit locally.

## 🔄 Integration with Development

The auto-save system works seamlessly with your development workflow:

1. **Make changes** to your Swift files
2. **Run auto-commit** or let the watcher handle it
3. **Continue coding** knowing your changes are safe
4. **Review commits** in your git history

Your changes are now automatically saved and committed! 🎉 