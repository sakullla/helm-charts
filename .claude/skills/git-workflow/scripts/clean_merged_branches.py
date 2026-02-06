#!/usr/bin/env python3
"""
Clean up local branches that have been merged into main/master.
Usage: python clean_merged_branches.py [--dry-run]
"""

import subprocess
import sys
import argparse


def run(cmd, check=True):
    """Run shell command and return output."""
    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True,
        check=check
    )
    return result.stdout.strip()


def get_main_branch():
    """Detect main branch name."""
    branches = run("git branch -r", check=False)
    if "origin/main" in branches:
        return "main"
    elif "origin/master" in branches:
        return "master"
    else:
        # Check local branches
        local = run("git branch", check=False)
        if "main" in local:
            return "main"
        return "master"


def get_merged_branches(main_branch):
    """Get list of merged local branches (excluding main, master, current)."""
    current = run("git branch --show-current")
    
    output = run(f"git branch --merged {main_branch}")
    
    branches = []
    for line in output.split("\n"):
        branch = line.strip().lstrip("* ")
        if branch and branch not in [main_branch, "main", "master", current]:
            branches.append(branch)
    
    return branches


def delete_branch(branch, dry_run=False):
    """Delete a branch locally."""
    if dry_run:
        print(f"  [DRY-RUN] Would delete: {branch}")
        return True
    
    try:
        run(f"git branch -d '{branch}'")
        print(f"  [OK] Deleted: {branch}")
        return True
    except subprocess.CalledProcessError:
        print(f"  [FAIL] Failed to delete: {branch}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Clean up local branches that have been merged into main/master"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be deleted without actually deleting"
    )
    args = parser.parse_args()
    
    # Check if in git repo
    try:
        run("git rev-parse --git-dir")
    except subprocess.CalledProcessError:
        print("Error: Not in a git repository")
        sys.exit(1)
    
    main_branch = get_main_branch()
    print(f"Main branch: {main_branch}")
    
    # Fetch latest
    print("Fetching latest changes...")
    run("git fetch --prune", check=False)
    
    branches = get_merged_branches(main_branch)
    
    if not branches:
        print("No merged branches to clean up.")
        return
    
    print(f"\nFound {len(branches)} merged branch(es):")
    for b in branches:
        print(f"  - {b}")
    
    print()
    if args.dry_run:
        print("Dry run mode - no changes made:")
    
    deleted = 0
    for branch in branches:
        if delete_branch(branch, args.dry_run):
            deleted += 1
    
    print(f"\n{'Would delete' if args.dry_run else 'Deleted'} {deleted} branch(es)")


if __name__ == "__main__":
    main()
