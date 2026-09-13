-- 0032: NHS recipient addresses, verified from official published sources only.
-- NHS CEO route: NHS England official contact (england.contactus@nhs.net, PO Box
-- 16738 Redditch) — the universal published channel to the organisation.
-- DHSC: official published channel is the Ministerial Correspondence and Public
-- Enquiries Unit, 39 Victoria Street London SW1H 0EU; no direct public email is
-- published, so the letter routes through the official postal/phone channel.
-- PM: no public direct email exists; Number Ten does not publish one. The
-- letter stays addressed to the role with the official Number Ten route noted.
-- No guessed address is placed in any row, per standing rule.
UPDATE email_outbox SET
  to_email = 'england.contactus@nhs.net',
  body = replace(body, 'VERIFY', 'via official channel')
WHERE id = 'mail_nhs_ceo_01';

UPDATE email_outbox SET
  to_email = 'DHSC Ministerial Correspondence and Public Enquiries Unit, 39 Victoria Street, London SW1H 0EU (no public email published; use official postal channel)',
  body = replace(body, 'VERIFY', 'via official channel')
WHERE id = 'mail_nhs_dhsc_01';

UPDATE email_outbox SET
  to_email = 'VERIFY:PM_ROUTE (no public email published; route via Number Ten correspondence channel)',
  body = replace(body, 'VERIFY', 'via official channel')
WHERE id = 'mail_nhs_pm_01';