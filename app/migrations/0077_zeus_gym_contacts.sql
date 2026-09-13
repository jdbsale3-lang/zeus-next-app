-- 0077: ForgeFit gym outreach contacts — published channels only
-- (0076 was amended after deploy so these got missed; this migration lands them).
INSERT OR IGNORE INTO contacts (id, org_id, type, name, email, phone, tags, source, created_at) VALUES
('ctc_puregym_franchise','org_user_3GJd975B4Ec780O9XOw','company','PureGym (Franchise Enquiries)','franchise@puregym.com',NULL,'forgefit,gym,uk','https://corporate.puregym.com/investor-contacts/',datetime('now')),
('ctc_gymgroup_property','org_user_3GJd975B4Ec780O9XOw','company','The Gym Group (Property)','property@thegymgroup.com',NULL,'forgefit,gym,uk','https://www.thegymgroup.com/property-info/',datetime('now'));