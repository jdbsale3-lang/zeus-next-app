// ZEUS voice bridge — mic input (SpeechRecognition) and spoken replies (speechSynthesis).
// SSR-safe: every browser API touch happens inside user-driven calls, never at module top level.

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

let recognizer: any = null;

export function isVoiceSupported(): boolean {
  return typeof window !== "undefined" && !!recognitionCtor();
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
}

export function startListening(cb: VoiceListenCallbacks): void {
  stopListening();
  const Ctor = recognitionCtor();
  if (!Ctor) {
    cb.onError?.("Voice input isn't supported in this browser — try Chrome or Edge.");
    return;
  }
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

export function speak(text: string, enabled: boolean): void {
  if (!enabled || typeof window === "undefined" || !("speechSynthesis" in window)) return;
  const synth = window.speechSynthesis;
  synth.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  const voices = synth.getVoices();
  const preferred =
    voices.find((v) => v.lang.startsWith("en-GB") && /natural|female|samantha|google uk/i.test(v.name)) ??
    voices.find((v) => v.lang.startsWith("en-GB")) ??
    voices.find((v) => v.lang.startsWith("en")) ??
    voices[0];
  if (preferred) utterance.voice = preferred;
  utterance.rate = 1.03;
  utterance.pitch = 1;
  synth.speak(utterance);
}