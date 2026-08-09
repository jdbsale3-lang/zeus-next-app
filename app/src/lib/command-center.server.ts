import { createLlmClient } from "@higgsfield/fnf";
import { bindings } from "./bindings.server";

// ---- Auth: resolve the current org id from the fnf user proxy ----
async function currentOrgId(): Promise<string> {
  const res = await fetch("https://fnf.internal/user");
  if (res.status !== 200) throw new Error("unauthorized");
  const user = (await res.json()) as { id?: string; email?: string };
  const id = user?.id ?? user?.email ?? "local";
  return `org_${id.slice(0, 24)}`;
}

function db() {
  const { DB } = bindings();
  if (!DB) throw new Error("D1 not bound");
  return DB;
}

// ---- Dashboard overview ----
export interface DashboardSnapshot {
  dealCount: number;
  openDealValue: number;
  taskOpen: number;
  contactCount: number;
  invoiceUnpaid: number;
  invoiceUnpaidAmount: number;
  noteCount: number;
  recentMessages: { id: string; role: string; text: string; createdAt: string }[];
}

export async function getDashboard(): Promise<DashboardSnapshot> {
  const org = await currentOrgId();
  const d = db();
  const [deals, tasks, contacts, inv, notes, msgs] = await Promise.all([
    d.prepare("SELECT COUNT(*) c, COALESCE(SUM(amount),0) v FROM deals WHERE org_id = ? AND stage NOT IN ('won','lost')").bind(org).first(),
    d.prepare("SELECT COUNT(*) c FROM tasks WHERE org_id = ? AND status != 'done'").bind(org).first(),
    d.prepare("SELECT COUNT(*) c FROM contacts WHERE org_id = ?").bind(org).first(),
    d.prepare("SELECT COUNT(*) c, COALESCE(SUM(amount),0) v FROM invoices WHERE org_id = ? AND status IN ('sent','overdue')").bind(org).first(),
    d.prepare("SELECT COUNT(*) c FROM notes WHERE org_id = ?").bind(org).first(),
    d.prepare("SELECT id, role, text, created_at FROM assistant_messages WHERE org_id = ? ORDER BY created_at DESC LIMIT 8").bind(org).all(),
  ]);
  return {
    dealCount: Number(deals?.c ?? 0),
    openDealValue: Number(deals?.v ?? 0),
    taskOpen: Number(tasks?.c ?? 0),
    contactCount: Number(contacts?.c ?? 0),
    invoiceUnpaid: Number(inv?.c ?? 0),
    invoiceUnpaidAmount: Number(inv?.v ?? 0),
    noteCount: Number(notes?.c ?? 0),
    recentMessages: (msgs?.results ?? []).map((r: any) => ({
      id: r.id, role: r.role, text: r.text, createdAt: r.created_at,
    })),
  };
}

// ---- CRUD helpers ----
export async function createContact(data: { name: string; email?: string; phone?: string; type?: string }) {
  const org = await currentOrgId();
  const id = crypto.randomUUID();
  await db().prepare("INSERT INTO contacts (id, org_id, type, name, email, phone) VALUES (?,?,?,?,?,?)")
    .bind(id, org, data.type ?? "person", data.name, data.email ?? null, data.phone ?? null).run();
  return { id };
}

export async function createTask(data: { title: string; priority?: string; due_at?: string }) {
  const org = await currentOrgId();
  const id = crypto.randomUUID();
  await db().prepare("INSERT INTO tasks (id, org_id, title, priority, due_at) VALUES (?,?,?,?,?)")
    .bind(id, org, data.title, data.priority ?? "medium", data.due_at ?? null).run();
  return { id };
}

export async function createDeal(data: { title: string; amount?: number; stage?: string }) {
  const org = await currentOrgId();
  const id = crypto.randomUUID();
  await db().prepare("INSERT INTO deals (id, org_id, title, amount, stage) VALUES (?,?,?,?,?)")
    .bind(id, org, data.title, data.amount ?? 0, data.stage ?? "lead").run();
  return { id };
}

export async function createNote(data: { title?: string; body: string }) {
  const org = await currentOrgId();
  const id = crypto.randomUUID();
  await db().prepare("INSERT INTO notes (id, org_id, title, body) VALUES (?,?,?,?)")
    .bind(id, org, data.title ?? "", data.body).run();
  return { id };
}

// ---- AI Assistant: query the D1 snapshot + call the LLM ----
export async function askZeus(message: string) {
  const org = await currentOrgId();
  const d = db();

  const userId = crypto.randomUUID();
  await d.prepare("INSERT INTO assistant_messages (id, org_id, channel, role, text) VALUES (?,?,?,?,?)")
    .bind(userId, org, "chat", "user", message).run();

  const [deals, tasks, contacts, inv, notes] = await Promise.all([
    d.prepare("SELECT title, stage, amount FROM deals WHERE org_id = ? ORDER BY amount DESC LIMIT 10").bind(org).all(),
    d.prepare("SELECT title, status, priority FROM tasks WHERE org_id = ? ORDER BY created_at DESC LIMIT 10").bind(org).all(),
    d.prepare("SELECT name, email, phone FROM contacts WHERE org_id = ? LIMIT 10").bind(org).all(),
    d.prepare("SELECT number, status, amount FROM invoices WHERE org_id = ? ORDER BY created_at DESC LIMIT 10").bind(org).all(),
    d.prepare("SELECT title, body FROM notes WHERE org_id = ? ORDER BY created_at DESC LIMIT 5").bind(org).all(),
  ]);

  const snapshot = JSON.stringify({
    deals: deals?.results, tasks: tasks?.results, contacts: contacts?.results,
    invoices: inv?.results, recentNotes: notes?.results,
  });

  const llm = createLlmClient({ baseUrl: "https://fnf.internal/llm" });
  const models = await llm.listModels();
  const model = models[0] ?? "gpt-4o-mini";

  const res = await llm.complete({
    model,
    messages: [
      { role: "system", content: `You are ZEUS, the AI command-center assistant for a small company (JDB Sales / ZEUS AI Intelligence, founder Darren Birch). You help run the business: pipeline, deals, tasks, contacts, invoices, notes. Answer from the provided company data snapshot only — never invent numbers. Be concise, warm, and direct. Here is the live company data snapshot:\n${snapshot}` },
      { role: "user", content: message },
    ],
  });

  const answer = res?.content?.trim() || "I couldn't find an answer right now.";
  const aid = crypto.randomUUID();
  await d.prepare("INSERT INTO assistant_messages (id, org_id, channel, role, text) VALUES (?,?,?,?,?)")
    .bind(aid, org, "chat", "assistant", answer).run();

  return { answer, messageId: aid };
}