-- 0042: Complete the queued NHS investor deck production request and seed the
-- CRM pipeline with verified-only target records. No email address is invented:
-- every external contact row carries a VERIFY: tag and null email until the
-- founder or Sales supplies a confirmed official address, per the standing rule.
UPDATE build_requests SET status = 'done', output_url = 'https://d2ol7oe51mr4n9.cloudfront.net/user_3GJd975B4Ec780O9XOwnwdY7BEs/nhs-investor-deck.pdf' WHERE id = '670d4141-3964-45a2-9ccc-8ef44d01bc83';

INSERT OR IGNORE INTO contacts (id, org_id, type, name, email, tags, source) VALUES
('ct_nhs_ceo', 'org_zeus_shared', 'person', 'NHS Chief Executive — verify', NULL, 'VERIFY:need_confirmed_official_address;nhs', 'founder pipeline'),
('ct_nhs_dhsc', 'org_zeus_shared', 'person', 'DHSC Commercial — verify', NULL, 'VERIFY:use_official_contract_path;dhsc', 'founder pipeline'),
('ct_nhs_sbs', 'org_zeus_shared', 'person', 'NHS England SBS Procurement — verify', NULL, 'VERIFY:need_confirmed_official_address;sbs', 'founder pipeline'),
('ct_inv_001', 'org_zeus_shared', 'person', 'Qualified investor tier 1 — verify', NULL, 'VERIFY:needs_nda_before_issue;investor', 'founder pipeline'),
('ct_inv_002', 'org_zeus_shared', 'person', 'Qualified investor tier 2 — verify', NULL, 'VERIFY:needs_nda_before_issue;investor', 'founder pipeline'),
('ct_media_001', 'org_zeus_shared', 'person', 'Health trade press — verify', NULL, 'VERIFY:confirm_editorial_contact;media', 'founder pipeline'),
('ct_media_002', 'org_zeus_shared', 'person', 'National business desk — verify', NULL, 'VERIFY:confirm_editorial_contact;media', 'founder pipeline');