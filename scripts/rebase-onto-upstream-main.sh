#!/usr/bin/env bash
set -euo pipefail

current_branch="$(git branch --show-current)"

if [[ -z "$current_branch" ]]; then
  echo "Detached HEAD is not supported for this helper." >&2
  exit 1
fi

if [[ "$current_branch" == "upstream-main" ]]; then
  echo "Refusing to rebase upstream-main onto itself." >&2
  exit 1
fi

"$(dirname "$0")/sync-upstream-main.sh"
git rebase upstream-main

echo "Rebased ${current_branch} onto upstream-main"
