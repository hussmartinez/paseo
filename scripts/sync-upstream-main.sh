#!/usr/bin/env bash
set -euo pipefail

current_branch="$(git branch --show-current)"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "You have uncommitted changes. Please commit or stash them first." >&2
  exit 1
fi

if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  echo "You have untracked files. Please commit or stash them first." >&2
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "Missing git remote 'upstream'." >&2
  exit 1
fi

git fetch upstream
git checkout upstream-main
git reset --hard upstream/main

if [[ -n "$current_branch" && "$current_branch" != "upstream-main" ]]; then
  git checkout "$current_branch"
fi

echo "upstream-main is now aligned with upstream/main"
