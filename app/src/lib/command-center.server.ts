import { createLlmClient } from "@higgsfield/fnf";
import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { bindings } from "./bindings.server";

// ---- Auth: resolve the current org id from the fnf user proxy ----
async function currentOrgId(): Promise<string> {
  const res = await fetch("https://fnf.internal/user");
  if (res.status !== 200) throw new Error("unauthorized");
  const user = (await res.json()) as { id?: string; email?: string };
  const id = user?.id ?? user?.email ?? "local";
  // Namespace the org by the user id so each signed-in user owns their data.
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

export const getDashboardFn = createServerFn({ method: "POST" }).handler(
  async (): Promise<DashboardSnapshot> => {
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
  },
);

// ---- CRUD helpers ----
export const createContactFn = createServerFn({ method: "POST" })
  .validator(z.object({ name: z.string().min(1), email: z.string().optional(), phone: z.string().optional(), type: z.string().default("person") }))
  .handler(async ({ data }) => {
    const org = await currentOrgId();
    const id = crypto.randomUUID();
    await db().prepare("INSERT INTO contacts (id, org_id, type, name, email, phone) VALUES (?,?,?,?,?,?)")
      .bind(id, org, data.type, data.name, data.email ?? null, data.phone ?? null).run();
    return { id };
  });

export const createTaskFn = createServerFn({ method: "POST" })
  .validator(z.object({ title: z.string().min(1), priority: z.string().default("medium"), due_at: z.string().optional() }))
  .handler(async ({ data }) => {
    const org = await currentOrgId();
    const id = crypto.randomUUID();
    await db().prepare("INSERT INTO tasks (id, org_id, title, priority, due_at) VALUES (?,?,?,?,?)")
      .bind(id, org, data.title, data.priority, data.due_at ?? null).run();
    return { id };
  });

export const createDealFn = createServerFn({ method: "POST" })
  .validator(z.object({ title: z.string().min(1), amount: z.coerce.number().default(0), stage: z.string().default("lead") }))
  .handler(async ({ data }) => {
    const org = await currentOrgId();
    const id = crypto.randomUUID();
    await db().prepare("INSERT INTO deals (id, org_id, title, amount, stage) VALUES (?,?,?,?,?)")
      .bind(id, org, data.title, data.amount, data.stage).run();
    return { id };
  });

export const createNoteFn = createServerFn({ method: "POST" })
  .validator(z.object({ title: z.string().default(""), body: z.string().min(1) }))
  .handler(async ({ data }) => {
    const org = await currentOrgId();
    const id = crypto.randomUUID();
    await db().prepare("INSERT INTO notes (id, org_id, title, body) VALUES (?,?,?,?)")
      .bind(id, org, data.title, data.body).run();
    return { id };
  });

// ---- AI Assistant: query the D1 snapshot + call the LLM ----
export const askZeusFn = createServerFn({ method: "POST" })
  .validator(z.object({ message: z.string().min(1).max(2000) }))
  .handler(async ({ data }) => {
    const org = await currentOrgId();
    const d = db();

    // Persist the user message
    const userId = crypto.randomUUID();
    await d.prepare("INSERT INTO assistant_messages (id, org_id, channel, role, text) VALUES (?,?,?,?,?)")
      .bind(userId, org, "chat", "user", data.message).run();

    // Build a grounded snapshot the model can answer from
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
        { role: "user", content: data.message },
      ],
    });

    const answer = res?.content?.trim() || "I couldn't find an answer right now.";
    const aid = crypto.randomUUID();
    await d.prepare("INSERT INTO assistant_messages (id, org_id, channel, role, text) VALUES (?,?,?,?,?)")
      .bind(aid, org, "chat", "assistant", answer).run();

    return { answer, messageId: aid };
  });