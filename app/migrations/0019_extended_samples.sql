-- 0019: Extended sample build + file records for the Commander test report.
-- Idempotent: INSERT OR IGNORE on fixed IDs so re-running never duplicates.

INSERT OR IGNORE INTO build_requests (id, org_id, title, build_type, spec, status, output_url) VALUES
  ('bld_demo_003', 'org_demo_test', 'NHS ID Card landing site', 'website', 'Hero page plus pricing and commercial tiers page, Direction 1 clinical style.', 'done', 'https://nhs-id-card.higgsfield.app'),
  ('bld_demo_004', 'org_demo_test', 'AEGIS AI Security site', 'website', 'Product site for AEGIS with 8 modules and 24 layers messaging.', 'done', 'https://aegis-security.higgsfield.app'),
  ('bld_demo_005', 'org_demo_test', 'ZEUS travel health card site', 'website', 'Travel health wallet landing page with GHIC and cover tiers.', 'done', 'https://zeus-travel-health.higgsfield.app'),
  ('bld_demo_006', 'org_demo_test', 'ZEUS brand launch reel', 'video', 'Vertical 9 by 16 kinetic brand promo for launch.', 'queued', NULL),
  ('bld_demo_007', 'org_demo_test', 'AEGIS product explainer', 'video', 'Narrated explainer covering the seven attack vectors.', 'building', NULL),
  ('bld_demo_008', 'org_demo_test', 'NHS outreach deck', 'file', 'Board-ready PDF pack for NHS and DHSC commercial teams.', 'done', NULL);

INSERT OR IGNORE INTO files (id, org_id, name, kind, url, size_bytes) VALUES
  ('file_demo_003', 'org_demo_test', 'aegis-security-report.pdf', 'document', 'https://aegis-security.higgsfield.app', 0),
  ('file_demo_004', 'org_demo_test', 'zeus-gantt-docs-export.md', 'document', 'https://zeus-gantt-docs.higgsfield.app', 0),
  ('file_demo_005', 'org_demo_test', 'nhs-id-card-poster.png', 'image', 'https://nhs-id-card.higgsfield.app/og', 0),
  ('file_demo_006', 'org_demo_test', 'aegis-api-docs.pdf', 'document', 'https://aegis-api-docs.higgsfield.app', 0),
  ('file_demo_007', 'org_demo_test', 'zeus-brand-promo-reel.mp4', 'video', NULL, 0),
  ('file_demo_008', 'org_demo_test', 'company-ops-baseline.csv', 'document', NULL, 0);