-- 1. Возвращает суммарную стоимость всех закрытых сеансов для клиента.

CREATE OR REPLACE FUNCTION net_cafe.get_client_total_spent(p_client_id INT)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE
  v_total NUMERIC;
BEGIN
  SELECT COALESCE(SUM(price),0)
    INTO v_total
  FROM net_cafe.session
  WHERE client_id = p_client_id
    AND status = 'закрыта';

  RETURN v_total;
END;
$$;

-- Использование

SELECT net_cafe.get_client_total_spent(3) AS spent;



-- 2. Возвращает топ-N услуг по количеству раз, которые они были заказаны в сеансах.

CREATE OR REPLACE FUNCTION net_cafe.get_top_services(limit_count INT)
RETURNS TABLE(
  service_id    INT,
  service_name  TEXT,
  usage_count   BIGINT
) LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT
    sv.service_id,
    sv.service_name,
    COUNT(ss.session_service_id) AS usage_count
  FROM net_cafe.services sv
  JOIN net_cafe.session_service ss ON sv.service_id = ss.service_id
  GROUP BY sv.service_id, sv.service_name
  ORDER BY usage_count DESC
  LIMIT limit_count;
END;
$$;

-- Использование

SELECT * FROM net_cafe.get_top_services(5);
