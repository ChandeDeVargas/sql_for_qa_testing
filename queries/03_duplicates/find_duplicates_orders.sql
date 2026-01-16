-- ============================================
-- FIND DUPLICATE ORDERS - Duplicate Detection
-- ============================================
-- Purpose: Detect duplicate orders
-- QA Focus: Validation of unique data
-- Bug Impact: Duplicate orders can cause inventory and order problems
-- ============================================

SELECT o.*
FROM orders o
JOIN(
    SELECT user_id, product_id, DATE(order_date) as order_day, COUNT(*) as duplicates
    FROM orders
    GROUP BY user_id, product_id, DATE(order_date)
    HAVING COUNT(*) > 1
) dup
ON o.user_id = dup.user_id
AND o.product_id = dup.product_id
AND DATE(o.order_date) = dup.order_day
ORDER BY o.user_id, o.product_id, o.order_date;
-- ============================================
-- Expected findings:
-- [After running, note if duplicates were found]
-- Orders duplicated: 0
-- ============================================