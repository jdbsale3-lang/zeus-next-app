import { test, expect, type Page } from "@playwright/test";

// Automated E2E for the ZEUS voice layer (DEV SANDBOX mode, see playwright.config.ts).
// The browser's real Web Speech API has no microphone in headless, so the suite
// injects deterministic fakes via addInitScript and asserts on the app's
// behavior around them — which is exactly the code path a real mic exercises.

const MIC = '[aria-label="Speak your command"]';
// While listening, BOTH the mic button and the sphere flip their label; the
// mic button is the only one with a title attribute, so scope to it.
const STOP = '[aria-label="Stop listening"][title]';
const SPHERE = '[aria-label="Talk to ZEUS"]';
const LISTENING = /Listening… speak your command|Recording… tap the mic again when done/;
const TRANSCRIPT = "Show my open tasks";
const MOCK_REPLY = /You have 1 open task/;

type FakeOptions = {
  /** Install a fake SpeechRecognition (Chrome/Edge path). Default true. */
  sr?: boolean;
  /** sr behavior: "final" (transcript immediately), "hold" (stays listening), "error". */
  srMode?: "final" | "hold" | "error";
  /** Install a fake MediaRecorder + getUserMedia (Firefox/Safari path). Default true. */
  recorder?: boolean;
};

async function installFakes(page: Page, opts: FakeOptions = {}) {
  const { sr = true, srMode = "final", recorder = true } = opts;
  await page.addInitScript(
    ({ sr, srMode, recorder }) => {
      const w = window as any;
      w.__spoken = [];
      w.__voiceTest = { mode: srMode, text: "Show my open tasks", errorCode: srMode === "error" ? "not-allowed" : null };

      if (sr) {
        const FakeSR = class {
          lang = "en-GB";
          continuous = false;
          interimResults = true;
          maxAlternatives = 1;
          onresult: any = null;
          onend: any = null;
          onerror: any = null;
          start() {
            const t = w.__voiceTest;
            if (t.errorCode) {
              queueMicrotask(() => this.onerror?.({ error: t.errorCode }));
              return;
            }
            if (t.mode === "hold") return; // stays listening until stop()
            queueMicrotask(() => {
              this.onresult?.({ resultIndex: 0, results: [{ 0: { transcript: t.text }, isFinal: true }] });
              this.onend?.();
            });
          }
          stop() {
            this.onend?.();
          }
        };
        Object.defineProperty(w, "webkitSpeechRecognition", { value: FakeSR, configurable: true });
        Object.defineProperty(w, "SpeechRecognition", { value: FakeSR, configurable: true });
      } else {
        // Chromium ships a native SpeechRecognition — remove it to truly
        // simulate Firefox/Safari (and the no-voice-API case).
        Object.defineProperty(w, "webkitSpeechRecognition", { value: undefined, configurable: true });
        Object.defineProperty(w, "SpeechRecognition", { value: undefined, configurable: true });
      }

      // Fake speechSynthesis: records utterances instead of speaking.
      const FakeSynth = {
        speaking: false,
        pending: false,
        getVoices: () => [],
        speak(u: any) {
          w.__spoken.push(u.text);
        },
        cancel() {},
      };
      Object.defineProperty(w, "speechSynthesis", { value: FakeSynth, configurable: true });

      if (recorder) {
        const FakeRec = class {
          static isTypeSupported = () => true;
          mimeType = "audio/webm;codecs=opus";
          ondataavailable: any = null;
          onstop: any = null;
          start() {
            setTimeout(() => {
              // 96 bytes → base64 ~128 chars, passes the server min(32) guard.
              this.ondataavailable?.({ data: new Blob([new Uint8Array(96)], { type: "audio/webm" }) });
            }, 40);
          }
          stop() {
            this.onstop?.();
          }
        };
        Object.defineProperty(w, "MediaRecorder", { value: FakeRec, configurable: true });
        Object.defineProperty(navigator, "mediaDevices", {
          value: {
            getUserMedia: () =>
              Promise.resolve({
                getTracks: () => [{ stop() {} }],
              }),
          },
          configurable: true,
        });
      } else {
        // Chromium ships a native MediaRecorder — remove it too.
        Object.defineProperty(w, "MediaRecorder", { value: undefined, configurable: true });
      }
    },
    { sr, srMode, recorder },
  );
}

test("security headers: microphone allowed for self on app responses", async ({ page }) => {
  const res = await page.request.get("/");
  const pp = res.headers()["permissions-policy"] ?? "";
  expect(pp).toContain("microphone=(self)");
  expect(pp).toContain("camera=()");
  expect(res.headers()["x-content-type-options"]).toBe("nosniff");
});

test("command center renders with mic button, sphere and sandbox badge", async ({ page }) => {
  await installFakes(page);
  await page.goto("/");
  await expect(page.locator("h1")).toContainText("ZEUS AI COMMAND CENTER");
  await expect(page.locator(MIC)).toBeVisible();
  await expect(page.locator(SPHERE)).toBeVisible();
  await expect(page.getByText("DEV SANDBOX")).toBeVisible();
});

test("voice capture → ZEUS reply → spoken reply (Chrome/Edge path)", async ({ page }) => {
  await installFakes(page);
  await page.goto("/");

  await page.locator(MIC).click();
  // Transcript lands in the chat as the user's message
  await expect(page.getByText(TRANSCRIPT)).toBeVisible();
  // ZEUS answers from the (mock) business data
  await expect(page.getByText(MOCK_REPLY)).toBeVisible();
  // ...and speaks the answer aloud
  const spoken = await page.evaluate(() => (window as any).__spoken as string[]);
  expect(spoken.length).toBeGreaterThan(0);
  expect(spoken[spoken.length - 1]).toMatch(/open task/);
});

test("listening state shows while mic is active", async ({ page }) => {
  await installFakes(page, { srMode: "hold" });
  await page.goto("/");
  await page.locator(MIC).click();
  await expect(page.getByText(LISTENING)).toBeVisible();
  await page.locator(STOP).click(); // stop listening
  await expect(page.getByText(LISTENING)).toHaveCount(0);
});

test("mic permission denied: clear error pin, no run", async ({ page }) => {
  await installFakes(page, { srMode: "error" });
  await page.goto("/");
  await page.locator(MIC).click();
  await expect(page.getByText(/Microphone access denied/)).toBeVisible();
  await expect(page.getByText(MOCK_REPLY)).toHaveCount(0);
});

test("VOICE REPLIES OFF: answer is visible but not spoken", async ({ page }) => {
  await installFakes(page);
  await page.goto("/");
  // The mic button only appears after the app hydrates AND the voice-caps
  // effect runs — a reliable "React is mounted + interactive" signal.
  await page.locator(MIC).waitFor();
  await page.getByRole("button", { name: /VOICE REPLIES ON/ }).click();
  // Wait for the committed flip so the run below reads the OFF value.
  await expect(page.getByRole("button", { name: /VOICE REPLIES OFF/ })).toBeVisible();

  await page.locator(MIC).click();
  await expect(page.getByText(TRANSCRIPT)).toBeVisible();
  // The reply comes only after the transcribed audio reaches the server and
  // ZEUS answers — assert the assistant bubble, not the empty-state chip.
  await expect(page.getByRole("heading", { name: "ZEUS Live AI" })).toBeVisible();
  await expect(page.getByText(MOCK_REPLY)).toBeVisible();
  await page.waitForTimeout(400);
  const spoken = await page.evaluate(() => (window as any).__spoken as string[]);
  expect(spoken).toHaveLength(0);
});

test("Firefox/Safari fallback: records audio, transcribes server-side, replies", async ({ page }) => {
  await installFakes(page, { sr: false });
  await page.goto("/");

  await page.locator(MIC).click();
  await expect(page.getByText(/Recording… tap the mic again when done/)).toBeVisible();
  await page.locator(STOP).click(); // stop → transcribe → ask

  await expect(page.getByText(TRANSCRIPT)).toBeVisible();
  await expect(page.getByText(MOCK_REPLY)).toBeVisible();
  const spoken = await page.evaluate(() => (window as any).__spoken as string[]);
  expect(spoken.length).toBeGreaterThan(0);
});

test("no voice API at all: mic button hidden, fallback hint shown", async ({ page }) => {
  await installFakes(page, { sr: false, recorder: false });
  await page.goto("/");
  await expect(page.locator(MIC)).toHaveCount(0);
  await expect(page.getByText(/Voice input isn't supported/)).toBeVisible();
});