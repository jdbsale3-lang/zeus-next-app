import { useEffect, useMemo, useRef, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@higgsfield/quanta/button";
import { Input } from "@higgsfield/quanta/input";
import { Loader } from "@higgsfield/quanta/loader";
import { Textarea } from "@higgsfield/quanta/textarea";
import { Typography } from "@higgsfield/quanta/typography";
import { Icon } from "@higgsfield/quanta/icon";
import { Sparkle, Shield, Activity, Gauge, Radio, Zap, Database, Users, Briefcase, CheckSquare, FileText, Wallet, Brain, LayoutGrid, MessageSquare, Bell, Calendar, Inbox, FolderOpen, Video, Newspaper, Headphones, Webhook, BarChart3, Clock, BookOpen, HeartPulse, Lock } from "lucide-react";
import { cn } from "@/lib/utils";
import { appFaviconUrl, appMeta } from "@/lib/app-meta";
import { askZeusFn, createContactFn, createDealFn, createNoteFn, createTaskFn, getDashboardFn } from "@/lib/command-center.functions";
import type { DashboardSnapshot } from "@/lib/command-center.functions";

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

const INTEGRATIONS = [
  "Gmail", "HubSpot", "Slack", "Stripe", "Google Calendar",
  "Google Drive", "Notion", "Claude AI", "Email (SMTP)", "Voice Engine",
];

const CALLS = [
  { time: "10:00", who: "Skitts Estate Agents", phone: "01902 631151", status: "CONFIRMED" },
  { time: "10:30", who: "Webbs Estate Agents", phone: "01922 929888", status: "CONFIRMED" },
  { time: "11:00", who: "KST Accountancy", phone: "01902 639877", status: "PENDING" },
];

const statusColor: Record<string, string> = {
  online: "bg-emerald-400", standby: "bg-amber-400", attention: "bg-rose-400",
};

function ZeusSphere({ onClick }: { onClick: () => void }) {
  return (
    <button type="button" onClick={onClick} aria-label="Talk to ZEUS"
      className="group mx-auto flex h-24 w-24 items-center justify-center rounded-full border border-cyan-400/40 bg-cyan-500/10 transition hover:bg-cyan-500/20"
      style={{ boxShadow: "0 0 40px rgba(34,211,238,.35), inset 0 0 30px rgba(34,211,238,.2)" }}>
      <span className="text-2xl font-bold text-cyan-300">ZEUS</span>
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

  const { data: snapshot, isLoading } = useQuery({
    queryKey: ["zeus-dashboard"],
    queryFn: () => getDashboardFn(),
  });

  const ask = async () => {
    if (!prompt.trim() || busy) return;
    const q = prompt;
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

  return (
    <div className="min-h-screen bg-[#0a1120] text-slate-100 data-[theme=default-dark]">
      <div className="mx-auto w-full max-w-[1400px] px-4 py-5">
        {/* Top bar */}
        <header className="mb-5 flex items-center justify-between rounded-xl border border-slate-800 bg-[#0d1526]/80 px-4 py-3">
          <div className="flex items-center gap-3">
            {appFaviconUrl ? <img src={appFaviconUrl} alt="" className="h-6 w-6 rounded" /> : null}
            <span className="text-xs text-emerald-400">SYS_95.7%</span>
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

          {/* CENTER: Live integrations + AI assistant */}
          <section className="flex flex-col gap-4">
            <div className="rounded-xl border border-slate-800 bg-[#0d1526]/60 p-4">
              <h2 className="mb-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Live Integrations</h2>
              <div className="grid grid-cols-2 gap-2">
                {INTEGRATIONS.map((i) => (
                  <div key={i} className="flex items-center gap-2 rounded-lg border border-slate-800 bg-[#0f1a2e] px-2 py-1.5">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
                    <span className="text-[11px]">{i}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* AI Assistant */}
            <div className="flex flex-1 flex-col rounded-xl border border-cyan-500/30 bg-[#0d1526]/70 p-4">
              <div className="mb-2 flex items-center gap-2">
                <Icon as={Sparkle} size="sm" className="text-cyan-300" />
                <h2 className="text-xs font-semibold uppercase tracking-widest text-cyan-300">ZEUS Live AI</h2>
              </div>
              <div className="mb-2 flex-1 space-y-2 overflow-y-auto" style={{ maxHeight: 220 }}>
                {chat.length === 0 ? (
                  <>
                    <p className="text-[11px] text-slate-500">Ask ZEUS anything — or tap a command:</p>
                    <div className="flex flex-wrap gap-1.5">
                      {["What's my pipeline?", "Show my open tasks", "What's our cashflow?", "Create a task: follow up with Acme"].map((s) => (
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
                    <span>That run failed.</span>
                    <button type="button" onClick={() => setError(null)} className="rounded border border-rose-500/40 px-2 py-0.5 text-[10px] hover:bg-rose-500/20">Dismiss</button>
                  </div>
                )}
              </div>
              <div className="flex items-end gap-2">
                <Textarea label="Command ZEUS" value={prompt} onChange={(e) => setPrompt(e.target.value)} onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); ask(); } }} rows={1} />
                {busy ? (
                  <Button variant="marketingPrimary" size="md" onClick={cancel}>Stop</Button>
                ) : (
                  <Button variant="marketingPrimary" size="md" onClick={ask} disabled={!prompt.trim()}>Ask</Button>
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

        {/* Bottom: Zeus sphere */}
        <div className="mt-8 flex flex-col items-center gap-2">
          <ZeusSphere onClick={() => { setChat((c) => [...c, { role: "assistant", text: "ZEUS online. What shall we run today?" }]); }} />
          <p className="text-[10px] text-slate-500">▲ CLICK THE SPHERE TO TALK TO ZEUS ▲</p>
        </div>

        <footer className="mt-8 flex items-center justify-between border-t border-slate-800 pt-3 text-[9px] text-slate-600">
          <span>DATA STREAM — ENCRYPTION: TLS + HMAC SESSIONS</span>
          <span>ACTIVE PROTOCOLS — UPTIME 99.98%</span>
        </footer>
      </div>
    </div>
  );
}