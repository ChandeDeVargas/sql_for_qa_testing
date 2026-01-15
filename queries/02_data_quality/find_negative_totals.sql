-- ============================================
-- FIND NEGATIVE TOTALS - Data Quality Check
-- ============================================
-- Purpose: Detect orders with negative or zero totals
-- QA Focus: Critical data integrity issue - financial impact
-- Bug Impact: Could result in revenue loss or incorrect billing
-- ============================================

SELECT
orders.id,
users.name AS user_name,
products.name AS product_name,
orders.quantity,
orders.total,
orders.order_date,

CASE
WHEN orders.total < 0 AND orders.quantity < 0 THEN 'Critical: Both negative'
WHEN orders.total < 0 THEN 'Warning: Total negative'
WHEN orders.quantity = 0 THEN 'Warning: zero Total'
END AS issue_type,

(orders.quantity * products.price) AS expected_total,

(orders.total - (orders.quantity * products.price)) AS total_difference

FROM orders
JOIN users ON orders.user_id = users.id
JOIN products ON orders.product_id = products.id
WHERE orders.total <= 0
ORDER BY total_difference ASC;

-- ============================================
-- Findings:
-- - Order ID 4: Negative total (-299.99)
-- - Order ID 13: Zero total (0.00)
-- - Order ID 14: Negative total (-299.98) AND negative quantity (-2)
-- Root cause: Likely data entry error or calculation bug
-- ============================================