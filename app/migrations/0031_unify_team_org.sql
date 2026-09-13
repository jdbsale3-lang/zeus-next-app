-- 0031: Unify the department team under the shared company org so ZEUS sees
-- all eight departments in one place.
UPDATE department_agents SET org_id = 'org_zeus_shared'
WHERE org_id = 'org_demo_test' AND name IN ('Sales','Finance','Development','Marketing');