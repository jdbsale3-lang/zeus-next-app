-- ZEUS COMMAND CENTER — replace dead project URLs with live ones (12 Aug 2026)
UPDATE projects SET url = 'https://zeusai-intelligence.higgsfield.app/nhs'
WHERE url = 'https://zeusai-intelligence.org/nhs';

UPDATE projects SET url = 'https://zeusai-intelligence.higgsfield.app'
WHERE url IN ('https://jdbsales', 'https://zeusai-intelligence.org');