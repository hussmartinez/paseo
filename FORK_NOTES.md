# Fork Notes

Personal fork of [getpaseo/paseo](https://github.com/getpaseo/paseo) with extra features and self-built Android/Linux releases.

## Release ownership

- `origin` is your fork. All tags and releases must be pushed there.
- `upstream` is the source repository. Fetch from it, but do not push release tags there.
- Stable and RC tags in this fork trigger:
  - Android APK GitHub release assets
  - Linux desktop GitHub release assets
- This fork's `release:*` scripts do not publish npm packages.

## Upstream sync workflow

Remotes in this fork:

- `origin` = `git@github.com:hussmartinez/paseo.git`
- `upstream` = `git@github.com:getpaseo/paseo.git`

Recommended branch layout:

- `upstream-main`: mirror of `upstream/main`
- `main`: your shipping branch
- feature branches: your actual work branches

Refresh the local upstream mirror branch:

```bash
npm run sync:upstream
```

The script checks for uncommitted changes first, then:

```bash
git fetch upstream
git checkout upstream-main
git reset --hard upstream/main
git checkout -
```

Rebase your current branch onto the refreshed upstream mirror:

```bash
npm run rebase:upstream
```

That script runs `sync:upstream` first, then:

```bash
git rebase upstream-main
```

## Recommended flows

Sync your feature branch with the latest upstream:

```bash
git checkout your-branch
npm run rebase:upstream
```

Update local `main` without releasing:

```bash
git checkout main
npm run rebase:upstream
git push origin main
```

Land a feature branch into your fork's `main` after it is rebased:

```bash
git checkout your-branch
npm run rebase:upstream
# open PR to main
```

## Fork-owned files

These files are expected to diverge from upstream:

- `FORK_NOTES.md`
- `package.json` — name, release scripts, sync/rebase scripts, repository URL
- `packages/app/app.config.js` — Expo owner/project/package identity
- `packages/desktop/electron-builder.yml` — Linux-only desktop publishing and branding
- `packages/desktop/package.json` — repository URL
- `.github/workflows/desktop-release.yml` — Linux-only desktop release workflow
- `.github/workflows/android-apk-release.yml` — APK build and release behavior
- `docs/RELEASE.md` — fork-specific release instructions
- `scripts/sync-upstream-main.sh` — upstream sync helper
- `scripts/rebase-onto-upstream-main.sh` — rebase helper

Keep changes outside this list minimal where possible. Smaller fork-only diffs make rebasing easier.

## Rebase policy

- Prefer `rebase` over `merge` for keeping your fork branches current with upstream.
- Rebase feature branches onto `upstream-main` before opening a PR to your fork's `main`.
- Rebase `main` onto `upstream-main` before cutting a release if upstream moved since your last sync.
- Do not push release tags to `upstream`.

## Release procedure

1. Sync with upstream.
2. Run `npm run typecheck`.
3. Cut a release with `npm run release:patch` or another `release:*` command.
4. Confirm the GitHub `Desktop Release` and `Android APK Release` workflows pass in your fork.

## Fork configuration

Expo / Android (`packages/app/app.config.js`):

- `EXPO_OWNER` = `hussmartinez`
- `EXPO_PROJECT_ID` = `edc888b5-a4ce-411b-8fa0-bcca32aa7cb9`
- `EXPO_SLUG` = `paseo-huss`
- `APP_NAME` = `Paseo Huss`
- `APP_PACKAGE_ID` = `sh.paseo`
- `APP_SCHEME` = `paseo-huss`

Desktop (`packages/desktop/electron-builder.yml`):

- `appId` = `sh.paseo-huss.desktop`
- `productName` = `Paseo Huss`
- `executableName` = `PaseoHuss`
- Linux `maintainer` = `Huss Martinez <dev@hussmartinez.xyz>`
- Linux `vendor` = `Paseo-Huss`
