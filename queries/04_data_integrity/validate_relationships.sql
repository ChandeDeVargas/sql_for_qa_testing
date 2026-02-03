-- ============================================
-- COMPREHENSIVE RELATIONSHIP VALIDATION
-- ============================================
-- Business Impact: Broken relationships = Cascading failures across entire system
-- QA Question: "Is our data internally consistent?"
-- Purpose: One-stop health check for all foreign key relationships
-- ============================================

USE sql_qa_testing;


-- ============================================
-- Part 1: Detailed breakdown of broken relationships
-- ============================================

SELECT
    o.order_id,
    o.user_id,
    o.order_total,
    o.order_date,
    o.order_status,

    -- Check user relationship
    CASE
        WHEN u.user_id IS NULL THEN 'Broken'
        ELSE 'Valid'
    END AS user_link,

    -- Check if order has items
    CASE
        when oi.items_id IS NULL THEN 'NO ITEMS'
        ELSE 'Valid'
    END AS items_link,

    -- Overall health
    CASE
        WHEN u.user_id IS NULL AND oi.items_id IS NULL THEN
            'CRITICAL; Ghost order (No user, no items)'
        WHEN u.user_id IS NULL THEN
            'CRITICAL: Orphaned (no user)'
        WHEN oi.items_id IS NULL THEN
            'CRITICAL: Empty order (no items)'
        ELSE 'Healthy'
    END AS overall_status

FROM orders o
LEFT JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.user_id, o.order_total, o.order_date, o.order_status, u.user_id, oi.item_id
ORDER BY
    CASE
        WHEN u.user_id IS NULL AND oi.item_id IS NULL THEN 1
        WHEN u.user_id IS NULL THEN 2
        WHEN oi.item_id IS NULL THEN 3
        ELSE 4
    END,
    o.order_id;

-- ============================================
-- Part 2: Database health summary (dashboard view)
-- ============================================

SELECT 
    -- Total counts
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN u.user_id IS NOT NULL THEN o.order_id END) AS orders_with_valid_user,
    COUNT(DISTINCT CASE WHEN oi.item_id IS NOT NULL THEN o.order_id END) AS orders_with_items,
    
    -- Problem counts
    COUNT(DISTINCT CASE WHEN u.user_id IS NULL THEN o.order_id END) AS orphaned_orders,
    COUNT(DISTINCT CASE WHEN oi.item_id IS NULL THEN o.order_id END) AS empty_orders,
    
    -- Integrity percentage
    ROUND(
        (COUNT(DISTINCT CASE WHEN u.user_id IS NOT NULL AND oi.item_id IS NOT NULL THEN o.order_id END) * 100.0) / 
        COUNT(DISTINCT o.order_id), 
        2
    ) AS data_integrity_score,
    
    -- Health status
    CASE
        WHEN (COUNT(DISTINCT CASE WHEN u.user_id IS NOT NULL AND oi.item_id IS NOT NULL THEN o.order_id END) * 100.0) / 
             COUNT(DISTINCT o.order_id) >= 95 THEN 'HEALTHY'
        WHEN (COUNT(DISTINCT CASE WHEN u.user_id IS NOT NULL AND oi.item_id IS NOT NULL THEN o.order_id END) * 100.0) / 
             COUNT(DISTINCT o.order_id) >= 80 THEN 'NEEDS ATTENTION'
        ELSE 'CRITICAL'
    END AS database_health

FROM orders o
LEFT JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id;

-- ============================================
-- Part 3: Order items with broken product references
-- ============================================

SELECT
    oi.item_id,
    oi.order_id,
    oi.product_id,
    p.product_name,
    
    CASE
        WHEN p.product_id IS NULL THEN 'BROKEN: Product deleted'
        ELSE 'Valid'
    END AS product_link

FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ============================================
-- EXPECTED RESULTS (Current dataset):
-- ============================================
-- Total orders: 13
-- Valid orders (user + items): 11-12 (depending on bugs)
-- Orphaned orders: 0 (with new schema)
-- Empty orders: 1 (order_id 13 - intentional bug)
-- Broken product refs: 1 (item_id 13, product 999)
--
-- Data Integrity Score: ~85-92%
-- Database Health: NEEDS ATTENTION
--
-- WHAT GOOD LOOKS LIKE:
-- ============================================
-- Target metrics for production:
--   - Data Integrity Score: > 99%
--   - Orphaned orders: 0
--   - Empty orders: 0
--   - Broken references: 0
--   - Database Health: HEALTHY
--
-- QA ACTIONS:
-- ============================================
-- 1. Run this query DAILY in production
-- 2. Alert if integrity score < 95%
-- 3. Investigate any broken relationships immediately
-- 4. Track trends: Is integrity improving or degrading?
--
-- 5. Add to CI/CD:
--    - Run after each deployment
--    - Fail build if integrity < 90%
--    - Prevent bad data from reaching production
-- ============================================