# ZEUS voice — sandbox testing & E2E suite

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
  gzip -dc P.gz | awk -v p="^Package: $pkg$" '$0 ~ p {f=1} f && /^Filename:/ {print $2; exit}' >> files.txt
done
while read -r f; do [ -n "$f" ] && curl -sO "http://deb.debian.org/debian/$f"; done < files.txt
for f in *.deb; do dpkg-deb -x "$f" .; done
```

> In this sandbox `HOME=/home`, so the libraries land at
> `/home/pw-libs/usr/lib/x86_64-linux-gnu/`. Verify with:
> `LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" <chromium> --version`.

## 3. Installing the browser + running the suite

```bash
cd app
bunx playwright install chromium   # downloads headless Chromium
LD_LIBRARY_PATH="$HOME/pw-libs/usr/lib/x86_64-linux-gnu" bun run test:e2e
```

The `webServer` in `playwright.config.ts` boots the app itself in sandbox mode
on `:3001` (pinned to `127.0.0.1` — vite binds IPv4 there), so you don't start
a server first.

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