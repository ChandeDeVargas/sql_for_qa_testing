-- ============================================
-- FIND INVALID DATES - Data Quality Check
-- ============================================
-- Purpose: Detect records with invalid dates (NULL, future, or too old)
-- QA Focus: Data integrity
-- ============================================

-- Query 1: Users with invalid dates
SELECT
    id,
    name,
    email,
    created_at,
    CASE
        WHEN created_at IS NULL THEN 'Critical: Date is NULL'
        WHEN created_at > NOW() THEN 'Critical: Future date'
        WHEN created_at < '2020-01-01' THEN 'Warning: Date too old'
        ELSE 'Valid'
    END AS issue_description
FROM users
WHERE created_at IS NULL
   OR created_at > NOW()
   OR created_at < '2020-01-01';

-- Query 2: Products with invalid dates
SELECT
    id,
    name,
    price,
    created_at,
    CASE
        WHEN created_at IS NULL THEN 'Critical: Date is NULL'
        WHEN created_at > NOW() THEN 'Critical: Future date'
        WHEN created_at < '2020-01-01' THEN 'Warning: Date too old'
        ELSE 'Valid'
    END AS issue_description
FROM products
WHERE created_at IS NULL
   OR created_at > NOW()
   OR created_at < '2020-01-01';

-- Query 3: Orders with invalid dates
SELECT
    id,
    user_id,
    total,
    order_date,
    CASE
        WHEN order_date IS NULL THEN 'Critical: Date is NULL'
        WHEN order_date > NOW() THEN 'Critical: Future date'
        WHEN order_date < '2020-01-01' THEN 'Warning: Date too old'
        ELSE 'Valid'
    END AS issue_description
FROM orders
WHERE order_date IS NULL
   OR order_date > NOW()
   OR order_date < '2020-01-01';

-- ============================================
-- Findings:
-- - Users: 2 records with NULL created_at
-- - Products: 1 record with NULL created_at
-- - Orders: 1 record with NULL order_date
-- ============================================