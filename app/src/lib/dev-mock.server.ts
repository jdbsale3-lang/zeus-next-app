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