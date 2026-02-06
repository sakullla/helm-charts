---
name: git-workflow
description: Git workflow automation and best practices. Use when working with Git operations including branching, committing, rebasing, merging, history rewriting, collaboration workflows, release management, or repository maintenance.
---

# Git Workflow

Comprehensive Git workflow guidance with automation scripts and best practices.

## Quick Commands

```bash
# Start feature branch
git checkout -b feature/description main

# Stage and commit with conventional message
git add -p
git commit -m "feat: add user authentication"

# Sync with main (rebase approach)
git fetch origin
git rebase origin/main

# Clean merged branches
python .claude/skills/git-workflow/scripts/clean_merged_branches.py
```

## Branching Strategy

### Feature Branch Workflow

```
main ──┬── feature/login ─────────────────┬── merge
       │                                    │
       └── feature/dashboard ───────────────┘
```

**Rules:**
- Branch from latest `main`: `git checkout -b feature/name main`
- Use prefix: `feature/`, `fix/`, `hotfix/`, `refactor/`, `docs/`
- Keep branches focused on single concern
- Delete after merge

### Commit Conventions

Format: `<type>(<scope>): <subject>`

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation changes |
| style | Formatting, semicolons, etc |
| refactor | Code restructuring |
| test | Adding tests |
| chore | Build/config changes |

Examples:
```bash
git commit -m "feat(auth): add OAuth2 login"
git commit -m "fix(api): handle null response"
git commit -m "docs(readme): update installation steps"
```

## History Management

### Interactive Rebase

**Use when:** cleaning up commits before PR

```bash
# Last N commits
git rebase -i HEAD~3

# Since branch point
git rebase -i main
```

**Common operations:**
- `pick` - keep commit
- `reword` - edit message
- `squash` - combine with previous
- `fixup` - combine, discard message
- `drop` - remove commit

### Safe Rewrite Rules

[OK] **Safe to rewrite:** Local commits not pushed
[OK] **Safe to rewrite:** Feature branch with force-push warning
[NO] **Never rewrite:** Shared/main branch commits

## Conflict Resolution

```bash
# During rebase/merge
git status                    # See conflicting files
# Edit files to resolve
git add <resolved-files>
git rebase --continue         # or git merge --continue

# Abort and restart
git rebase --abort
```

## Stash Workflow

```bash
# Quick stash
git stash push -m "WIP: login form"

# Stash with untracked files
git stash push -u -m "description"

# List and apply
git stash list
git stash pop stash@{0}
git stash apply stash@{0}     # Keep in stash
```

## Release Workflow

### Version Tagging

```bash
# Annotated tag
git tag -a v1.2.0 -m "Release version 1.2.0"

# Sign tag (if GPG configured)
git tag -s v1.2.0 -m "Release version 1.2.0"

git push origin v1.2.0
```

### Hotfix Process

```bash
# From main branch
git checkout -b hotfix/critical-bug main
# Fix and commit
git checkout main
git merge --no-ff hotfix/critical-bug
git tag -a v1.2.1 -m "Hotfix release"
git push origin main --tags
```

## Repository Maintenance

### Clean Merged Branches

```bash
# Dry run
python .claude/skills/git-workflow/scripts/clean_merged_branches.py --dry-run

# Actually delete
python .claude/skills/git-workflow/scripts/clean_merged_branches.py
```

### Check Repository Health

```bash
# Find large files
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print $3, $4}' | sort -rn | head -20

# Garbage collect
git gc --aggressive --prune=now
```

## Troubleshooting

### Undo Last Commit

```bash
# Keep changes
git reset --soft HEAD~1

# Discard changes
git reset --hard HEAD~1

# Amend without changing message
git commit --amend --no-edit
```

### Recover Lost Commits

```bash
git reflog
# Find commit hash
git checkout <hash>
git checkout -b recovery-branch
```

### Submodules

```bash
# Update all submodules
git submodule update --init --recursive

# Pull with submodules
git pull --recurse-submodules
```

## Reference

- **Detailed workflows:** See [references/workflows.md](references/workflows.md)
- **Advanced scenarios:** See [references/advanced.md](references/advanced.md)
