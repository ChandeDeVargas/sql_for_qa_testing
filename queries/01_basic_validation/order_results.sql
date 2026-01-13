-- ============================================
-- Query 1: Top 5 most expensive products
SELECT
id,
name,
price
FROM products
ORDER BY price DESC
LIMIT 5;

-- ============================================
-- Query 2: Most active users (by order count)
SELECT
users.id AS user_id,
users.name,
COUNT(orders.id) AS total_orders
FROM users
JOIN orders ON users.id = orders.user_id
GROUP BY users.id
ORDER BY total_orders DESC
LIMIT 5;


-- ============================================
-- Query 3: Orders by Total (With Rankings)
SELECT
orders.id,
users.name AS user_name,
products.name AS product_name,
orders.total,
orders.order_date,
orders.status,
RANK() OVER (ORDER BY orders.total DESC) AS ranking,
CASE
WHEN orders.total <= 0 THEN 'Warning: Invalid Total'
ELSE 'OK'
END AS validation_status
FROM orders
JOIN users ON orders.user_id = users.id
JOIN products ON orders.product_id = products.id
ORDER BY orders.total DESC;


-- ============================================
-- Expected bugs to find:
-- - User ID 4: Negative total and warning status
-- - User ID 13: Total 0 and warning status
-- - User ID 14: Negative Total and warning status
-- =============================================