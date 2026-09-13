-- 0014: Salesforce dropped - not in use
UPDATE connections SET status = 'disconnected', note = 'Not in use'
WHERE provider = 'salesforce_rest_api';