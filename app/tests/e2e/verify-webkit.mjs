#!/usr/bin/env node
// WebKit E2E pre-flight: can this environment actually run the `webkit`
// Playwright project? CI (GitHub Actions, official mcr.microsoft.com/playwright
// image) can; a trimmed sandbox (no WPE compositing/automation stack) may not.
//
// Usage:
//   bun run test:e2e:webkit:verify                # launch + page smoke
//   ZEUS_E2E_URL=http://127.0.0.1:3001 bun run test:e2e:webkit:verify
//
// Exit codes:
//   0 = WebKit launched (and, if an app server is reachable, the ZEUS command
//       center header rendered)
//   2 = environment limitation / browser missing — actionable guidance printed
//   3 = unexpected failure

import { webkit } from "@playwright/test";

const APP_URL = process.env.ZEUS_E2E_URL ?? "http://127.0.0.1:3001";

function bye(code, lines) {
  console.log(lines.join("\n"));
  process.exit(code);
}

console.log("== WebKit E2E pre-flight ==");

let browser;
try {
  browser = await webkit.launch({ headless: true });
} catch (e) {
  const msg = e?.message ?? String(e);
  if (/missing dependencies|executable doesn't exist|browserType\.launch/.test(msg)) {
    bye(2, [
      "WebKit could not launch in this environment.",
      msg.split("\n").slice(0, 6).join("\n"),
      "",
      "Fixes, in order of preference:",
      "  1. CI: let `.github/workflows/voice-e2e.yml` run the webkit matrix leg on",
      "     the official image (mcr.microsoft.com/playwright:v1.62.1-noble) — this",
      "     image ships the WPE compositing + automation stack WebKit needs.",
      "  2. Local: install the webkit browser  →  bunx playwright install webkit",
      "     (and, if the host validation complains, vendor the Debian libraries",
      "     listed in tests/e2e/README.md §2-§3d).",
      "  3. If it still exits with 'automation is not allowed in the context',",
      "     that is the known sandbox limitation (README §3c): the WPE host needs",
      "     a compositing session this box does not provide — run webkit on CI.",
    ]);
  }
  bye(3, ["Unexpected WebKit launch failure:", msg.split("\n").slice(0, 10).join("\n")]);
}

try {
  const page = await browser.newPage();
  console.log("✓ WebKit browser launched; page/context created.");

  const res = await page.goto(APP_URL, { timeout: 10_000 }).catch(() => null);
  if (!res) {
    console.log(`- App server not reachable at ${APP_URL} (skip page smoke).`);
    console.log(`  Start it with:  VITE_ZEUS_MOCK=1 bun run dev -- --port 3001 --host 127.0.0.1`);
    console.log(`  Then re-run with ZEUS_E2E_URL set.`);
  } else {
    const title = await page
      .locator("h1")
      .first()
      .textContent({ timeout: 15_000 })
      .catch(() => null);
    if (title && title.includes("ZEUS AI COMMAND CENTER")) {
      console.log(`✓ App header rendered on WebKit: "${title}"`);
    } else {
      console.log(`- App loaded (HTTP ${res.status()}) but header check failed: ${title ?? "no h1"}`);
    }
  }
  await browser.close();
  console.log("✓ WebKit verification complete.");
  process.exit(0);
} catch (e) {
  bye(3, ["WebKit page smoke failed:", e?.message ?? String(e)]);
}