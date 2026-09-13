-- 0043: Register the programme knowledge base in ZEUS file storage so the
-- Commander's list_files/store_file can serve every programme document needed
-- to get work done. All urls are the real durable CDN copies uploaded this
-- session; none are invented.
INSERT OR IGNORE INTO files (id, org_id, name, kind, url, size_bytes) VALUES
('fl_nhs_deck_pdf', 'org_zeus_shared', 'NHS Investor Deck and Press Package.pdf', 'file', 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/16c8362f-ac83-48fa-bf85-2307352b4fbc.pdf', 9516),
('fl_nhs_deck_md', 'org_zeus_shared', 'NHS Investor Deck and Press Package.md', 'document', 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/fb1c240c-9d6a-40c2-aa42-ddb9ddec3473.md', 6095),
('fl_zeus_exec', 'org_zeus_shared', 'ZEUS Executive One Page.md', 'document', 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/24c543ad-b2e6-4157-b31c-8390e994b44c.md', 1830),
('fl_company_os', 'org_zeus_shared', 'ZEUS Full Company OS.md', 'document', 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/403d052d-53c5-4111-8f09-29a6aeb0a57e.md', 2434),
('fl_radar_01', 'org_zeus_shared', 'ZEUS Radar Run 01.md', 'document', 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/f42e4ff4-f6c1-4979-81f7-7cfa0cc63b82.md', 2103),
('fl_cost_audit', 'org_zeus_shared', 'Cost Consolidation Audit.md', 'document', 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/c738198f-31a5-4ace-8b8f-be27a97619c7.md', 2255);