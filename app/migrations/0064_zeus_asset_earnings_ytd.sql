-- 0064: earnings_ytd column on asset_registry — per-asset year-to-date earnings.
-- Honest default: NULL until billing data is supplied. The AWS Earnings & Renewal
-- entry will hold the AWS-linked earnings reference when figures exist.
ALTER TABLE asset_registry ADD COLUMN earnings_ytd TEXT;

UPDATE asset_registry
SET notes = notes || ' YTD earnings: awaiting billing snapshot.'
WHERE id = 'ast_aws_earnings';