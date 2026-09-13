-- 0015: Mark 6 Pipedream tools with expired tokens as disconnected (reconnect needed)
UPDATE connections SET status = 'disconnected', note = 'Token expired — reconnect'
WHERE provider IN ('discord_bot', 'whatsapp_business', 'linear_app', 'sendgrid', 'outlook', 'onedrive');