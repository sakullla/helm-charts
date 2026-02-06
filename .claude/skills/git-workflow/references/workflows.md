# Git Workflows Reference

## Table of Contents
1. [Feature Branch Workflow](#feature-branch-workflow)
2. [GitFlow Workflow](#gitflow-workflow)
3. [Trunk-Based Development](#trunk-based-development)
4. [Forking Workflow](#forking-workflow)

---

## Feature Branch Workflow

Simple workflow for small teams and open source projects.

```
main ──┬── feature/A ───────┬── merge
       │                    │
       ├── feature/B ───────┤
       │                    │
       └── hotfix/X ────────┘
```

### Daily Workflow

```bash
# 1. Start new feature
git checkout main
git pull
git checkout -b feature/login-page

# 2. Work and commit
git add .
git commit -m "feat: add login form UI"

# 3. Push to remote
git push -u origin feature/login-page

# 4. Create PR via GitHub/GitLab UI

# 5. After merge, clean up
git checkout main
git pull
git branch -d feature/login-page
```

---

## GitFlow Workflow

Structured workflow for release management.

```
         tag v1.0                    tag v1.1
            │                          │
main ───────┼──────────────────────────┼─────────
            │                          │
       release/1.0               release/1.1
            │                          │
develop ────┬────┬─────────────────────┬────
            │    │                     │
       feature/A  feature/B       hotfix/X
```

### Branch Types

| Branch | Lifetime | From | Merge To |
|--------|----------|------|----------|
| main | Permanent | - | - |
| develop | Permanent | - | - |
| feature/* | Temporary | develop | develop |
| release/* | Temporary | develop | main+develop |
| hotfix/* | Temporary | main | main+develop |

### Commands

```bash
# Initialize (first time)
git checkout -b develop main

# Start feature
git checkout -b feature/auth develop

# Finish feature
git checkout develop
git merge --no-ff feature/auth
git branch -d feature/auth

# Start release
git checkout -b release/1.2 develop

# Finish release
git checkout main
git merge --no-ff release/1.2
git tag -a v1.2
git checkout develop
git merge --no-ff release/1.2
git branch -d release/1.2
```

---

## Trunk-Based Development

Short-lived branches merged to main frequently.

```
main ──┬── feature/A ─┬──┬── feature/B ─┬──
       │   (2 hrs)    │  │   (4 hrs)    │
       │              │  │              │
      v1.0           v1.1            v1.2
```

### Key Principles

1. **Single main branch** - No long-lived branches
2. **Short-lived branches** - < 1 day lifetime
3. **Feature flags** - Hide incomplete features
4. **Continuous integration** - Merge to main daily

### Workflow

```bash
# Morning - sync
git checkout main
git pull

# Create short branch
git checkout -b feature/tiny-change

# Work (few hours)
git add .
git commit -m "feat: add button"

# Push and PR immediately
git push -u origin feature/tiny-change
# Create PR → Review → Merge

# Clean up
git checkout main
git pull
git branch -d feature/tiny-change
```

---

## Forking Workflow

Used in open source with many contributors.

```
upstream/main ────┬── feature/A ─────┬── PR ─── merge
                  │                  │
origin/main ──────┴──────────────────┘
         (your fork)
```

### Setup

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOU/repo.git
cd repo

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL/repo.git

# Verify
git remote -v
# origin    https://github.com/YOU/repo.git (fetch)
# upstream  https://github.com/ORIGINAL/repo.git (fetch)
```

### Daily Workflow

```bash
# Sync with upstream
git checkout main
git fetch upstream
git rebase upstream/main

# Push to your fork
git push origin main

# Create feature branch
git checkout -b feature/awesome

# Work, commit, push
git add .
git commit -m "feat: add awesome feature"
git push -u origin feature/awesome

# Create PR from YOUR/fork to UPSTREAM/main via GitHub

# After PR merge, clean up
git checkout main
git pull upstream main
git push origin main
git branch -d feature/awesome
```

---

## Workflow Comparison

| Aspect | Feature Branch | GitFlow | Trunk-Based | Forking |
|--------|---------------|---------|-------------|---------|
| Team Size | Small-Medium | Medium-Large | Any | Open Source |
| Release Cycle | Any | Scheduled | Continuous | Any |
| Branch Complexity | Low | High | Very Low | Medium |
| CI/CD Friendly | Yes | Moderate | Yes | Yes |
| Best For | General use | Versioned products | DevOps teams | OSS projects |
