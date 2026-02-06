# Advanced Git Scenarios

## Table of Contents
1. [Interactive Rebase Recipes](#interactive-rebase-recipes)
2. [Cherry-Picking](#cherry-picking)
3. [Bisect Debugging](#bisect-debugging)
4. [Patch Management](#patch-management)
5. [Worktrees](#worktrees)
6. [Reflog Recovery](#reflog-recovery)

---

## Interactive Rebase Recipes

### Combine Last N Commits

```bash
# Squash last 3 commits into 1
git rebase -i HEAD~3
# Change:
#   pick abc123 First commit
#   pick def456 Second commit
#   pick ghi789 Third commit
# To:
#   pick abc123 First commit
#   squash def456 Second commit
#   squash ghi789 Third commit
```

### Reorder Commits

```bash
git rebase -i HEAD~3
# Simply reorder lines:
#   pick def456 Second commit
#   pick abc123 First commit
#   pick ghi789 Third commit
```

### Split a Commit

```bash
# 1. Start rebase
git rebase -i HEAD~3
# Change 'pick' to 'edit' for the commit to split

# 2. At the commit, reset
git reset HEAD^

# 3. Stage and commit in parts
git add file1.cpp
git commit -m "feat: add feature part 1"
git add file2.cpp
git commit -m "feat: add feature part 2"

# 4. Continue rebase
git rebase --continue
```

### Fix an Old Commit Message

```bash
# Fix message from 3 commits ago
git rebase -i HEAD~3
# Change 'pick' to 'reword' for target commit
# Editor opens for new message
```

---

## Cherry-Picking

### Basic Cherry-Pick

```bash
# Apply specific commit to current branch
git cherry-pick abc123

# Cherry-pick without committing
git cherry-pick -n abc123

# Cherry-pick range
git cherry-pick abc123..def456
```

### Cherry-Pick with Conflict Resolution

```bash
git cherry-pick abc123
# Conflict!

# See what changed
git diff

# Resolve conflicts
git add .

# Continue
git cherry-pick --continue

# Or abort
git cherry-pick --abort
```

---

## Bisect Debugging

Find which commit introduced a bug.

```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark known good commit
git bisect good v1.0

# Git checks out middle commit
# Test and mark:
git bisect good   # or
git bisect bad

# Repeat until found...

# Finish and see result
git bisect reset
git bisect log
```

### Automated Bisect

```bash
# Create test script (exit 0 = good, non-zero = bad)
git bisect start
git bisect bad
git bisect good v1.0
git bisect run ./test.sh
```

---

## Patch Management

### Create Patches

```bash
# From last commit
git format-patch -1

# From range
git format-patch abc123..def456

# From specific commit
git format-patch -1 abc123

# As single file
git diff abc123..def456 > feature.patch
```

### Apply Patches

```bash
# Apply formatted patch
git am < 0001-commit-message.patch

# Apply diff patch
git apply feature.patch

# Check if applies cleanly (dry-run)
git apply --check feature.patch

# Apply with 3-way merge
git am -3 < patch.mbox
```

---

## Worktrees

Work on multiple branches simultaneously.

```bash
# Create worktree for feature branch
git worktree add ../project-feature feature-branch

# Create worktree from commit
git worktree add ../project-hotfix -b hotfix/main HEAD~5

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../project-feature

# Prune stale worktrees
git worktree prune
```

### Worktree Directory Layout

```
project/               # main worktree (main branch)
  ├── .git/
  ├── src/
  └── ...

project-feature/       # linked worktree (feature branch)
  ├── src/
  └── ...

project-hotfix/        # linked worktree (hotfix branch)
  ├── src/
  └── ...
```

---

## Reflog Recovery

### View Reflog

```bash
# All reference updates
git reflog

# Specific branch
git reflog show main

# Timeline format
git reflog --date=iso
```

### Recovery Scenarios

**Deleted branch:**
```bash
git reflog
# Find: abc123 HEAD@{5}: commit: last commit on deleted branch
git checkout -b recovered-branch abc123
```

**Reset --hard:**
```bash
# Oops! Lost commits
git reset --hard HEAD~3

# Recover
git reflog
# Find: def456 HEAD@{1}: commit: important work
git reset --hard def456
```

**Amended commit:**
```bash
# Oops! Lost original
git commit --amend

# Recover original
git reflog
# Find: ghi789 HEAD@{1}: commit: original message
git checkout -b recovery ghi789
```

---

## Partial Commits

### Stage Parts of a File

```bash
# Interactive staging
git add -p file.cpp

# Options:
#   y - stage this hunk
#   n - do not stage this hunk
#   s - split into smaller hunks
#   e - manually edit the hunk
#   ? - help

# Stage specific lines only
git add -e file.cpp
```

### Split Working Changes

```bash
# You have mixed changes in working directory
# Stage some for commit A
git add -p
git commit -m "feat: add validation"

# Stage rest for commit B
git add -p
git commit -m "refactor: extract helper"
```

---

## Signed Commits and Tags

### Setup GPG

```bash
# List keys
gpg --list-secret-keys --keyid-format=long

# Set signing key for git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

### Sign Commits

```bash
# Sign single commit
git commit -S -m "feat: add security"

# Auto-sign all commits (after config)
git commit -m "feat: add security"
```

### Sign Tags

```bash
# Annotated and signed
git tag -s v1.0 -m "Version 1.0"

# Verify signature
git tag -v v1.0
```

### Verify Commits

```bash
# Show signature
git log --show-signature -1

# List verified commits only
git log --pretty=short --show-signature
```

---

## Filter-Branch / Filter-Repo

### Remove File from History

```bash
# Using filter-branch (legacy)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch secret.txt' \
  HEAD

# Using filter-repo (modern, needs installation)
git filter-repo --path secret.txt --invert-paths
```

### Change Author Info

```bash
# Fix author email for all commits
git filter-branch --env-filter '
OLD_EMAIL="wrong@example.com"
CORRECT_EMAIL="right@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

⚠️ **Warning:** Rewriting history requires force-push. Coordinate with team!
