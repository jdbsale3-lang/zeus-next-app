// ZEUS voice bridge — unified mic input and spoken replies.
// Chrome/Edge: native SpeechRecognition (local, free, real-time transcripts).
// Firefox/Safari: MediaRecorder capture → server-side transcription
// (transcribeVoiceFn; Whisper via OPENAI_API_KEY in production, deterministic
// mock under VITE_ZEUS_MOCK). Replies always use speechSynthesis.
// SSR-safe: every browser API touch happens inside user-driven calls.

import { transcribeVoiceFn } from "@/lib/command-center.functions";

type VoiceListenCallbacks = {
  onInterim?: (text: string) => void;
  onFinal?: (text: string) => void;
  onEnd?: () => void;
  onError?: (message: string) => void;
};

function recognitionCtor(): (new () => any) | undefined {
  if (typeof window === "undefined") return undefined;
  const w = window as any;
  return w.SpeechRecognition || w.webkitSpeechRecognition || undefined;
}

function recorderSupported(): boolean {
  return (
    typeof window !== "undefined" &&
    typeof window.MediaRecorder !== "undefined" &&
    !!navigator?.mediaDevices?.getUserMedia
  );
}

let recognizer: any = null;
let recorderSession: { stop: () => void } | null = null;
let recordCapTimer: ReturnType<typeof setTimeout> | null = null;

const RECORD_CAP_MS = 12_000;

export function hasNativeSpeech(): boolean {
  return typeof window !== "undefined" && !!recognitionCtor();
}

export function hasVoiceInput(): boolean {
  return hasNativeSpeech() || recorderSupported();
}

export function stopListening(): void {
  if (recognizer) {
    try {
      recognizer.stop();
    } catch {
      // already stopped
    }
    recognizer = null;
  }
  if (recorderSession) {
    recorderSession.stop();
    recorderSession = null;
  }
  if (recordCapTimer) {
    clearTimeout(recordCapTimer);
    recordCapTimer = null;
  }
}

export function startListening(cb: VoiceListenCallbacks): void {
  stopListening();
  if (recognitionCtor()) {
    startNative(cb);
    return;
  }
  if (recorderSupported()) {
    void startRecorder(cb);
    return;
  }
  cb.onError?.("Voice input isn't supported in this browser — use the text box.");
}

// ---- Chrome/Edge: native SpeechRecognition ----
function startNative(cb: VoiceListenCallbacks): void {
  const Ctor = recognitionCtor()!;
  const rec = new Ctor();
  rec.lang = "en-GB";
  rec.continuous = false;
  rec.interimResults = true;
  rec.maxAlternatives = 1;
  recognizer = rec;

  let finalText = "";
  rec.onresult = (e: any) => {
    let interim = "";
    for (let i = e.resultIndex; i < e.results.length; i++) {
      const result = e.results[i];
      const transcript = result[0]?.transcript ?? "";
      if (result.isFinal) finalText += transcript;
      else interim += transcript;
    }
    if (interim) cb.onInterim?.(interim);
  };
  rec.onend = () => {
    recognizer = null;
    const spoken = finalText.trim();
    if (spoken) cb.onFinal?.(spoken);
    cb.onEnd?.();
  };
  rec.onerror = (e: any) => {
    const code = e?.error as string | undefined;
    if (code === "not-allowed" || code === "service-not-allowed") {
      cb.onError?.("Microphone access denied — allow the mic in your browser and try again.");
    } else if (code === "no-speech") {
      cb.onError?.("No speech heard — tap the mic and speak again.");
    } else if (code === "aborted") {
      cb.onEnd?.(); // user cancelled — quiet
    } else {
      cb.onError?.(`Voice input error (${code ?? "unknown"}) — try again.`);
    }
  };
  try {
    rec.start();
  } catch {
    cb.onError?.("Couldn't start the microphone — check permissions and try again.");
  }
}

// ---- Firefox/Safari: record, then transcribe server-side ----
function pickRecorderMime(): string {
  if (typeof window.MediaRecorder === "undefined") return "";
  const candidates = ["audio/webm;codecs=opus", "audio/webm", "audio/ogg;codecs=opus", "audio/mp4", "audio/wav"];
  for (const c of candidates) {
    try {
      if (window.MediaRecorder.isTypeSupported(c)) return c;
    } catch {
      // not supported — try the next
    }
  }
  return "";
}

function blobToBase64(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      const comma = result.indexOf(",");
      resolve(comma >= 0 ? result.slice(comma + 1) : result);
    };
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(blob);
  });
}

async function startRecorder(cb: VoiceListenCallbacks): Promise<void> {
  let stream: MediaStream | null = null;
  try {
    stream = await navigator.mediaDevices.getUserMedia({ audio: true });
  } catch (e) {
    const name = (e as DOMException)?.name ?? "";
    cb.onError?.(
      name === "NotAllowedError" || name === "SecurityError"
        ? "Microphone access denied — allow the mic in your browser and try again."
        : name === "NotFoundError"
          ? "No microphone found on this device."
          : "Couldn't start the microphone — check permissions and try again.",
    );
    cb.onEnd?.();
    return;
  }

  const mime = pickRecorderMime();
  let rec: MediaRecorder;
  try {
    rec = mime ? new window.MediaRecorder(stream, { mimeType: mime }) : new window.MediaRecorder(stream);
  } catch {
    rec = new window.MediaRecorder(stream);
  }

  const chunks: BlobPart[] = [];
  rec.ondataavailable = (e) => {
    if (e.data && e.data.size > 0) chunks.push(e.data);
  };

  const finalize = async () => {
    try {
      rec.stop();
    } catch {
      // already stopped
    }
    stream?.getTracks().forEach((t) => t.stop());
    await new Promise<void>((resolve) => {
      rec.onstop = () => resolve();
      setTimeout(resolve, 800); // safety valve if onstop never fires
    });
    if (chunks.length === 0) {
      cb.onEnd?.();
      return;
    }
    const blob = new Blob(chunks, { type: rec.mimeType || "audio/webm" });
    const audioB64 = await blobToBase64(blob).catch(() => null);
    if (!audioB64) {
      cb.onError?.("Couldn't read the recording.");
      cb.onEnd?.();
      return;
    }
    try {
      const text = await transcribeVoiceFn({ data: { audio: audioB64, mimeType: blob.type } });
      cb.onFinal?.(text.trim());
    } catch (e) {
      cb.onError?.((e as Error)?.message ?? "Transcription failed — try again.");
    }
    cb.onEnd?.();
  };

  rec.start();
  recorderSession = {
    stop: () => {
      void finalize();
    },
  };
  recordCapTimer = setTimeout(() => {
    if (recorderSession) {
      recorderSession.stop();
      recorderSession = null;
    }
  }, RECORD_CAP_MS);
}

// ---- Spoken replies ----
export function speak(text: string, enabled: boolean): void {
  if (!enabled || typeof window === "undefined" || !("speechSynthesis" in window)) return;
  const synth = window.speechSynthesis;
  synth.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  const voices = synth.getVoices();
  const preferred =
    voices.find((v) => v.lang.startsWith("en-GB") && /natural|female|samantha|google uk|karen/i.test(v.name)) ??
    voices.find((v) => v.lang.startsWith("en-GB")) ??
    voices.find((v) => v.lang.startsWith("en")) ??
    voices[0];
  if (preferred) utterance.voice = preferred;
  utterance.rate = 1.03;
  utterance.pitch = 1;
  synth.speak(utterance);
}