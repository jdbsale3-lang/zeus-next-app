-- 0035: First test build through the Higgsfield bridge. Filed with the exact
-- spec the pipeline would use, status blocked on platform credits until the
-- account is topped up. The request proves the bridge writes correctly; the
-- rental is the only missing piece.
INSERT OR IGNORE INTO build_requests (id, org_id, title, build_type, spec, status, output_url) VALUES
('bld_first_bridge', 'org_zeus_shared', 'ZEUS bridge test clip', 'video',
 'prompt:Cinematic brand test clip for ZEUS AI Intelligence, dark command-center desk, cyan interface glow, orb of light, slow push-in, premium tech atmosphere;duration:4;aspect:9:16;engine:seedance_2_0',
 'blocked', NULL);