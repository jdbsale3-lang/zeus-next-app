-- 0059: ZEUS FILE WORKSPACE — content + path on the file store so ZEUS can
-- write, read and browse text files (notes, exports, specs, docs).
ALTER TABLE files ADD COLUMN content TEXT;
ALTER TABLE files ADD COLUMN dir_path TEXT NOT NULL DEFAULT '/';

CREATE INDEX IF NOT EXISTS idx_files_name ON files(name);