-- 1. Индекс на таблицу session по (staff_id, time_start)

CREATE INDEX IF NOT EXISTS idx_session_staff_time
  ON net_cafe.session (staff_id, time_start DESC);



-- 2. Индекс на таблицу computer_status по (computer_id, date_start)

CREATE INDEX IF NOT EXISTS idx_computer_status_latest
  ON net_cafe.computer_status (computer_id, date_start DESC);