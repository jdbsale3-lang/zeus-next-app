-- 0034: Verified official contacts from published government sources.
-- DHSC: ddat_business_cases@dhsc.gov.uk is the DHSC DDaT Commercial contact
-- published on the official Contracts Finder platform (notice CF-2786600D0O0, 39
-- Victoria Street, SW1H 0EU). This is the correct commercial route for a
-- framework engagement and replaces the generic postal placeholder.
-- NHS CEO: Sir Jim Mackey confirmed on GOV.UK as Chief Executive since 1 April
-- 2025; the letter names him and uses the published NHS England contact channel
-- (no public direct email exists).
-- PM: no public email published; Number Ten route stays flagged for manual
-- delivery of a confirmed private office address.
UPDATE email_outbox SET
  to_email = 'ddat_business_cases@dhsc.gov.uk',
  body = replace(body, 'Dear Secretary of State for Health and Social Care,', 'Dear DHSC DDaT Commercial team,')
WHERE id = 'mail_nhs_dhsc_01';

UPDATE email_outbox SET
  to_email = 'england.contactus@nhs.net',
  body = replace(body, 'Dear NHS Chief Executive,', 'Dear Sir Jim Mackey,')
WHERE id = 'mail_nhs_ceo_01';