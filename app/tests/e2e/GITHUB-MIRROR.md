# Mirroring to GitHub — activate the voice E2E CI

> **Status: mirrored.** The repo is live at
> `github.com/jdbsale3-lang/zeus-next-app` (default branch `main`), and the
> README badge is wired to the real workflow. The mirror is maintained as the
> `github-mirror` branch in the project repo — it is `origin/main` minus the
> platform-internal scaffolding (`.github/workflows/ci.yml`, `app/AGENTS.md`).
> Re-sync after any push to `origin/main`:
>
> ```bash
> git fetch origin main
> git checkout github-mirror
> git merge origin/main --no-edit        # if ci.yml/AGENTS.md come back:
> git rm --cached -r .github/workflows/ci.yml app/AGENTS.md && git commit -m "Mirror: re-strip platform scaffolding"
> git push github github-mirror:main     # the `github` remote is set for SSH
> ```

The E2E workflow (`.github/workflows/voice-e2e.yml`) runs on GitHub Actions,
so the repo must be reachable there. This repo currently lives on the
Higgsfield-hosted git; mirroring it to GitHub is a one-time push — nothing in
the project changes.

## Why

- The `webkit` matrix leg needs the official Playwright image
  (`mcr.microsoft.com/playwright:v1.62.1-noble`), which ships the WPE
  compositing + automation stack that minimal sandboxes (like this one) lack.
- Once the workflow has run green, the README badge renders a live status.

## One-time setup

1. **Create an empty GitHub repository** (no README, no .gitignore — the
   project brings its own). A name that matches the app slug works well, e.g.
   `zeus-next-app`. Private or public both fine.
2. **Add the remote and push** (from the project root):

   ```bash
   git remote add github https://github.com/<owner>/<repo>.git
   git push github main
   # if you keep other branches/tags:
   git push --all github
   git push --tags github
   ```

3. **Enable Actions**: repo → Settings → Actions → *General* → *Allow* (if
   your org has Actions disabled by default, allow it for this repo).
4. **Wait for the first run** (Actions tab): the push to `main` triggers
   three matrix legs — `chromium`, `firefox`, `webkit` — each running the 8
   voice E2E tests in DEV SANDBOX mock mode (no platform auth/D1/LLM needed).
   The `container:` image is standard on ubuntu runners and needs no config.
5. **Swap the badge**: once green, replace `<owner>/<repo>` in the badge URL
   at the top of `tests/e2e/README.md` with the real values.

## What runs

| Leg | Engine | What it proves |
|---|---|---|
| chromium | Chrome/Edge engine | native SpeechRecognition path |
| firefox | Firefox | MediaRecorder → server-transcription fallback (native SR stripped) |
| webkit | Safari engine | same fallback on WebKit |

Every leg boots the app itself (sandbox `webServer` in `playwright.config.ts`),
so no server is needed. Failure traces upload as artifacts (`voice-e2e-<engine>-traces`).

## Troubleshooting

- **Actions tab missing / disabled** → org policy: Settings → Actions → allow
  this repository, then re-push or use *workflow_dispatch* (the workflow has
  it enabled).
- **Badge shows "no status"** → normal until the first completed run; it can
  take a few minutes after the mirror push.
- **Leg fails only on `webkit`** → read the trace artifact; if the failure is
  the automation-session message, re-run the leg (flaky WPE startup on shared
  runners); if it persists, file it — it is a CI-image issue, not suite code.
- **Keeping the Higgsfield remote in sync**: continue using `origin` for
  Higgsfield deploys; push the same commits to `github` (`git push origin main
  && git push github main`).

## After the mirror

Optionally wire a status badge into the project README and/or a notification
(Slack/Discord webhook) on workflow completion via the Actions UI — both are
settings-only, no code.