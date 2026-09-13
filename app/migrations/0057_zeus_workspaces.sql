-- 0057: ZEUS WORKSPACE REGISTRY — one voice command opens the whole stack.
-- A workspace is a named bundle of launch targets (apps, sites, tools).
CREATE TABLE IF NOT EXISTS workspace_targets (
  id TEXT PRIMARY KEY,
  workspace TEXT NOT NULL,          -- bundle name, e.g. 'core' | 'aegis' | 'docs'
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  kind TEXT NOT NULL DEFAULT 'site', -- site | app | tool | docs
  enabled INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS idx_ws_target ON workspace_targets(workspace, enabled);

INSERT OR IGNORE INTO workspace_targets (id, workspace, name, url, kind, enabled) VALUES
('ws_core_os','core-business','ZEUS OS','https://zeus-os.higgsfield.app','app',1),
('ws_core_cc','core-business','Command Center','https://zeus-next-app.higgsfield.app','app',1),
('ws_core_intel','core-business','Intelligence CRM','https://intelligence-crm.higgsfield.app','app',1),
('ws_core_mind','core-business','ZEUS Mind','https://zeus-mind.higgsfield.app','app',1),
('ws_core_cal','core-business','CalorieLens','https://calorielens.higgsfield.app','app',1),
('ws_core_meals','core-business','20-Min Meals','https://zeus-20min-meals.higgsfield.app','app',1),
('ws_core_zeusai','core-business','ZEUS AI Intelligence','https://zeusaiintelligence.org','site',1),
('ws_core_sales','core-business','JDB Sales','https://zeusai-intelligence.higgsfield.app','site',1),
('ws_aeg_1','aegis','AEGIS Security','https://aegis-security.higgsfield.app','app',1),
('ws_aeg_2','aegis','AEGIS API Docs','https://aegis-api-docs.higgsfield.app','docs',1),
('ws_aeg_3','aegis','AEGIS API Live','https://apiaegissecurity.tech','site',1),
('ws_doc_1','docs','Docs Portal','https://zeus-gantt-docs.higgsfield.app','docs',1),
('ws_doc_2','docs','Gantt Planner','https://zeus-gantt-plan.higgsfield.app','app',1),
('ws_doc_3','docs','Travel Health','https://zeus-travel-health.higgsfield.app','app',1),
('ws_mkt_1','marketing','ZEUS Marketing','https://zeus-os-marketing.higgsfield.app','site',1),
('ws_mkt_2','marketing','Task Force Board','https://zeus-next-app.higgsfield.app/seo-taskforce','app',1);