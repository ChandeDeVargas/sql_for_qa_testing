-- ============================================
-- FIND ZERO PRICES - Data Quality Check
-- ============================================
-- Purpose: Detect products with zero price and orders with zero totals
-- QA Focus: Revenue assurance
-- ============================================

-- Query 1: Products with zero or negative price
SELECT
    id,
    name,
    price,
    created_at,
    CASE
        WHEN price = 0 THEN 'Critical: Free product'
        WHEN price < 0 THEN 'Critical: Negative price'
        ELSE 'Ok'
    END AS impact_description
FROM products
WHERE price <= 0;

-- Query 2: Orders with zero totals
SELECT
    id,
    user_id,
    product_id,
    quantity,
    total,
    order_date,
    CASE
        WHEN total = 0 THEN 'Critical: No revenue'
        ELSE 'Ok'
    END AS impact_description
FROM orders
WHERE total = 0;

-- ============================================
-- Findings:
-- - Products: 3 record with zero price (ID 4 and 10)
-- - Orders: 1 record with negative total (ID 6)
-- Root cause: Data entry error or pricing configuration issue
-- ============================================
