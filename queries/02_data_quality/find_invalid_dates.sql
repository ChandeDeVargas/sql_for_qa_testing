-- ============================================
-- INVALID DATES - Time Travel Detection
-- ============================================
-- Business Impact: Broken reports, wrong analytics, impossible data
-- QA Question: "Can our system handle time correctly?"
-- Real-world example: User created in 2027 > Marketing report shows 'Future signups'


use sql_qa_testing;

-- ============================================
-- Check 1: Users with time anomalies
-- ============================================

SELECT
    user_id,
    full_name,
    email,
    created_at,

    CASE
        WHEN created_at IS NULL THEN 'CRITICAL: NULL date - System crash risk'
        WHEN created_at > NOW() THEN CONCAT('Future date (+', DATEDIFF(created_at, NOW()), ' days) - Time travel bug')
        WHEN created_at < '2020-01-01' THEN CONCAT('Very old (', YEAR(created_at), ') - Before system launch?')
        ELSE 'OK: Valid date'
    END AS date_issue,

    -- Additional context
    DATEDIFF(NOW(), created_at) AS account_age_days

FROM users
WHERE created_at IS NULL
    OR created_at > NOW()
    OR created_at < '2020-01-01'
ORDER BY created_at DESC;

-- Expected bugs: User 8 with future date.

-- ============================================
-- Check 2: Products with invalid creation dates
-- ============================================

SELECT
    product_id,
    product_name,
    price,
    created_at,

    CASE
        WHEN created_at IS NULL THEN 'Critical: NULL DATE - CAN\'T track inventory'
        WHEN created_at > NOW() THEN 'CRITICAL: Future product - Not launched yet?'
        WHEN created_at < '2020-01-01' THEN 'Warning: Legacy product - May be discontinued'
        ELSE 'Valid'
    END AS date_issue

FROM products
WHERE created_at IS NULL
    OR created_at > NOW()
    OR created_at < '2020-01-01';

-- Expected: No bugs in products (all have valid dates)

-- ============================================
-- Check 3: Orders with impossible dates
-- ============================================

SELECT
    order_id,
    user_id,
    order_total,
    order_date,
    order_status,

    CASE
        WHEN order_date IS NULL THEN 'Critical NULL DATE - Order lost in time'
        WHEN order_date > NOW() THEN CONCAT('CRITICAL: Future order (+', DATEDIFF(order_date, NOW()), ' days) - Pre-orders broken')
        WHEN order_date < '2020-01-01' THEN 'Warning: Ancient order - Migration data?'
        ELSE 'Valid'
    END AS date_issue,

    -- Financial impact of future orders
    CASE
        WHEN order_date > NOW() THEN order_total
        ELSE 0
    END AS revenue_at_risk

FROM orders
WHERE order_date IS NULL
    OR order_date > NOW()
    OR order_date < '2020-01-01'
ORDER BY order_date DESC;

-- Expected bugs: Order 7 with future date (2027)

-- ============================================
-- REAL-WORLD IMPACT:
-- ============================================
-- User 8: Created 2027-12-31
--   → "New users this month" report includes them
--   → Marketing thinks we have signups from the future
--   → Skews growth metrics
--
-- Order 7: Date 2027-12-25
--   → Revenue report shows $89.97 in future revenue
--   → "Recent orders" includes orders that haven't happened
--   → Inventory forecasting is wrong
--
-- QA ACTION:
-- 1. Add database constraint: CHECK (created_at <= NOW())
-- 2. Frontend validation: Disable future dates
-- 3. Backend validation: Reject requests with date > NOW()
-- ============================================