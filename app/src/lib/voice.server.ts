// Server-side voice transcription for browsers without SpeechRecognition
// (Firefox, Safari). Audio arrives as base64 from the client's MediaRecorder.
// Production provider: OpenAI Whisper via the OPENAI_API_KEY secret. Under
// VITE_ZEUS_MOCK dev mode a deterministic mock transcript is returned so the
// full loop is testable in the sandbox without any provider key.

import { bindings } from "./bindings.server";
import { assertNotRateLimited } from "./command-center.server";
import { DEV_MOCK, mockTranscribe } from "./dev-mock.server";

export const MAX_VOICE_B64 = 8_000_000; // ~6 MB decoded — a ~60s opus clip

export const ALLOWED_VOICE_MIME = new Set([
  "audio/webm",
  "audio/ogg",
  "audio/wav",
  "audio/x-wav",
  "audio/mp4",
  "audio/mpeg",
]);

export function validateVoiceUpload(audio: string, mimeType: string): string | undefined {
  if (audio.length < 32) return "Recording is empty.";
  if (audio.length > MAX_VOICE_B64) return "Recording is too large to transcribe.";
  const mime = mimeType.split(";")[0].trim().toLowerCase();
  if (!ALLOWED_VOICE_MIME.has(mime)) return `Unsupported audio type: ${mimeType}`;
  return undefined;
}

export async function transcribeVoice(audio: string, mimeType: string): Promise<string> {
  if (DEV_MOCK) return mockTranscribe(audio, mimeType);

  await assertNotRateLimited();

  const invalid = validateVoiceUpload(audio, mimeType);
  if (invalid) throw new Error(invalid);

  const apiKey = bindings().OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error(
      "Voice transcription isn't configured yet — add the OPENAI_API_KEY secret and redeploy. Chrome/Edge voice works today.",
    );
  }

  const binary = atob(audio);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);

  const form = new FormData();
  form.append("file", new Blob([bytes], { type: mimeType }), "zeus-voice.webm");
  form.append("model", "whisper-1");
  form.append("language", "en");

  const res = await fetch("https://api.openai.com/v1/audio/transcriptions", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}` },
    body: form,
  });
  if (!res.ok) {
    throw new Error(`Transcription service error (${res.status}) — try again in a moment.`);
  }
  const json = (await res.json()) as { text?: string };
  const text = (json?.text ?? "").trim();
  if (!text) throw new Error("Nothing heard in that recording — try again.");
  return text;
}