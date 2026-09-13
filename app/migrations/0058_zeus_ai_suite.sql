-- 0058: ZEUS UPGRADE SUITE — smart home registry + computer-use action log.
CREATE TABLE IF NOT EXISTS smart_devices (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  room TEXT NOT NULL DEFAULT 'living',
  kind TEXT NOT NULL DEFAULT 'light',   -- light | plug | thermostat | camera | lock
  state INTEGER NOT NULL DEFAULT 0,     -- 0 off / 1 on (thermostat: 0=auto)
  target_c REAL,                        -- thermostat target °C
  last_sync TEXT
);
CREATE INDEX IF NOT EXISTS idx_smart_room ON smart_devices(room);

INSERT OR IGNORE INTO smart_devices (id, name, room, kind, state, target_c) VALUES
('dev_living_main','Living Room Main Light','living','light',0,NULL),
('dev_living_tv','TV Plug','living','plug',0,NULL),
('dev_office_rig','Founder Desk Power','office','plug',1,NULL),
('dev_office_lamp','Desk Lamp','office','light',1,NULL),
('dev_kitchen_hub','Kitchen Hub','kitchen','plug',0,NULL),
('dev_bed_light','Bedroom Light','bedroom','light',0,NULL),
('dev_therm_main','Main Thermostat','office','thermostat',1,21.0),
('dev_door_cam','Front Door Cam','hall','camera',1,NULL);

CREATE TABLE IF NOT EXISTS computer_use_steps (
  id TEXT PRIMARY KEY,
  task TEXT NOT NULL,
  step_payload TEXT NOT NULL,           -- json action list from the model
  status TEXT NOT NULL DEFAULT 'planned',-- planned | doing | done | failed
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);