-- 0018: Sample Second Brain memory, build request, and file store records.
-- Idempotent: INSERT OR IGNORE on fixed IDs so re-running never duplicates.
-- Scope is the demo org used by the founder during tests.

INSERT OR IGNORE INTO memory (id, org_id, kind, key, body, source) VALUES
  ('mem_demo_001', 'org_demo_test', 'fact', 'company_location', 'ZEUS headquarters is based in the United Kingdom, operated by JDB Sales.', 'zeus'),
  ('mem_demo_002', 'org_demo_test', 'preference', 'communication', 'Darren requires ZEUS to respond in plain words only, no symbols, no asterisks, no formatting characters.', 'zeus'),
  ('mem_demo_003', 'org_demo_test', 'standing_instruction', 'accuracy', 'Never claim an action was done unless the tool actually succeeded. Report only grounded facts.', 'zeus'),
  ('mem_demo_004', 'org_demo_test', 'fact', 'holding_company', 'Holding company is ZEUSTRUSTAEGISSECURITY LTD, Companies House number 17391549, 66 Paul Street, London EC2A 4NA.', 'zeus');

INSERT OR IGNORE INTO build_requests (id, org_id, title, build_type, spec, status) VALUES
  ('bld_demo_001', 'org_demo_test', 'Zeus Demo Site', 'website', 'A one page test site proving the build request pipeline.', 'queued'),
  ('bld_demo_002', 'org_demo_test', 'Zeus Brand Video', 'video', 'A short 9 by 16 promo video for the ZEUS brand test.', 'queued');

INSERT OR IGNORE INTO files (id, org_id, name, kind, url, size_bytes) VALUES
  ('file_demo_001', 'org_demo_test', 'demo-note.txt', 'document', NULL, 41),
  ('file_demo_002', 'org_demo_test', 'zeus-brand-cover.png', 'image', 'https://zeus-next-app.higgsfield.app/og', 0);