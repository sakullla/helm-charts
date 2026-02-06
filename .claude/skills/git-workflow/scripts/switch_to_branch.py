#!/usr/bin/env python3
"""
Smart branch switcher - create if not exists, or switch to existing.
Usage: python switch_to_branch.py <branch-name> [--from <base-branch>]
"""

import subprocess
import sys
import argparse


def run(cmd, check=True):
    """Run shell command."""
    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True,
        check=check
    )
    return result


def branch_exists(branch):
    """Check if branch exists locally or remotely."""
    # Check local
    result = run(f"git branch --list '{branch}'", check=False)
    if result.stdout.strip():
        return True
    
    # Check remote
    result = run(f"git branch -r --list 'origin/{branch}'", check=False)
    if result.stdout.strip():
        return True
    
    return False


def get_current_branch():
    """Get current branch name."""
    result = run("git branch --show-current")
    return result.stdout.strip()


def switch_or_create(branch, base_branch=None):
    """Switch to branch, creating if necessary."""
    current = get_current_branch()
    
    if current == branch:
        print(f"Already on branch: {branch}")
        return True
    
    if branch_exists(branch):
        # Switch to existing
        print(f"Switching to existing branch: {branch}")
        result = run(f"git checkout '{branch}'")
        if result.returncode != 0:
            print(f"Error: {result.stderr}")
            return False
        
        # Pull latest if tracking remote
        print("Pulling latest changes...")
        run("git pull", check=False)
    else:
        # Create new branch
        if not base_branch:
            # Detect main branch
            for main in ["main", "master"]:
                result = run(f"git rev-parse --verify {main}", check=False)
                if result.returncode == 0:
                    base_branch = main
                    break
        
        if not base_branch:
            print("Error: Cannot determine base branch")
            return False
        
        print(f"Creating new branch '{branch}' from '{base_branch}'")
        
        # Ensure base is up to date
        run(f"git fetch origin {base_branch}", check=False)
        
        result = run(f"git checkout -b '{branch}' {base_branch}")
        if result.returncode != 0:
            print(f"Error: {result.stderr}")
            return False
    
    print(f"[OK] Now on branch: {branch}")
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Smart branch switcher - create if not exists, or switch to existing"
    )
    parser.add_argument(
        "branch",
        help="Branch name to switch to"
    )
    parser.add_argument(
        "--from",
        dest="base",
        help="Base branch for new branch creation"
    )
    args = parser.parse_args()
    
    # Validate branch name
    if "/" in args.branch:
        prefix, name = args.branch.split("/", 1)
        valid_prefixes = ["feature", "fix", "hotfix", "refactor", "docs", "chore"]
        if prefix not in valid_prefixes:
            print(f"Warning: Unusual prefix '{prefix}'")
            print(f"Common prefixes: {', '.join(valid_prefixes)}")
    
    success = switch_or_create(args.branch, args.base)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
