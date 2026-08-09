import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import {
  getDashboard,
  createContact,
  createTask,
  createDeal,
  createNote,
  askZeus,
} from "./command-center.server";

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
  (): Promise<DashboardSnapshot> => getDashboard(),
);

export const createContactFn = createServerFn({ method: "POST" })
  .validator(z.object({ name: z.string().min(1), email: z.string().optional(), phone: z.string().optional(), type: z.string().default("person") }))
  .handler(({ data }) => createContact(data));

export const createTaskFn = createServerFn({ method: "POST" })
  .validator(z.object({ title: z.string().min(1), priority: z.string().default("medium"), due_at: z.string().optional() }))
  .handler(({ data }) => createTask(data));

export const createDealFn = createServerFn({ method: "POST" })
  .validator(z.object({ title: z.string().min(1), amount: z.coerce.number().default(0), stage: z.string().default("lead") }))
  .handler(({ data }) => createDeal(data));

export const createNoteFn = createServerFn({ method: "POST" })
  .validator(z.object({ title: z.string().default(""), body: z.string().min(1) }))
  .handler(({ data }) => createNote(data));

export const askZeusFn = createServerFn({ method: "POST" })
  .validator(z.object({ message: z.string().min(1).max(2000) }))
  .handler(({ data }) => askZeus(data.message));