-- ZEUS COMMAND CENTER — dedupe connections (12 Aug 2026)
-- The INSERT OR IGNORE propagation used deterministic ids (conn_<provider>) but
-- the original lazy seed used random UUIDs, so every org ended up with two rows
-- per provider. Keep the deterministic conn_* row, drop the random-UUID twin.
DELETE FROM connections
WHERE id NOT LIKE 'conn\_%' ESCAPE '\'
  AND EXISTS (
    SELECT 1 FROM connections c2
    WHERE c2.org_id = connections.org_id
      AND c2.provider = connections.provider
      AND c2.id LIKE 'conn\_%' ESCAPE '\'
  );
