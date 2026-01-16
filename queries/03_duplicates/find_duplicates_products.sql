-- ============================================
-- FIND DUPLICATE PRODUCTS - Duplicate Detection
-- ============================================
-- Purpose: Detect duplicate products
-- QA Focus: Validation of unique data
-- Bug Impact: Duplicate products can cause inventory and order problems
-- ============================================

SELECT
id,
name,
price,
stock
FROM products
WHERE LOWER(name) IN (
    SELECT LOWER(name) FROM products
    GROUP BY name
    HAVING COUNT(*) > 1
)
ORDER BY name;
-- ============================================
-- Expected findings:
-- [After running, note how many duplicate products were found]
-- Products duplicated: 0
-- ============================================