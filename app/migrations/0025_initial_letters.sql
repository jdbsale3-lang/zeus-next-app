-- 0025: Draft the three NHS outreach letters into the email outbox.
-- Status 'draft' so nothing sends. Recipient addresses are deliberately NOT
-- fabricated: to_email holds a verification flag, to be replaced with the
-- confirmed official address before any send (standing rule: no guessed
-- addresses on official correspondence).
INSERT OR IGNORE INTO email_outbox (id, org_id, sender, to_email, subject, body, status) VALUES
('mail_nhs_ceo_01', 'org_zeus_shared', 'jdbsale3@gmail.com', 'VERIFY:NHS_CHIEF_EXEC',
 'NHS ID Card System - secure digital identity for the NHS App',
 'Dear NHS Chief Executive,

I am writing to present the NHS ID Card System for formal consideration.

The proposal is a secure digital identity for fifty million patients, issued as smart cards integrated directly with the NHS App. The programme carries a ten year value of twenty four point four billion pounds with a twenty eight point two times return on investment, and the platform is secured by AEGIS, our twenty four layer AI security system that is GDPR ready, CE ready and reaches the Data Security and Protection Toolkit assessment for the NHS.

The card delivers four things the NHS already wants: paramedic emergency access to critical patient information, hospital check in, digital prescriptions, and a revenue model that is fully opt in for patients.

ZEUS AI is aligned with the NHS commercial frameworks. We hold the registered entity ZEUSTRUSTAEGISSECURITY LTD, company number 17391549. We wish to begin with a working session: we engage the DHSC commercial team and the SBS framework to agree the procurement route.

The founder can make the full due diligence pack, including the eight of eight audit finding closure, available to your team within one business day of request.

I would welcome a short meeting at your convenience to introduce the programme and agree the first steps.

Yours sincerely

Darren Birch
Founder, ZEUS AI Intelligence, JDB Sales',
'draft'),
('mail_nhs_dhsc_01', 'org_zeus_shared', 'jdbsale3@gmail.com', 'VERIFY:NHS_DHSC_COMMERCIAL',
 'NHS ID Card - commercial framework engagement',
 'Dear Secretary of State for Health and Social Care,

I am writing to bring the NHS ID Card System proposal to your department. The project issues secure smart cards to fifty million NHS patients, integrated into the NHS App, with a ten year value of twenty four point four billion pounds and a twenty eight point two times return on investment.

The security layer is provided by AEGIS, a twenty four layer AI security platform with thirty seven endpoints across eight modules, fully hardened with eight of eight audit findings closed, GDPR and CE evidence ready, and NHS DSPT compliant. AEGIS already protects production systems today.

We propose to route this through the NHS commercial structure: NHS England for the commercial team and the SBS framework, with your department as the sponsor for the NHS App integration and the procurement route. The holding entity is ZEUSTRASTAEGISSECURITY LIMITED, company number 17391549, registered at 66 Paul Street, London.

We would welcome your teams direction and a working session.

Yours sincerely

Darren Birch',
'draft'),
('mail_nhs_pm_01', 'org_zeus_shared', 'jdbsale3@gmail.com', 'VERIFY:NUMBER_TEN',
 'NHS ID Card - a national digital identity programme',
 'Prime Minister,

I am writing to invite your government to consider the NHS digital ID card programme. It builds a patient identity that works in the NHS App, protects data with a home grown UK security platform, and contributes to public service outcomes across the country. The programme is designed to be digital first, clinically safe, and based on a privacy offer.

Our company, through ZEUS Intelligence, develops AEGIS, a British security platform. We are ready to engage with Number Ten policy teams to align with the governments digital strategy.

We request audience through the relevant government offices to put the full commercial case before the department of health teams.

Yours sincerely

Darren Birch',
'draft');