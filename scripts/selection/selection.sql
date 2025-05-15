-- 1. Список сессий с информацией о клиенте, компьютере и менеджере

SELECT s.session_id,
       c.first_name || ' ' || c.second_name AS client_name,
       cmp.type AS computer_type,
       st.first_name || ' ' || st.second_name AS manager_name,
       s.time_start, s.time_end, s.price
FROM net_cafe.session s
INNER JOIN net_cafe.client c ON s.client_id = c.client_id
LEFT JOIN net_cafe.computer cmp ON s.computer_id = cmp.computer_id
INNER JOIN net_cafe.staff st ON s.staff_id = st.staff_id
WHERE st.position = 'Менеджер'
ORDER BY s.time_start DESC;



-- 2. Статистика сеансов по типу компьютера

SELECT cmp.type,
       COUNT(s.session_id) AS sessions_count,
       AVG(s.price) AS avg_price
FROM net_cafe.session s
INNER JOIN net_cafe.computer cmp ON s.computer_id = cmp.computer_id
GROUP BY cmp.type
HAVING COUNT(s.session_id) >= 1
ORDER BY sessions_count DESC;



-- 3. Средняя стоимость сеансов по менеджерам

SELECT st.staff_id,
       st.first_name || ' ' || st.second_name AS manager_name,
       COUNT(s.session_id) AS sessions_count,
       AVG(s.price) AS avg_session_price
FROM net_cafe.session s
INNER JOIN net_cafe.staff st ON s.staff_id = st.staff_id
WHERE st.position = 'Менеджер'
GROUP BY st.staff_id, st.first_name, st.second_name
ORDER BY avg_session_price DESC;



-- 4. Клиенты с суммарной стоимостью сеансов больше 20

SELECT c.client_id,
       c.first_name || ' ' || c.second_name AS client_name,
       totals.total_price
FROM net_cafe.client c
INNER JOIN (
    SELECT s.client_id, SUM(s.price) AS total_price
    FROM net_cafe.session s
    GROUP BY s.client_id
) totals ON c.client_id = totals.client_id
WHERE totals.total_price > 20
ORDER BY totals.total_price DESC;



-- 5. Последняя версия состояния каждого компьютера

SELECT cs.computer_id, cs.status, cs.date_start, cs.date_end, cs.specs
FROM (
  SELECT cs.*,
         ROW_NUMBER() OVER (PARTITION BY cs.computer_id ORDER BY cs.date_start DESC) AS rn
  FROM net_cafe.computer_status cs
) cs
WHERE rn = 1
ORDER BY cs.computer_id;



-- 6. Администраторы, выдающие оборудование

SELECT st.staff_id,
       st.first_name || ' ' || st.second_name AS admin_name,
       COUNT(ss.service_id) AS equipment_services_count
FROM net_cafe.staff st
INNER JOIN net_cafe.staff_service ss ON st.staff_id = ss.staff_id
INNER JOIN net_cafe.services sv ON ss.service_id = sv.service_id
WHERE st.position = 'Администратор'
  AND sv.service_name IN ('дополнительный контроллер к консоли', 'VR-шлем')
GROUP BY st.staff_id, st.first_name, st.second_name
ORDER BY equipment_services_count DESC;



-- 7. Сотрудники службы поддержки с количеством оказанных услуг технической поддержки

SELECT st.staff_id,
       st.first_name || ' ' || st.second_name AS support_name,
       COUNT(ss.service_id) AS tech_support_count
FROM net_cafe.staff st
INNER JOIN net_cafe.staff_service ss ON st.staff_id = ss.staff_id
INNER JOIN net_cafe.services sv ON ss.service_id = sv.service_id
WHERE st.position = 'Служба поддержки'
  AND sv.service_name = 'Техническая Поддержка'
GROUP BY st.staff_id, st.first_name, st.second_name
ORDER BY tech_support_count DESC;



-- 8. Менеджеры отсортированные по убыванию максимальной цены сеанса.

WITH max_sessions AS (
  SELECT 
    s.staff_id, 
    s.session_id, 
    s.price,
    ROW_NUMBER() OVER (PARTITION BY s.staff_id ORDER BY s.price DESC) AS rn
  FROM net_cafe.session s
  INNER JOIN net_cafe.staff st ON s.staff_id = st.staff_id
  WHERE st.position = 'Менеджер'
)
SELECT 
  ms.staff_id,
  st.first_name || ' ' || st.second_name AS manager_name,
  ms.session_id,
  ms.price AS max_session_price
FROM max_sessions ms
INNER JOIN net_cafe.staff st ON ms.staff_id = st.staff_id
WHERE ms.rn = 1
ORDER BY ms.price DESC;



-- 9. Топ-5 клиентов по суммарной стоимости сеансов с ранжированием

SELECT client_id, client_name, total_price, 
       RANK() OVER (ORDER BY total_price DESC) AS rank
FROM (
  SELECT c.client_id, c.first_name || ' ' || c.second_name AS client_name, SUM(s.price) AS total_price
  FROM net_cafe.client c
  INNER JOIN net_cafe.session s ON c.client_id = s.client_id
  GROUP BY c.client_id, c.first_name, c.second_name
) sub
ORDER BY total_price DESC
LIMIT 5;



-- 10. Сводный отчет по услугам по категориям с подсчетом заказов и выручкой

SELECT category, COUNT(*) AS orders_count, SUM(price) AS total_revenue
FROM (
    SELECT ss.session_service_id, sv.service_name, sv.price,
           CASE
             WHEN sv.service_name LIKE 'Чипсы%' THEN 'Чипсы'
             WHEN sv.service_name LIKE 'энергетик%' THEN 'Энергетик'
             WHEN sv.service_name LIKE 'газировка%' THEN 'Газировка'
             WHEN sv.service_name LIKE 'Кофе%' THEN 'Кофе'
             WHEN sv.service_name IN ('дополнительный контроллер к консоли', 'VR-шлем') THEN 'Оборудование'
             WHEN sv.service_name = 'Техническая Поддержка' THEN 'Техническая Поддержка'
             ELSE 'Другое'
           END AS category
    FROM net_cafe.session_service ss
    INNER JOIN net_cafe.services sv ON ss.service_id = sv.service_id
) sub
GROUP BY category
ORDER BY total_revenue DESC;
