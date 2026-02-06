#!/usr/bin/env python3
"""
Validate commit message follows conventional commits format.
Usage: python validate_commit_msg.py [<commit-msg-file>]
       or pipe: echo "feat: add feature" | python validate_commit_msg.py
"""

import re
import sys

# Conventional commit pattern
PATTERN = re.compile(
    r"^(revert: )?(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,100}"
)

# Valid types
TYPES = ["feat", "fix", "docs", "style", "refactor", "test", "chore", "revert"]


def validate(message):
    """Validate commit message format."""
    # Skip merge commits and comments
    if message.startswith("Merge") or message.startswith("#"):
        return True, None
    
    # Check empty
    if not message.strip():
        return False, "Commit message cannot be empty"
    
    # Check pattern
    if not PATTERN.match(message):
        return False, """Invalid commit message format.

Expected: <type>(<scope>): <subject>

Valid types:
  feat     - New feature
  fix      - Bug fix
  docs     - Documentation
  style    - Code style changes
  refactor - Code refactoring
  test     - Adding tests
  chore    - Build/config changes

Examples:
  feat: add user login
  fix(api): handle timeout error
  docs(readme): update setup guide
"""
    
    return True, None


def main():
    # Handle help
    if len(sys.argv) > 1 and sys.argv[1] in ("--help", "-h"):
        print("Usage: python validate_commit_msg.py [<commit-msg-file>]")
        print("       echo 'commit message' | python validate_commit_msg.py")
        sys.exit(0)
    
    # Read from file or stdin
    if len(sys.argv) > 1:
        with open(sys.argv[1], "r") as f:
            message = f.read()
    else:
        message = sys.stdin.read()
    
    # Take first line only
    first_line = message.split("\n")[0]
    
    valid, error = validate(first_line)
    
    if valid:
        print(f"[OK] Valid commit message: {first_line[:50]}...")
        sys.exit(0)
    else:
        print(f"[FAIL] Invalid: {first_line[:50]}")
        print(error)
        sys.exit(1)


if __name__ == "__main__":
    main()
