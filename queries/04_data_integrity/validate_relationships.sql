-- ============================================
-- VALIDATE RELATIONSHIPS - Comprehensive Check
-- ============================================
-- Purpose: Find orders with broken relationships between orders, users, and products.
-- QA Focus: Data integrity and foreign key relationships.
-- ============================================

SELECT
o.id AS order_id,
o.user_id,
o.product_id,
o.total,
CASE
WHEN u.id IS null AND p.id IS null THEN 'Both References broken'
WHEN u.id IS NULL THEN 'ERROR: User not found'
WHEN p.id IS NULL THEN 'ERROR: Product not found'
ELSE 'OK'
END AS relationship_status
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN products p ON o.product_id = p.id
ORDER BY
CASE
WHEN u.id IS NULL AND p.id IS NULL THEN 1
WHEN u.id IS NULL OR p.id IS NULL THEN 2
ELSE 3
END;

-- ============================================

SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN u.id IS NOT NULL AND p.id IS NOT NULL THEN 1 ELSE 0 END) AS valid_orders,
    SUM(CASE WHEN u.id IS NULL THEN 1 ELSE 0 END) AS orphaned_orders,
    SUM(CASE WHEN p.id IS NULL THEN 1 ELSE 0 END) AS broken_product_refs,
    ROUND(
        (SUM(CASE WHEN u.id IS NOT NULL AND p.id IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS integrity_percentage
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN products p ON o.product_id = p.id;

-- Summary:
-- After running the query, we found that there are 15 total orders, 13 valid orders 1 orphaned orders and 1 broken product reference.
-- ============================================