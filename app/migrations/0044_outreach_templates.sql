-- 0044: Outreach email templates drafted into the outbox per the follow-up.
-- Recipient fields are VERIFY placeholders, never guessed addresses: each row
-- is a ready-to-send template the moment the founder or Sales fills in a
-- confirmed official contact from the CRM verify rows.
INSERT OR IGNORE INTO email_outbox (id, org_id, sender, to_email, subject, body, status) VALUES
('mail_out_investor_01', 'org_zeus_shared', 'jdbsale3@gmail.com', 'VERIFY:CONFIRMED_INVESTOR_ADDR',
 'NHS ID Card System — Investor opportunity (50M cards, 24.4bn, 28.2x ROI)',
 'Dear investor,

We are preparing the public investment round for the NHS ID Card System: fifty million smart cards linked to the NHS App, a ten year programme value of 24.4 billion pounds, and an estimated 28.2 times return on investment, with security provided by AEGIS AI Security.

The full investor terms and commercial case are ready. Before issuing them we require a signed mutual NDA, which we will send on request.

Please reply to confirm the address this deck should be sent to, and your NDA signatory contact details.

Kind regards,
ZEUS AI Intelligence
', 'draft'),
('mail_out_media_1', 'org_zeus_shared', 'jdbsale3@gmail.com', 'VERIFY:CONFIRMED_MEDIA_CONTACT',
 'Press release: ZEUS AI Intelligence announces national NHS ID Card System proposal',
 'Hi,

Attached is a press release for your consideration: ZEUS AI Intelligence announces its proposal for a national NHS ID Card System, fifty million smart cards linked to the NHS App, with security by AEGIS AI Security.

The release is embargoed-ready and includes founder commentary and commercial summary. We can supply board-approved figures and security evidence on request.

Kind regards,
ZEUS AI Intelligence
', 'draft'),
('mail_out_nhs_commercial', 'org_zeus_shared', 'jdbsale3@gmail.com', 'VERIFY:NHS_COMMERCIAL_TEAM',
 'NHS ID Card System — commercial submission for review',
 'Dear NHS commercial team,

We are submitting the NHS ID Card System proposal for your review. It proposes fifty million smart cards linked to the NHS App, delivering a reusable national identity layer, with a ten year value of 24.4 billion pounds and a projected 28.2 times ROI, secured by AEGIS AI Security.

The submission pack, one page executive summary, and evidence file are ready to send to the confirmed commercial route you advise.

Kind regards,
JDB Sales, for ZEUS AI Intelligence
', 'draft');