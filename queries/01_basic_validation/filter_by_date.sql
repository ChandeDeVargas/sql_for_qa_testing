-- ============================================
-- FILTER BY DATE - Date Validation
-- ============================================
-- Purpose: Filter orders by date range and detect invalid dates
-- QA Focus: Future dates, negative totals, invalid status
-- ============================================

-- Query 1: Orders in March 2024

SELECT
id,
user_id,
product_id,
total,
order_date,
status,
-- Flag Potential Uses
CASE
WHEN order_date > NOW() THEN 'WARNING: Future Date'
WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'WARNING: Invalid Status'
WHEN total <= 0 THEN 'WARNING: Invalid Total'
ELSE 'OK'
END AS validation_status
FROM orders
WHERE order_date BETWEEN '2024-03-01' AND '2024-03-31' or order_date > NOW() or order_date < '2020-01-01'
ORDER BY id;

-- ============================================
-- Bugs found:
-- - Order ID 9: Future date
-- - Order ID 4, 13, 14: Negative total
-- ============================================