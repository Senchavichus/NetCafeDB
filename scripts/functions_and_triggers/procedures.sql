-- 1. Создаёт новую сессию и сразу записывает связанные услуги.

CREATE OR REPLACE PROCEDURE net_cafe.create_session_with_services(
  p_client_id   INT,
  p_computer_id INT,
  p_staff_id    INT,
  p_time_start  TIMESTAMP,
  p_time_end    TIMESTAMP,
  p_price       NUMERIC,
  p_service_ids INT[]
)
LANGUAGE plpgsql AS $$
DECLARE
  v_session_id INT;
BEGIN
  INSERT INTO net_cafe.session(
    client_id, computer_id, staff_id,
    time_start, time_end, status, price
  ) VALUES (
    p_client_id, p_computer_id, p_staff_id,
    p_time_start, p_time_end, 'закрыта', p_price
  ) RETURNING session_id INTO v_session_id;

  INSERT INTO net_cafe.session_service(session_id, service_id)
  SELECT v_session_id, svc
  FROM unnest(p_service_ids) AS svc;

  RAISE NOTICE 'Session % with services % created.', v_session_id, p_service_ids;
END;
$$;

-- Пример: 

CALL net_cafe.create_session_with_services(
  4, 2, 1, '2025-02-01 10:00', '2025-02-01 12:30', 15.00,
  ARRAY[1,5,13]
);



-- 2. Закрывает текущий статус компьютера и создаёт новую запись с новым статусом.

CREATE OR REPLACE PROCEDURE net_cafe.record_computer_status(
  p_computer_id INT,
  p_status      VARCHAR,
  p_specs       VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
  -- Закрываем текущий статус
  UPDATE net_cafe.computer_status
    SET date_end = NOW()
  WHERE computer_id = p_computer_id
    AND date_end IS NULL;

  -- Вставляем новую запись
  INSERT INTO net_cafe.computer_status(
    computer_id, status, specs, date_start, date_end
  ) VALUES (
    p_computer_id, p_status, p_specs, NOW(), NULL
  );

  RAISE NOTICE 'Computer % status recorded as %.', p_computer_id, p_status;
END;
$$;

-- Пример: 

CALL net_cafe.record_computer_status(5, 'Работает', 'Консоль: PS5');


