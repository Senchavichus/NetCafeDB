-- 1. Выводит для каждого компьютера его текущий статус и характеристики.

CREATE OR REPLACE VIEW net_cafe.current_computer_status AS
WITH latest AS (
  SELECT
    cs.*,
    ROW_NUMBER() OVER (PARTITION BY cs.computer_id ORDER BY cs.date_start DESC) AS rn
  FROM net_cafe.computer_status cs
)
SELECT
  l.computer_id,
  c.type          AS computer_type,
  c.placement     AS computer_location,
  l.status,
  l.specs,
  l.date_start    AS status_since
FROM latest l
JOIN net_cafe.computer c ON l.computer_id = c.computer_id
WHERE l.rn = 1;

-- Вывод:

SELECT * FROM net_cafe.current_computer_status;



-- 2. Подсчитывает для каждого менеджера общее число проведённых сессий и суммарную выручку, а также среднюю стоимость сеанса.

CREATE OR REPLACE VIEW net_cafe.manager_session_summary AS
SELECT
  st.staff_id,
  st.first_name || ' ' || st.second_name AS manager_name,
  COUNT(s.session_id)      AS sessions_count,
  SUM(s.price)             AS total_revenue,
  ROUND(AVG(s.price)::numeric, 2) AS avg_price
FROM net_cafe.session s
JOIN net_cafe.staff st ON s.staff_id = st.staff_id
WHERE st.position = 'Менеджер'
GROUP BY st.staff_id, st.first_name, st.second_name
ORDER BY total_revenue DESC;

-- Вывод:

SELECT * FROM net_cafe.manager_session_summary;