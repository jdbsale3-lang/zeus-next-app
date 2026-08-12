# ZEUS voice — sandbox testing & E2E suite

[![Voice E2E — Chromium · Firefox · WebKit](https://github.com/jdbsale3-lang/zeus-next-app/actions/workflows/voice-e2e.yml/badge.svg)](https://github.com/jdbsale3-lang/zeus-next-app/actions/workflows/voice-e2e.yml)

This documents how to run the ZEUS Command Center locally in a **dev sandbox**
(no platform auth, D1, or LLM required) and how to run the automated voice E2E
suite. It covers the pieces added for sandbox testing:

- `src/lib/dev-mock.server.ts` — in-memory mock store + deterministic answers,
  active only when `VITE_ZEUS_MOCK=1` in dev (`import.meta.env.DEV` is statically
  `false` in production builds, so the mock can never ship).
- `src/lib/dev-cf-env-shim.ts` + the `vite.config.ts` dev-alias — lets the
  Node-based `vite dev` resolve the workerd-only `cloudflare:workers` module
  (the real module exists only on the deployed Worker). The shim fails loudly
  if a non-mocked path actually touches a binding.
- `src/lib/voice.server.ts` — server-side transcription (Firefox/Safari path):
  OpenAI Whisper via the `OPENAI_API_KEY` secret in production, deterministic
  mock transcript under `VITE_ZEUS_MOCK`.
- `tests/e2e/voice.spec.ts` — the Playwright suite.

## 1. Sandbox mode

```bash
cd app
bun install
VITE_ZEUS_MOCK=1 bun run dev -- --port 3001 --strictPort --host 127.0.0.1
```

The app boots with a **DEV SANDBOX** badge in the header. Server functions
(`getDashboard`, `askZeus`, the CRUD tools, and `transcribeVoice`) answer from
the in-memory mock store — no sign-in, no D1, no LLM. The mic button and spoken
replies work exactly as in production.

> Note: at boot the dev server logs an `ENOTFOUND fnf.internal` error from the
> auth bootstrap. `fnf.internal` only resolves inside Cloudflare's network. It
> is non-fatal — the sandbox mock never calls it.

## 2. System dependencies (Linux sandbox)

The Playwright Chromium needs five native libraries the base image lacks:
`libatk-1.0.so.0`, `libatk-bridge-2.0.so.0`, `libatspi.so.0`,
`libXcomposite.so.1`, `libXdamage.so.1`. There is no root/sudo, so they are
extracted into a user prefix:

```bash
mkdir -p ~/pw-libs && cd ~/pw-libs
# Fetch the bookworm index and pull the exact .deb filenames
curl -s http://deb.debian.org/debian/dists/bookworm/main/binary-amd64/Packages.gz -o P.gz
for pkg in libatk1.0-0 libatk-bridge2.0-0 libatspi2.0-0 libxcomposite1 libxdamage1; do
  gzip -dc P.gz | awk -v p="^Package: $pkg$" '$0 ~ p {f=1} f && /^Filename:/ {print $2; exit}' > files.txt
done
while read -r f; do [ -n "$f" ] && curl -sO "http://deb.debian.org/debian/$f"; done < files.txt
for f in *.deb; do dpkg-deb -x "$f" .; done
```

> In this sandbox `HOME=/home`, so the libraries land at
> `/home/pw-libs/usr/lib/x86_64-linux-gnu/`. Verify with:
> `LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" <chromium> --version`.

## 3. Installing the browsers + running the suite

```bash
cd app
bunx playwright install chromium firefox webkit   # Chrome/Edge + Firefox + Safari-engine
```

Chromium and Firefox both run in this sandbox (see §3d for Firefox's one extra
dep). Run all three projects, or a single engine:

```bash
LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" bun run test:e2e
LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" bunx playwright test --project=firefox
LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" bunx playwright test --project=webkit
```

The `webServer` in `playwright.config.ts` boots the app itself in sandbox mode
on `:3001` (pinned to `127.0.0.1` — vite binds IPv4 there), so you don't start
a server first.

### 3a. The three browser projects

`playwright.config.ts` defines `chromium`, `firefox`, and `webkit` projects and
runs the **same suite** on each. That is valid on all three because the harness
injects the Web Speech API fakes — and on Firefox/WebKit it also removes any
native `SpeechRecognition`, which forces the app to take its real
MediaRecorder → server-transcription fallback: the genuine Firefox/Safari story.

In THIS sandbox, `webkit` cannot run (§3c) — use the explicit project form to
avoid an all-engines run failing on it:

```bash
LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" bun run test:e2e -- --project=chromium
LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" bun run test:e2e -- --project=firefox
```

### 3b. CI

`.github/workflows/voice-e2e.yml` runs the suite on all three browsers after
every push to `app/**`, on the official `mcr.microsoft.com/playwright:v1.62.1-noble`
image (all browsers + system deps preinstalled — including WebKit's WPE
automation stack). It runs one matrix leg per engine
(`--project=<engine>`), keeps legs from blocking each other (`fail-fast:
false`), and uploads failure traces as artifacts. The workflow activates
wherever this repo runs GitHub Actions — see **GITHUB-MIRROR.md** for the
one-time mirror + badge activation steps. To pre-flight WebKit locally
(including inside the CI image), run:

```bash
bun run test:e2e:webkit:verify          # exit 0 = WebKit usable, 2 = env limitation
ZEUS_E2E_URL=http://127.0.0.1:3001 bun run test:e2e:webkit:verify   # + app header smoke
```

### 3c. WebKit in THIS sandbox (known limitation)

WebKit's WPE host cannot open its automation session here
(`WebKitWebView is-controlled-by-automation set but automation is not allowed
in the context` → immediate exit): the sandbox lacks the WPE compositing stack.
This is an environment limitation, not a code or suite defect — the same bundle
runs cleanly on the CI image (§3b), which is where the `webkit` project is
meant to execute. Locally, run the `chromium` and `firefox` projects; leave
`webkit` for CI.

### 3d. Firefox's extra dependency

Playwright's Firefox needs GTK3 (`libgtk-3.so.0`, `libgdk-3.so.0`). Vendor it
into the same prefix:

```bash
cd ~/pw-libs
curl -s http://deb.debian.org/debian/dists/bookworm/main/binary-amd64/Packages.gz -o P.gz
f=$(gzip -dc P.gz | awk -v p="^Package: libgtk-3-0$" '$0 ~ p {f=1} f && /^Filename:/ {print $2; exit}')
curl -sO "http://deb.debian.org/debian/$f"
dpkg-deb -x "$(basename "$f")" .
```

For WebKit, the helper script `fetch.sh` in `~/pw-libs` downloads any Debian
package by name into the prefix and re-checks what is still missing (this
sandbox needed four batches: GTK4, graphene, libevent, gstreamer GL +
codecparsers, libavif, libmanette, libenchant, libsecret, libgles2 + the
transitive tail). After resolving, symlink the prefix libs into the WPE
bundle's `lib/` so the bundle-owned `LD_LIBRARY_PATH` finds them:

```bash
ln -sf /home/pw-libs/usr/lib/x86_64-linux-gnu/*.so* \
  ~/.cache/ms-playwright/webkit-*/minibrowser-wpe/lib/
```

## 4. What the suite covers (`tests/e2e/voice.spec.ts`)

The browser's real Web Speech API has no microphone in headless, so the suite
injects deterministic fakes via `addInitScript` and asserts on the app's
behavior around them — the exact code paths a real mic exercises:

| Test | Verifies |
|---|---|
| Security headers | `permissions-policy: microphone=(self)`, `camera=()`, `nosniff` on app responses |
| Render | mic button + sphere + DEV SANDBOX badge |
| Chrome/Edge capture | fake `SpeechRecognition` → transcript bubble → ZEUS mock reply → `speechSynthesis` utters it |
| Listening state | recording indicator shows while active and clears on stop |
| Mic denied | `not-allowed` → clear error pin, no run |
| VOICE REPLIES OFF | answer renders but no utterance is spoken |
| Firefox/Safari fallback | no `SpeechRecognition` → fake `MediaRecorder` → base64 upload → server `transcribeVoice` mock → reply + spoken |
| No voice API | mic button hidden + fallback hint |

Two harness details worth knowing:

- **Chromium ships native `SpeechRecognition`/`MediaRecorder`.** The "Firefox"
  and "no API" cases explicitly set them to `undefined` so the app truly takes
  the fallback path.
- **Clicks must wait for the mic button.** The mic button only appears after
  the app hydrates and the voice-caps `useEffect` runs, so it doubles as the
  "React is mounted + interactive" signal — wait for it before clicking.

## 5. Enabling real Firefox/Safari voice (production)

The fallback already ships; it just needs a provider. Set the secret:

```bash
# via the website_secrets tool: name=OPENAI_API_KEY, value=<your Whisper key>
```

Then redeploy. Without it, Firefox/Safari voice shows a clear "not configured"
error; Chrome/Edge voice needs no key (native SpeechRecognition).

## 6. Key files

| File | Role |
|---|---|
| `src/lib/voice.ts` | Client voice bridge: native SR (Chrome/Edge) or MediaRecorder → upload (FF/Safari); `speechSynthesis` replies |
| `src/lib/voice.server.ts` | Server transcription (Whisper / mock), upload validation, rate limit |
| `src/lib/dev-mock.server.ts` | In-memory sandbox store + deterministic answers |
| `src/lib/dev-cf-env-shim.ts` | Dev resolver for `cloudflare:workers` |
| `src/layouts/command-center.tsx` | Voice UI: mic button, listening/recording states, VOICE REPLIES toggle, DEV SANDBOX badge |
| `playwright.config.ts` | Suite config + sandbox webServer |
| `tests/e2e/voice.spec.ts` | The suite |