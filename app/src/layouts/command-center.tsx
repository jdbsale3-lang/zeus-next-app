import { useEffect, useRef, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@higgsfield/quanta/button";
import { Input } from "@higgsfield/quanta/input";
import { Loader } from "@higgsfield/quanta/loader";
import { Textarea } from "@higgsfield/quanta/textarea";
import { Typography } from "@higgsfield/quanta/typography";
import { Icon } from "@higgsfield/quanta/icon";
import { Sparkle, Shield, Activity, Gauge, Radio, Zap, Database, Users, Briefcase, CheckSquare, FileText, Wallet, Brain, LayoutGrid, MessageSquare, Bell, Calendar, Inbox, FolderOpen, Video, Newspaper, Headphones, Webhook, BarChart3, Clock, BookOpen, HeartPulse, Lock, Mic, Volume2, VolumeX, Globe } from "lucide-react";
import { cn } from "@/lib/utils";
import { appFaviconUrl, appMeta } from "@/lib/app-meta";
import { askZeusFn, createContactFn, createDealFn, createNoteFn, createTaskFn, getDashboardFn, getProjectsFn, getConnectionsFn } from "@/lib/command-center.functions";
import type { DashboardSnapshot } from "@/lib/command-center.functions";
import { hasNativeSpeech, hasVoiceInput, speak, startListening, stopListening } from "@/lib/voice";

const MODULES = [
  { name: "Task Matrix", status: "online", icon: CheckSquare },
  { name: "Deal Pipeline", status: "online", icon: Briefcase },
  { name: "Contacts", status: "online", icon: Users },
  { name: "Client Workspaces", status: "online", icon: FolderOpen },
  { name: "Calendar", status: "online", icon: Calendar },
  { name: "Email Intel", status: "online", icon: Inbox },
  { name: "Video Studio", status: "standby", icon: Video },
  { name: "News Feeds", status: "standby", icon: Newspaper },
  { name: "Second Brain", status: "online", icon: Brain },
  { name: "Genius Mode", status: "attention", icon: Sparkle },
  { name: "Zeus Core", status: "online", icon: Shield },
  { name: "Call Tracking", status: "online", icon: Headphones },
  { name: "Security", status: "online", icon: Lock },
  { name: "Webhooks", status: "standby", icon: Webhook },
  { name: "Automation", status: "online", icon: Zap },
  { name: "Analytics", status: "online", icon: BarChart3 },
  { name: "Documents", status: "online", icon: FileText },
  { name: "File Studio", status: "standby", icon: Database },
  { name: "AI Assistant", status: "online", icon: MessageSquare },
  { name: "Notifications", status: "online", icon: Bell },
  { name: "Invoicing", status: "online", icon: Wallet },
  { name: "Expenses", status: "online", icon: Activity },
  { name: "Time Tracking", status: "standby", icon: Clock },
  { name: "Knowledge Base", status: "online", icon: BookOpen },
  { name: "System Health", status: "online", icon: HeartPulse },
];

const CALLS = [
  { time: "10:00", who: "Skitts Estate Agents", phone: "01902 631151", status: "CONFIRMED" },
  { time: "10:30", who: "Webbs Estate Agents", phone: "01922 929888", status: "CONFIRMED" },
  { time: "11:00", who: "KST Accountancy", phone: "01902 639877", status: "PENDING" },
];

const statusColor: Record<string, string> = {
  online: "bg-emerald-400", standby: "bg-amber-400", attention: "bg-rose-400",
};

const connColor: Record<string, string> = {
  connected: "bg-emerald-400", waiting: "bg-amber-400", disconnected: "bg-slate-500",
  needs_key: "bg-amber-400", unavailable: "bg-rose-400",
};

const projectStatusColor: Record<string, string> = {
  live: "text-emerald-300 border-emerald-500/40 bg-emerald-500/10",
  planning: "text-amber-300 border-amber-500/40 bg-amber-500/10",
  build: "text-cyan-300 border-cyan-500/40 bg-cyan-500/10",
  paused: "text-slate-400 border-slate-600 bg-slate-700/20",
};

function ZeusSphere({ listening, onClick }: { listening: boolean; onClick: () => void }) {
  return (
    <button type="button" onClick={onClick} aria-label="Talk to ZEUS"
      className={cn("group relative mx-auto flex h-24 w-24 items-center justify-center rounded-full border transition",
        listening ? "border-rose-400/70 bg-rose-500/15" : "border-cyan-400/40 bg-cyan-500/10 hover:bg-cyan-500/20")}
      style={{ boxShadow: listening ? "0 0 60px rgba(251,113,133,.55), inset 0 0 28px rgba(251,113,133,.25)" : "0 0 40px rgba(34,211,238,.35), inset 0 0 30px rgba(34,211,238,.2)" }}>
      {listening && <span className="absolute inset-0 animate-ping rounded-full border-2 border-rose-400/50" />}
      <span className={cn("text-2xl font-bold", listening ? "text-rose-300" : "text-cyan-300")}>ZEUS</span>
    </button>
  );
}

export function CommandCenterLayout() {
  const [prompt, setPrompt] = useState("");
  const [chat, setChat] = useState<{ role: string; text: string; error?: boolean }[]>([]);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const runRef = useRef(0);
  const cancelledRef = useRef(false);
  const [listening, setListening] = useState(false);
  const [interim, setInterim] = useState("");
  const [voiceOn, setVoiceOn] = useState(true);
  const voiceOnRef = useRef(true);
  useEffect(() => {
    voiceOnRef.current = voiceOn;
  }, [voiceOn]);
  // Voice capability is browser-only, so SSR and the first client render agree
  // (both "unavailable"), then we detect on mount. This avoids an
  // SSR/client hydration mismatch on devices whose API differs from Node.
  const [voiceAvailable, setVoiceAvailable] = useState(false);
  const [nativeSpeech, setNativeSpeech] = useState(false);
  useEffect(() => {
    setVoiceAvailable(hasVoiceInput());
    setNativeSpeech(hasNativeSpeech());
  }, []);
  const devMock = Boolean(import.meta.env.DEV && import.meta.env.VITE_ZEUS_MOCK === "1");

  const { data: snapshot, isLoading } = useQuery({
    queryKey: ["zeus-dashboard"],
    queryFn: () => getDashboardFn(),
  });

  const { data: projects } = useQuery({
    queryKey: ["zeus-projects"],
    queryFn: () => getProjectsFn(),
  });

  const { data: connections } = useQuery({
    queryKey: ["zeus-connections"],
    queryFn: () => getConnectionsFn(),
  });
  const connected = (connections ?? []).filter((c) => c.status === "connected");
  const sortedConnections = [...(connections ?? [])]
    .sort((a, b) => Number(b.status === "connected") - Number(a.status === "connected"));

  const ask = async (text?: string) => {
    const q = (text ?? prompt).trim();
    if (!q || busy) return;
    setPrompt("");
    setChat((c) => [...c, { role: "user", text: q }]);
    setError(null);
    setBusy(true);
    cancelledRef.current = false;
    const myRun = ++runRef.current;
    try {
      const res = await askZeusFn({ data: { message: q } });
      // Ignore stale results if the user sent a newer run or cancelled
      if (runRef.current !== myRun || cancelledRef.current) return;
      setChat((c) => [...c, { role: "assistant", text: res.answer }]);
      if (voiceOnRef.current) speak(res.answer, true);
    } catch (e) {
      if (runRef.current !== myRun || cancelledRef.current) return;
      setError((e as Error)?.message ?? "Request failed");
      setChat((c) => [...c, { role: "assistant", text: "ZEUS hit an error on that run.", error: true }]);
    } finally {
      if (runRef.current === myRun) setBusy(false);
    }
  };

  const cancel = () => {
    cancelledRef.current = true;
    runRef.current++; // invalidate the in-flight run
    setBusy(false);
    setChat((c) => [...c, { role: "assistant", text: "⏹ Run stopped — what next?" }]);
  };

  const toggleVoiceInput = () => {
    if (!voiceAvailable) {
      setError("Voice input isn't supported in this browser — use the text box.");
      return;
    }
    if (busy || listening) {
      stopListening();
      setListening(false);
      setInterim("");
      return;
    }
    setListening(true);
    setError(null);
    startListening({
      onInterim: (t) => setInterim(t),
      onFinal: (t) => {
        setInterim("");
        setListening(false);
        ask(t);
      },
      onEnd: () => {
        setListening(false);
        setInterim("");
      },
      onError: (msg) => {
        setListening(false);
        setInterim("");
        setError(msg);
      },
    });
  };

  return (
    <div className="min-h-screen bg-[#0a1120] text-slate-100 data-[theme=default-dark]">
      <div className="mx-auto w-full max-w-[1400px] px-4 py-5">
        {/* Top bar */}
        <header className="mb-5 flex items-center justify-between rounded-xl border border-slate-800 bg-[#0d1526]/80 px-4 py-3">
          <div className="flex items-center gap-3">
            {appFaviconUrl ? <img src={appFaviconUrl} alt="" className="h-6 w-6 rounded" /> : null}
            <span className="text-xs text-emerald-400">SYS_95.7%</span>
            {devMock && (
              <span className="rounded-full border border-amber-400/40 bg-amber-400/10 px-2 py-0.5 text-[9px] font-bold tracking-widest text-amber-300">
                DEV SANDBOX
              </span>
            )}
          </div>
          <h1 className="text-sm font-bold tracking-widest text-cyan-300">ZEUS AI COMMAND CENTER</h1>
          <span className="text-xs text-cyan-400">NET_88.2%</span>
        </header>

        <div className="grid gap-5 lg:grid-cols-[1fr_1.2fr_1fr]">
          {/* LEFT: System status module grid */}
          <section className="rounded-xl border border-slate-800 bg-[#0d1526]/60 p-4">
            <h2 className="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">System Status</h2>
            <div className="grid grid-cols-5 gap-2">
              {MODULES.map((m) => (
                <div key={m.name} title={m.name} className="flex flex-col items-center gap-1 rounded-lg border border-slate-800 bg-[#0f1a2e] p-2">
                  <Icon as={m.icon} size="sm" className="text-cyan-300" />
                  <span className="text-[7px] leading-tight text-center text-slate-400">{m.name}</span>
                  <span className="flex items-center gap-1 text-[7px] text-slate-500">
                    <span className={cn("h-1.5 w-1.5 rounded-full", statusColor[m.status])} />{m.status.toUpperCase()}
                  </span>
                </div>
              ))}
            </div>

            {/* Live KPI strip */}
            <div className="mt-4 grid grid-cols-3 gap-2">
              <div className="rounded-lg border border-slate-800 p-2"><div className="text-[9px] text-slate-500">OPEN DEALS</div><div className="text-lg font-bold text-cyan-300">{isLoading ? "…" : snapshot?.dealCount ?? 0}</div></div>
              <div className="rounded-lg border border-slate-800 p-2"><div className="text-[9px] text-slate-500">PIPELINE £</div><div className="text-lg font-bold text-emerald-400">£{isLoading ? "…" : (snapshot?.openDealValue ?? 0).toLocaleString()}</div></div>
              <div className="rounded-lg border border-slate-800 p-2"><div className="text-[9px] text-slate-500">OPEN TASKS</div><div className="text-lg font-bold text-amber-300">{isLoading ? "…" : snapshot?.taskOpen ?? 0}</div></div>
            </div>
          </section>

          {/* CENTER: Live connections + AI assistant */}
          <section className="flex flex-col gap-4">
            <div className="rounded-xl border border-slate-800 bg-[#0d1526]/60 p-4">
              <h2 className="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Live Connections</h2>
              <div className="grid grid-cols-2 gap-2">
                {connected.length === 0 && connections === undefined && (
                  <div className="col-span-2 text-[11px] text-slate-500">Loading…</div>
                )}
                {connected.slice(0, 10).map((c) => (
                  <a key={c.provider} href={c.url ?? "#"} target="_blank" rel="noreferrer"
                    className="flex items-center gap-2 rounded-lg border border-slate-800 bg-[#0f1a2e] px-2 py-1.5 transition hover:border-cyan-500/40 hover:bg-cyan-500/10">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
                    <span className="text-[11px]">{c.account_label}</span>
                    <span className="ml-auto text-[8px] text-slate-500">↗</span>
                  </a>
                ))}
              </div>
            </div>

            {/* AI Assistant */}
            <div className="flex flex-1 flex-col rounded-xl border border-cyan-500/30 bg-[#0d1526]/70 p-4">
              <div className="mb-2 flex items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <Icon as={Sparkle} size="sm" className="text-cyan-300" />
                  <h2 className="text-xs font-semibold uppercase tracking-widest text-cyan-300">ZEUS Live AI</h2>
                </div>
                <button type="button" onClick={() => setVoiceOn((v) => !v)}
                  className={cn("flex items-center gap-1.5 rounded-full border px-2 py-0.5 text-[9px] font-semibold tracking-widest",
                    voiceOn ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-300" : "border-slate-700 bg-slate-800/60 text-slate-500")}
                  aria-pressed={voiceOn}>
                  <Icon as={voiceOn ? Volume2 : VolumeX} size="sm" />
                  {voiceOn ? "VOICE REPLIES ON" : "VOICE REPLIES OFF"}
                </button>
              </div>
              <div className="mb-2 flex-1 space-y-2 overflow-y-auto" style={{ maxHeight: 220 }}>
                {chat.length === 0 ? (
                  <>
                    <p className="text-[11px] text-slate-500">Ask ZEUS anything — or tap a command:</p>
                    <div className="flex flex-wrap gap-1.5">
                      {["What's my pipeline?", "Show my open tasks", "What's our cashflow?", "Which accounts are connected?", "List our projects"].map((s) => (
                        <button key={s} type="button" onClick={() => setPrompt(s)} className="rounded-full border border-cyan-500/30 bg-cyan-500/5 px-2.5 py-1 text-[10px] text-cyan-200 hover:bg-cyan-500/15">{s}</button>
                      ))}
                    </div>
                  </>
                ) : chat.map((m, i) => (
                  <div key={i} className={cn("rounded-lg px-2 py-1.5 text-[12px]", m.role === "user" ? "bg-cyan-500/10 text-cyan-200" : m.error ? "bg-rose-500/10 text-rose-300" : "bg-slate-800/60 text-slate-200")}>
                    {m.text}
                  </div>
                ))}
                {busy && (
                  <div className="flex items-center gap-2 text-[11px] text-cyan-300">
                    <Loader variant="stars" />
                    <span>ZEUS is working…</span>
                  </div>
                )}
                {error && !busy && (
                  <div className="flex items-center justify-between gap-2 rounded-lg border border-rose-500/30 bg-rose-500/10 px-2 py-1.5 text-[11px] text-rose-300">
                    <span>{error}</span>
                    <button type="button" onClick={() => setError(null)} className="rounded border border-rose-500/40 px-2 py-0.5 text-[10px] hover:bg-rose-500/20">Dismiss</button>
                  </div>
                )}
                {listening && (
                  <div aria-live="polite" className="flex items-center gap-2 rounded-lg border border-rose-400/40 bg-rose-500/10 px-2 py-1.5 text-[11px] text-rose-200">
                    <span className="h-2 w-2 animate-pulse rounded-full bg-rose-400" />
                    <span>{interim || (nativeSpeech ? "Listening… speak your command" : "Recording… tap the mic again when done")}</span>
                  </div>
                )}
              </div>
              <div className="flex items-end gap-2">
                <Textarea label="Command ZEUS" value={prompt} onChange={(e) => setPrompt(e.target.value)} onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); ask(); } }} rows={1} />
                {voiceAvailable && (
                  <Button variant={listening ? "marketingPrimary" : "tertiary"} size="md" onClick={toggleVoiceInput}
                    aria-label="Voice input"
                    title={listening ? "Stop listening" : nativeSpeech ? "Speak your command" : "Record your command"}>
                    <Icon as={Mic} size="sm" className={listening ? "animate-pulse" : ""} />
                  </Button>
                )}
                {busy ? (
                  <Button variant="marketingPrimary" size="md" onClick={cancel}>Stop</Button>
                ) : (
                  <Button variant="marketingPrimary" size="md" onClick={() => ask()} disabled={!prompt.trim()}>Ask</Button>
                )}
              </div>
            </div>
          </section>

          {/* RIGHT: Call schedule */}
          <section className="rounded-xl border border-slate-800 bg-[#0d1526]/60 p-4">
            <h2 className="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Call Schedule</h2>
            <div className="space-y-3">
              {CALLS.map((c) => (
                <div key={c.time} className="flex items-center justify-between rounded-lg border border-slate-800 bg-[#0f1a2e] p-2.5">
                  <div>
                    <div className="text-sm font-semibold">{c.time}</div>
                    <div className="text-[11px] text-slate-300">{c.who}</div>
                    <div className="text-[10px] text-slate-500">{c.phone}</div>
                  </div>
                  <span className={cn("text-[10px] font-bold", c.status === "CONFIRMED" ? "text-emerald-400" : "text-amber-400")}>{c.status}</span>
                </div>
              ))}
            </div>
            <Button variant="tertiary" size="sm" className="mt-3 w-full">View Full Calendar</Button>
          </section>
        </div>

        {/* Portfolio & Accounts: projects + connection registry */}
        <section className="mt-5 rounded-xl border border-slate-800 bg-[#0d1526]/60 p-4">
          <h2 className="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Portfolio & Accounts</h2>
          <div className="grid gap-3 lg:grid-cols-[1.2fr_1fr]">
            {/* Projects */}
            <div className="rounded-lg border border-slate-800 bg-[#0f1a2e] p-3">
              <div className="mb-2 flex items-center justify-between">
                <div className="text-[10px] font-bold uppercase tracking-widest text-slate-500">Projects</div>
                <div className="text-[10px] text-slate-500">{projects?.length ?? "…"} tracked</div>
              </div>
              <div className="grid grid-cols-1 gap-1.5">
                {projects?.map((p) => (
                  <a key={p.id} href={p.url ?? "#"} target="_blank" rel="noreferrer"
                    className="group flex items-center justify-between gap-2 rounded-md border border-slate-800 bg-[#0d1526] px-2 py-1.5 transition hover:border-cyan-500/40 hover:bg-cyan-500/5">
                    <span className="truncate text-[11px] text-slate-300">{p.name}</span>
                    <span className={cn("shrink-0 rounded-full border px-1.5 py-0.5 text-[8px] font-bold uppercase tracking-wider", projectStatusColor[p.status] ?? projectStatusColor.live)}>{p.status}</span>
                  </a>
                ))}
                {!projects && (
                  <div className="text-[11px] text-slate-500">Loading portfolio…</div>
                )}
              </div>
            </div>

            {/* Connections */}
            <div className="rounded-lg border border-slate-800 bg-[#0f1a2e] p-3">
              <div className="mb-2 flex items-center justify-between">
                <div className="text-[10px] font-bold uppercase tracking-widest text-slate-500">Connections</div>
                <div className="text-[10px] text-slate-500">{connected.length} live</div>
              </div>
              <div className="grid grid-cols-2 gap-1.5">
                {sortedConnections.map((c) => (
                  <a key={c.provider} href={c.url ?? "#"} target="_blank" rel="noreferrer"
                    className="flex items-center gap-2 rounded-md border border-slate-800 bg-[#0d1526] px-2 py-1.5 transition hover:border-cyan-500/40 hover:bg-cyan-500/5">
                    <span className={cn("h-1.5 w-1.5 rounded-full", connColor[c.status] ?? "bg-slate-500")} />
                    <span className="truncate text-[11px]">{c.account_label}</span>
                    {c.status === "waiting" && (
                      <span className="rounded-full border border-amber-400/40 px-1 text-[8px] font-bold text-amber-300">AUTH</span>
                    )}
                    <span className="ml-auto text-[8px] text-slate-500">↗</span>
                  </a>
                ))}
                {sortedConnections.length === 0 && (
                  <div className="col-span-2 text-[11px] text-slate-500">Loading connections…</div>
                )}
              </div>
            </div>
          </div>
        </section>

        {/* Bottom: HQ strip — Maps + Earth + automation stack */}
        <section className="mt-5 grid gap-2 lg:grid-cols-[1.4fr_1fr]">
          <div className="rounded-xl border border-slate-800 bg-[#0d1526]/60 p-3">
            <div className="text-[10px] font-bold uppercase tracking-widest text-slate-500">Headquarters — 66 Paul Street, London EC2A 4NA</div>
            <iframe title="HQ map" src="https://www.openstreetmap.org/export/embed.html?bbox=-0.0880%2C51.5185%2C-0.0810%2C51.5235&layer=mapnik&marker=51.5206%2C-0.0843" className="mt-2 h-44 w-full rounded-lg opacity-80" loading="lazy" referrerPolicy="no-referrer-when-downgrade" />
            <a href="https://earth.google.com/web/@51.5206,-0.0843" target="_blank" rel="noreferrer" className="mt-1 inline-flex items-center gap-1 text-[10px] text-slate-500 hover:text-cyan-300">
              <Globe size="sm" className="text-cyan-400" /> Open in Google Earth
            </a>
          </div>
          <div className="rounded-xl border border-slate-800 bg-[#0d1526]/60 p-3">
            <div className="text-[10px] font-bold uppercase tracking-widest text-slate-500">Automation Stack</div>
            <div className="mt-2 grid grid-cols-1 gap-1.5 text-[11px]">
              <span className="rounded border border-slate-800 px-2 py-1 text-slate-300">Playwright E2E — Chromium · Firefox · WebKit</span>
              <span className="rounded border border-slate-800 px-2 py-1 text-emerald-400">Voice suite: 24 tests passing on CI</span>
              <span className="rounded border border-slate-800 px-2 py-1 text-slate-300">Firefox fallback: server transcription (Whisper)</span>
              <a href="https://github.com/jdbsale3-lang/zeus-next-app/actions" target="_blank" rel="noreferrer" className="rounded border border-cyan-500/40 px-2 py-1 text-cyan-200 hover:bg-cyan-500/15 hover:border-cyan-400">Open GitHub Actions</a>
              <a href="https://earth.google.com" target="_blank" rel="noreferrer" className="rounded border border-slate-800 px-2 py-1 text-slate-400 hover:text-cyan-300">Google Earth — satellite view</a>
            </div>
          </div>
        </section>

        {/* Bottom: Zeus sphere */}
        <div className="mt-8 flex flex-col items-center gap-2">
          <ZeusSphere listening={listening} onClick={toggleVoiceInput} />
          <p className="text-[10px] text-slate-500">
            {listening
              ? "● LISTENING — SPEAK YOUR COMMAND ●"
              : voiceAvailable
                ? nativeSpeech
                  ? "▲ TAP THE SPHERE AND TALK TO ZEUS ▲"
                  : "▲ TAP THE SPHERE AND RECORD — VOICE VIA RECORDING ▲"
                : "Voice input isn't supported in this browser — use the chat box"}
          </p>
        </div>

        <footer className="mt-8 flex items-center justify-between border-t border-slate-800 pt-3 text-[9px] text-slate-600">
          <span>DATA STREAM — ENCRYPTION: TLS + HMAC SESSIONS</span>
          <span>ACTIVE PROTOCOLS — UPTIME 99.98%</span>
        </footer>
      </div>
    </div>
  );
}