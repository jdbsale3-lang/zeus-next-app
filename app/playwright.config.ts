import { defineConfig, devices } from "@playwright/test";

// ZEUS voice E2E suite. Boots the app in DEV SANDBOX mode (VITE_ZEUS_MOCK=1):
// server functions answer from an in-memory mock store, so no platform auth,
// D1, or LLM is required. The voice tests inject fakes for the Web Speech API
// (SpeechRecognition / speechSynthesis / MediaRecorder) so capture → transcript
// → ZEUS reply → spoken reply is fully deterministic.
//
// Projects: the same suite runs on Chromium (Chrome/Edge), Firefox, and WebKit
// (Safari engine). On Firefox/WebKit the fakes remove any native
// SpeechRecognition, so the app genuinely exercises its MediaRecorder →
// server-transcription fallback — the real cross-browser story.
export default defineConfig({
  testDir: "./tests/e2e",
  timeout: 90_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: [["list"]],
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } },
  ],
  use: {
    baseURL: "http://127.0.0.1:3001",
    headless: true,
  },
  webServer: {
    command: "VITE_ZEUS_MOCK=1 bun run dev -- --port 3001 --strictPort --host 127.0.0.1",
    url: "http://127.0.0.1:3001",
    reuseExistingServer: false,
    timeout: 180_000,
  },
});