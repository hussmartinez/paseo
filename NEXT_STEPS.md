# Orphaned workspace plugin handoff

## Current state

- The plugin (detect + archive only) lives in its own private repo:
  `https://github.com/hussmartinez/detect-orphaned-workspaces`. Its `NEXT_STEPS.md`
  tracks plugin-side gaps. This branch holds no code; it only tracks the core relink
  API the plugin needs.
- This branch started from Paseo commit `30178c4f5` and is 683 commits behind
  `upstream/main` as of 2026-10-29.
- The branch is pushed as `origin/plugin-detect-orphaned-workspaces` in
  `https://github.com/hussmartinez/paseo`.
- There is no pull request for this branch.
- The fork is public. Do not copy secrets, daemon state, or workspace data into it.

The daemon already reconciles workspace placement metadata and archives a missing
workspace directory when its project root is still reachable. It does not repair a
moved or renamed project root. The public plugin API can list and archive workspaces,
but it cannot atomically change a project's root or a workspace's directory while
preserving identity and history.

## Implementation plan

1. Rebase or recreate the branch from the current `upstream/main` before coding.
2. Define an explicit relink operation in Paseo core. It must update the project root
   and affected workspace directories atomically while preserving project/workspace
   IDs, agent history, and same-directory workspace ownership.
3. Expose the operation through the client/plugin API with the normal permission and
   capability gates. Follow `docs/protocol-compatibility.md` and
   `docs/rpc-namespacing.md` for any protocol changes.
4. Extend `hussmartinez/detect-orphaned-workspaces` (scan RPC and sidebar surface
   already exist) with candidate ranking and a Relink action.
5. Detect missing paths without mutating them. Rank relocation candidates using, in
   order: Git common-dir/worktree metadata, normalized remote URL, repository name,
   and nearby filesystem location.
6. Require confirmation before relinking. Offer `Relink`, `Archive`, and `Ignore`.
   Never automatically relink an ambiguous match.
7. Test missing directories, renamed project roots, moved worktrees, duplicate remote
   URLs, non-Git directories, unreadable paths, same-directory workspaces, and paths
   that reappear during a scan.

## Server migration

1. Clone `https://github.com/hussmartinez/paseo` on the new server and fetch
   `plugin-detect-orphaned-workspaces` plus `upstream/main`.
2. Copy Paseo daemon state separately if workspace and agent history must move. Git
   does not contain daemon state. Preserve file ownership and permissions, and update
   absolute paths after the repositories are placed on the new server.
3. Recreate or relink the two relevant Paseo workspaces after migration:
   `Create plugin to detect orphaned workspaces` and
   `Create Paseo project management platform`.
4. Do not copy the generated worktree directories as the source of truth. Push any
   commits first, clone the repositories, then recreate worktrees from their branches.
5. Verify the target daemon can see each new absolute path before archiving the old
   server's workspace records.

## Local cleanup after migration

The local Git checkout currently has three clean worktrees:

- `/home/huss/sources/paseo` on `main`
- `/home/huss/.paseo/worktrees/2zqru0vy/hot-rhino` on `paseo-project-manager`
- `/home/huss/.paseo/worktrees/2zqru0vy/rapid-monkey` on
  `plugin-detect-orphaned-workspaces`

Only `plugin-detect-orphaned-workspaces` has a matching branch on `origin`.
`paseo-project-manager` has no unique commits and no remote branch. Archive the two
Paseo workspaces only after the new server is verified; Paseo may then remove its owned
worktrees.
