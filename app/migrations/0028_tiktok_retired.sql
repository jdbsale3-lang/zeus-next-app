-- 0028: TikTok retired by founder (14 Aug 2026). OAuth disconnected, registry
-- flipped so the Commander treats both entries as retired, never for marketing.
UPDATE connections SET status = 'disconnected', note = 'Retired by founder 14 Aug — not in use'
WHERE provider IN ('tiktok', 'tiktok_ads');
