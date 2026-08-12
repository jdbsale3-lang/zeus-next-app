// DEV-ONLY sandbox mock for local voice/E2E testing. Never active in production
// builds: import.meta.env.DEV is statically replaced with `false` at build time.
// Activate with: VITE_ZEUS_MOCK=1 bun run dev
import type { DashboardSnapshot } from "./command-center.server";

export const DEV_MOCK = import.meta.env.DEV && import.meta.env.VITE_ZEUS_MOCK === "1";
export const DEV_ORG = "org_dev_sandbox";

type MockDeal = { id: string; title: string; amount: number; stage: string };
type MockTask = { id: string; title: string; status: string; priority: string; due_at?: string };
type MockInvoice = { number: string; status: string; amount: number; due_at?: string };
type MockContact = { id: string; name: string; email?: string; phone?: string };
type MockNote = { id: string; title: string; body: string };
type MockProject = { id: string; name: string; slug?: string | null; url?: string | null; status: string; kind: string };
type MockConnection = { id: string; provider: string; accountLabel?: string | null; status: string; url?: string | null };

export const mockStore = {
  contacts: [] as MockContact[],
  deals: [] as MockDeal[],
  tasks: [] as MockTask[],
  invoices: [] as MockInvoice[],
  notes: [] as MockNote[],
  messages: [] as { id: string; role: string; text: string; created_at: string }[],
};

let seeded = false;
export function ensureMockSeed(): void {
  if (seeded || !DEV_MOCK) return;
  seeded = true;
  mockStore.deals.push(
    { id: "d_mock_1", title: "AEGIS Enterprise", amount: 30000, stage: "proposal" },
    { id: "d_mock_2", title: "NHS Pilot", amount: 100000, stage: "qualified" },
  );
  mockStore.tasks.push({ id: "t_mock_1", title: "Follow up with Skitts", status: "todo", priority: "high" });
  mockStore.invoices.push({ number: "INV-001", status: "sent", amount: 5000 });
  mockStore.contacts.push(
    { id: "c_mock_1", name: "JDB Sales", email: "jdbsale3@gmail.com", phone: "01922 445318" },
    { id: "c_mock_2", name: "ZEUS AI Intelligence", phone: "01902 631151" },
    { id: "c_mock_3", name: "ZEUSTRUSTAEGIS SECURITY LTD", phone: "01902 639877" },
  );
}

export function mockDashboard(): DashboardSnapshot {
  ensureMockSeed();
  return {
    dealCount: mockStore.deals.length,
    openDealValue: mockStore.deals
      .filter((d) => d.stage !== "won" && d.stage !== "lost")
      .reduce((s, d) => s + d.amount, 0),
    taskOpen: mockStore.tasks.filter((t) => t.status !== "done").length,
    contactCount: mockStore.contacts.length,
    invoiceUnpaid: mockStore.invoices.filter((i) => i.status === "sent" || i.status === "overdue").length,
    invoiceUnpaidAmount: mockStore.invoices
      .filter((i) => i.status === "sent" || i.status === "overdue")
      .reduce((s, i) => s + i.amount, 0),
    noteCount: mockStore.notes.length,
    recentMessages: mockStore.messages
      .slice(-8)
      .map((m) => ({ id: m.id, role: m.role, text: m.text, createdAt: m.created_at }))
      .reverse(),
  };
}

export function mockProjects(): { id: string; name: string; slug: string | null; url: string | null; category: string; status: string; description: string | null }[] {
  return [
    { id: "p_mock_1", name: "ZEUS AI Command Center", slug: "zeus-next-app", url: "https://zeus-next-app.higgsfield.app", category: "app", status: "live", description: "Voice-first business OS — this app." },
    { id: "p_mock_2", name: "AEGIS AI Security", slug: "aegis-security", url: "https://aegis-security.higgsfield.app", category: "security", status: "live", description: "8 modules · 24 layers · GDPR/CE-ready." },
    { id: "p_mock_3", name: "NHS ID Card System", slug: "nhs-id-card", url: "https://zeusai-intelligence.org/nhs", category: "nhs", status: "planning", description: "50M smart cards · £24.4B 10-yr value." },
  ];
}

export function mockConnections(): { id: string; provider: string; account_label: string; kind: string; status: string; url: string | null; note: string | null }[] {
  return [
    { id: "c_mock_1", provider: "gmail", account_label: "Gmail", kind: "saas", status: "connected", url: "https://mail.google.com", note: "Email inbound/outbound" },
    { id: "c_mock_2", provider: "x", account_label: "X (Twitter)", kind: "platform", status: "connected", url: "https://x.com/jdbsales3", note: "@jdbsales3" },
    { id: "c_mock_3", provider: "discord_bot", account_label: "Discord", kind: "saas", status: "waiting", url: "https://discord.com", note: "Authorization link sent" },
  ];
}

export function mockAskZeus(message: string): string {
  ensureMockSeed();
  const lower = message.toLowerCase();
  if (lower.includes("task")) {
    const open = mockStore.tasks.filter((t) => t.status !== "done");
    return `You have ${open.length} open task${open.length === 1 ? "" : "s"}: ${open.map((t) => t.title).join(", ") || "none right now"}.`;
  }
  if (lower.includes("pipeline") || lower.includes("deal")) {
    const open = mockStore.deals.filter((d) => d.stage !== "won" && d.stage !== "lost");
    return `${open.length} deal${open.length === 1 ? "" : "s"} in the pipeline, worth £${open.reduce((s, d) => s + d.amount, 0).toLocaleString()} total.`;
  }
  if (lower.includes("cashflow") || lower.includes("invoice")) {
    const unpaid = mockStore.invoices.filter((i) => i.status === "sent" || i.status === "overdue");
    return `Outstanding receivables: £${unpaid.reduce((s, i) => s + i.amount, 0).toLocaleString()} across ${unpaid.length} invoice${unpaid.length === 1 ? "" : "s"}.`;
  }
  return `Voice test received: "${message}". In the live build ZEUS answers from your real pipeline.`;
}

export function mockTranscribe(_audioBase64: string, _mimeType: string): string {
  return "Show my open tasks";
}

export function mockCreateContact(data: { name: string; email?: string; phone?: string }) {
  ensureMockSeed();
  const c: MockContact = { id: crypto.randomUUID(), name: data.name, email: data.email, phone: data.phone };
  mockStore.contacts.push(c);
  return { id: c.id };
}

export function mockCreateTask(data: { title: string; priority?: string; due_at?: string }) {
  ensureMockSeed();
  const t: MockTask = { id: crypto.randomUUID(), title: data.title, status: "todo", priority: data.priority ?? "medium", due_at: data.due_at };
  mockStore.tasks.push(t);
  return { id: t.id };
}

export function mockCreateDeal(data: { title: string; amount?: number; stage?: string }) {
  ensureMockSeed();
  const d: MockDeal = { id: crypto.randomUUID(), title: data.title, amount: data.amount ?? 0, stage: data.stage ?? "lead" };
  mockStore.deals.push(d);
  return { id: d.id };
}

export function mockCreateNote(data: { title?: string; body: string }) {
  ensureMockSeed();
  const n: MockNote = { id: crypto.randomUUID(), title: data.title ?? "", body: data.body };
  mockStore.notes.push(n);
  return { id: n.id };
}

// ---- Project fleet & connection registry sandbox mirrors (no D1) ----
export function mockProjects(): MockProject[] {
  return [
    { id: "p1", name: "ZEUS OS (app)", slug: "zeus-next-app", url: "https://zeus-next-app.higgsfield.app", status: "live", kind: "app" },
    { id: "p2", name: "ZEUS AI Intelligence", slug: "zeusai-intelligence", url: "https://zeusai-intelligence.higgsfield.app", status: "live", kind: "website" },
    { id: "p3", name: "AEGIS Security", slug: "aegis-security", url: "https://aegis-security.higgsfield.app", status: "live", kind: "website" },
    { id: "p4", name: "AEGIS API Docs", slug: "aegis-api-docs", url: "https://aegis-api-docs.higgsfield.app", status: "live", kind: "docs" },
    { id: "p5", name: "ZEUS Gantt Docs", slug: "zeus-gantt-docs", url: "https://zeus-gantt-docs.higgsfield.app", status: "live", kind: "docs" },
    { id: "p6", name: "Intelligence CRM", slug: "intelligence-crm", url: "https://intelligence-crm.higgsfield.app", status: "live", kind: "website" },
    { id: "p7", name: "ZEUS Mind", slug: "zeus-mind", url: "https://zeus-mind.higgsfield.app", status: "live", kind: "website" },
    { id: "p8", name: "CalorieLens", slug: "calorielens", url: "https://calorielens.higgsfield.app", status: "live", kind: "website" },
  ];
}

export function mockConnections(): MockConnection[] {
  return [
    { id: "c1", provider: "Gmail", accountLabel: "jdbsale3@gmail.com", status: "connected", url: null },
    { id: "c2", provider: "YouTube", accountLabel: "ZeusAI (@jdbsale)", status: "connected", url: "https://www.youtube.com/@jdbsale" },
    { id: "c3", provider: "X / Twitter", accountLabel: "@jdbsales3", status: "connected", url: "https://x.com/jdbsales3" },
    { id: "c4", provider: "LinkedIn", accountLabel: "Darren Birch (JDB Sales)", status: "connected", url: "https://www.linkedin.com" },
    { id: "c5", provider: "TikTok", accountLabel: "JDB Sales", status: "connected", url: "https://www.tiktok.com" },
    { id: "c6", provider: "HubSpot CRM", accountLabel: "JDB Sales", status: "connected", url: null },
    { id: "c7", provider: "Discord", accountLabel: "ZEUS server", status: "needs_auth", url: "https://pipedream.com/_static/connect.html?token=ctok_89ce2ade07454c7981edb5c0d05dd39f&connectLink=true&app=discord_bot" },
    { id: "c8", provider: "TikTok Ads", accountLabel: "Business ads", status: "needs_auth", url: null },
  ];
}