-- ZEUS COMMAND CENTER — dedupe projects + prevent re-duplication (12 Aug 2026)
DELETE FROM projects
WHERE id NOT IN (
  SELECT MIN(id) FROM projects GROUP BY org_id, name
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_projects_org_name
  ON projects(org_id, name);