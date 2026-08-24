app/migration/-- 0010_governance.sql — ZEUS governance hardening
-- Adds: full agent audit logging via DB triggers + department policy rules.
-- Apply: wrangler d1 execute zeus-db --file=./migrations/0010_governance.sql --remote

-- ============ 1. FULL AGENT AUDIT LOGGING (trigger-based) ============
-- Every insert/update on business-critical tables is recorded in tool_audit.

CREATE TRIGGER IF NOT EXISTS audit_deals_ins AFTER INSERT ON deals BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('db.deals.insert', NEW.id, 'ok', 'deal created');
END;

CREATE TRIGGER IF NOT EXISTS audit_deals_upd AFTER UPDATE ON deals BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('db.deals.update', NEW.id, 'ok', 'deal modified');
END;

CREATE TRIGGER IF NOT EXISTS audit_tasks_ins AFTER INSERT ON tasks BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('db.tasks.insert', NEW.id, 'ok', 'task created');
END;

CREATE TRIGGER IF NOT EXISTS audit_contacts_ins AFTER INSERT ON contacts BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('db.contacts.insert', NEW.id, 'ok', 'contact created');
END;

CREATE TRIGGER IF NOT EXISTS audit_connections_chg AFTER UPDATE ON connections BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('db.connections.update', OLD.id || ' -> ' || NEW.status, 'ok', 'connection status changed');
END;

CREATE TRIGGER IF NOT EXISTS audit_invoices_ins AFTER INSERT ON invoices BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('db.invoices.insert', NEW.id, 'ok', 'invoice raised');
END;

CREATE TRIGGER IF NOT EXISTS audit_shopify_sync AFTER INSERT ON shopify_sync_log BEGIN
  INSERT INTO tool_audit (tool, args, outcome, note)
  VALUES ('shopify.sync', NEW.rowid, 'ok', 'catalog sync event');
END;

-- ============ 2. GOVERNANCE POLICY RULES ============
-- Schema: id TEXT pk, rule TEXT, apply_to TEXT default 'all',
--         limit_value REAL, action TEXT default 'block', enabled INT, note TEXT

INSERT OR IGNORE INTO policy_rules (id, rule, apply_to, limit_value, action, enabled, note) VALUES
('pol_spend_dept_500','No single agent-initiated spend above 500 GBP without owner approval','all',500,'approve',1,'AEGIS guardrail: spend cap per action'),
('pol_monthly_budget_2000','Agent monthly operating spend must not exceed 2000 GBP','all',2000,'block',1,'Monthly burn ceiling'),
('pol_sales_discount_20','Sales agent cannot approve discounts over 20 percent; escalate to Darren','Sales',20,'approve',1,'Pricing authority limit'),
('pol_finance_payment_1000','Finance agent cannot release payments above 1000 GBP without dual approval','Finance',1000,'approve',1,'Payment authority'),
('pol_payroll_human','Payroll and HMRC filings are prepare-only; human submission required','Payroll',NULL,'block',1,'Statutory compliance boundary'),
('pol_hr_no_pii_export','HR agent must not export employee PII outside the Second Brain','HR',NULL,'block',1,'GDPR / UK DPA 2018'),
('pol_dev_deploy_prod','Development agent requires explicit owner approval for production deploys','Development',NULL,'approve',1,'Change control'),
('pol_marketing_publish','Marketing agent may draft but not publish to X/LinkedIn/TikTok without review','Marketing',NULL,'approve',1,'Brand safety gate'),
('pol_seo_bulk_changes','SEO agent limited to 50 bulk page changes per run','SEO',50,'block',1,'Prevents runaway automation'),
('pol_data_delete','No bulk deletes over 100 rows without owner approval','all',100,'approve',1,'Data-loss protection'),
('pol_external_send','Outbound email to more than 50 recipients per hour is blocked','all',50,'block',1,'Spam/reputation guard'),
('pol_audit_immutable','tool_audit rows must never be updated or deleted by agents','all',NULL,'block',1,'Audit trail integrity');

-- ============ 3. AUDIT RETENTION INDEX ============
CREATE INDEX IF NOT EXISTS idx_tool_audit_ts ON tool_audit(ts);
CREATE INDEX IF NOT EXISTS idx_tool_audit_tool ON tool_audit(tool);

-- ============ 4. AUDIT IMMUTABILITY (enforces pol_audit_immutable) ============
-- tool_audit is write-once: agents cannot UPDATE or DELETE audit rows.
CREATE TRIGGER IF NOT EXISTS audit_immutable_upd BEFORE UPDATE ON tool_audit BEGIN
  SELECT RAISE(ABORT, 'tool_audit is immutable: updates blocked by pol_audit_immutable');
END;
CREATE TRIGGER IF NOT EXISTS audit_immutable_del BEFORE DELETE ON tool_audit BEGIN
  SELECT RAISE(ABORT, 'tool_audit is immutable: deletes blocked by pol_audit_immutable');
END;
