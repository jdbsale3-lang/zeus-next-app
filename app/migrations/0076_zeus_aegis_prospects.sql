-- 0076: AEGIS security prospects — verified at source (published contact
-- pages, 16 Aug 2026). Only published addresses, never guessed.
INSERT OR IGNORE INTO contacts (id, org_id, type, name, email, phone, tags, source, created_at) VALUES
('ctc_precogs','org_user_3GJd975B4Ec780O9XOw','company','Precogs AI Ltd','hello@precogs.ai','+44-7936909908','aegis,ai-security,uk','https://www.precogs.ai/contact-us',datetime('now')),
('ctc_hoplon','org_user_3GJd975B4Ec780O9XOw','company','HOPLONai','info@hoplon-ai.com',NULL,'aegis,ai-security,london','https://hoplonai.com/contact/',datetime('now')),
('ctc_blackdice','org_user_3GJd975B4Ec780O9XOw','company','BlackDice Cyber Ltd','info@blackdice.ai',NULL,'aegis,ai-security,leeds','https://www.blackdice.ai/contact/',datetime('now')),
('ctc_qlsecurity','org_user_3GJd975B4Ec780O9XOw','company','QL Security','hello@qlsecurity.co.uk','0330 223 6633','aegis,ai-governance,uk','https://qlsecurity.co.uk/contact/',datetime('now')),
('ctc_archestra_joey','org_user_3GJd975B4Ec780O9XOw','person','Joey Orlando (Archestra)','joey@archestra.ai',NULL,'aegis,ai-infra,cofounder','https://archestra.ai/about',datetime('now')),
('ctc_archestra_matvey','org_user_3GJd975B4Ec780O9XOw','person','Matvey Kukuy (Archestra)','matvey@archestra.ai',NULL,'aegis,ai-infra,ceo','https://archestra.ai/about',datetime('now')),
('ctc_archestra_ildar','org_user_3GJd975B4Ec780O9XOw','person','Ildar Iskhakov (Archestra)','ildar@archestra.ai',NULL,'aegis,ai-infra,cto','https://archestra.ai/about',datetime('now'));
-- ForgeFit gym outreach adds (verified published channels only)
INSERT OR IGNORE INTO contacts (id, org_id, type, name, email, phone, tags, source, created_at) VALUES
('ctc_puregym_franchise','org_user_3GJd975B4Ec780O9XOw','company','PureGym (Franchise Enquiries)','franchise@puregym.com',NULL,'forgefit,gym,uk','https://corporate.puregym.com/investor-contacts/',datetime('now')),
('ctc_gymgroup_property','org_user_3GJd975B4Ec780O9XOw','company','The Gym Group (Property)','property@thegymgroup.com',NULL,'forgefit,gym,uk','https://www.thegymgroup.com/property-info/',datetime('now'));
