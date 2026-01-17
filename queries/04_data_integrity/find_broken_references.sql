-- ============================================
-- FIND BROKEN REFERENCES - Data Integrity Check
-- ============================================
-- Purpose: Find orders that reference non-existent products.
-- QA Focus: Data integrity and foreign key relationships.
-- Bug Impact: Orphaned orders can cause application crashes, incorrect reports, 
-- and financial reconciliation issues.
-- ============================================

SELECT 
    o.id,
    o.user_id,
    u.name AS user_name,
    o.product_id,
    o.quantity,
    o.total,
    o.order_date
FROM orders o
LEFT JOIN products p ON o.product_id = p.id
LEFT JOIN users u ON o.user_id = u.id
WHERE p.id IS NULL;
-- ============================================
-- Expected findings:
-- [id 7 it is broken]
-- ============================================