-- ============================================
-- DUPLICATE ORDERS - Double-Charging Detection
-- ============================================
-- Business Impact: Customers charged twice, inventory oversold, angry customers
-- QA Question: "Did we accidentally process the same order twice?"
-- Real-world scenario: User clicks 'Submit' twice → 2 charges on credit card
-- ============================================

USE sql_qa_testing;

-- Find potential duplicate orders (same user, same day, similar totals)
WITH potential_duplicates AS (
    SELECT 
        user_id,
        DATE(order_date) AS order_day,
        order_total,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id, DATE(order_date), order_total
    HAVING COUNT(*) > 1
)
SELECT 
    o.order_id,
    u.full_name AS customer,
    o.order_total,
    o.order_date,
    o.order_status,
    
    -- Show items in this order
    GROUP_CONCAT(p.product_name ORDER BY p.product_name SEPARATOR ', ') AS items_ordered,
    
    -- How many "duplicate" orders on same day
    pd.order_count AS similar_orders_same_day,
    
    -- Time between duplicate orders (helps identify double-click)
    TIMESTAMPDIFF(SECOND, 
        LAG(o.order_date) OVER (PARTITION BY o.user_id, DATE(o.order_date) ORDER BY o.order_date),
        o.order_date
    ) AS seconds_since_previous_order,
    
    -- Severity assessment
    CASE
        WHEN pd.order_count > 1 
             AND TIMESTAMPDIFF(SECOND, 
                 LAG(o.order_date) OVER (PARTITION BY o.user_id, DATE(o.order_date) ORDER BY o.order_date),
                 o.order_date
             ) < 60 
        THEN 'CRITICAL: Likely double-click bug (< 60 sec apart)'
        
        WHEN pd.order_count > 1 
        THEN 'WARNING: Multiple orders same day - Verify if intentional'
        
        ELSE 'OK'
    END AS duplicate_risk

FROM orders o
JOIN users u ON o.user_id = u.user_id
INNER JOIN potential_duplicates pd 
    ON o.user_id = pd.user_id 
    AND DATE(o.order_date) = pd.order_day
    AND o.order_total = pd.order_total
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id, u.full_name, o.order_total, o.order_date, o.order_status, pd.order_count
ORDER BY o.user_id, o.order_date;

-- ============================================
-- EXPECTED FINDINGS:
-- ============================================
-- Current data: NO duplicate orders found ✅
--
-- IF duplicates existed, impact would be:
--
-- Example: User 1 has 2 orders within 5 seconds
--   → Order 101: $299.99 at 14:30:00
--   → Order 102: $299.99 at 14:30:05
--   → Same items, same total, 5 seconds apart
--   → Probability: 95% it's a double-click bug
--
-- REAL-WORLD CONSEQUENCES:
-- ============================================
-- Scenario 1: Double-click on checkout
--   → User clicks "Complete Order"
--   → Button doesn't disable fast enough
--   → User clicks again (impatient)
--   → 2 orders created in database
--   → Customer charged twice: $299.99 × 2 = $599.98
--   → Credit card shows 2 charges
--   → Customer calls support: "Why was I charged twice?!"
--
-- Scenario 2: Inventory impact
--   → Order 1: Reduces stock by 1
--   → Order 2: Reduces stock by 1 again
--   → Customer only expects 1 item
--   → Warehouse ships 2 items
--   → Customer confused or keeps both
--   → Lost inventory
--
-- Scenario 3: Fraud detection triggered
--   → Bank sees 2 identical charges within seconds
--   → Flags as potential fraud
--   → Blocks card
--   → Customer can't complete other purchases
--
-- HOW TO IDENTIFY TRUE DUPLICATES:
-- ============================================
-- High probability duplicate if:
--   ✅ Same user_id
--   ✅ Same day (or within minutes)
--   ✅ Same order_total
--   ✅ Less than 60 seconds apart
--   ✅ Same items (check order_items)
--
-- Probably NOT a duplicate if:
--   ❌ Different totals
--   ❌ Different items
--   ❌ Hours apart (user placed 2 separate orders)
--
-- QA ACTIONS:
-- ============================================
-- 1. PREVENTION: Frontend safeguards
--    - Disable submit button after first click
--    - Show loading spinner
--    - Debounce button clicks (500ms)
--
-- 2. PREVENTION: Backend deduplication
--    - Generate unique order token on checkout page load
--    - Reject duplicate token submissions
--    - Idempotency key in API
--
-- 3. DETECTION: Monitor for duplicates
--    - Daily report: Orders within 60 sec from same user
--    - Alert if > 5 potential duplicates per day
--
-- 4. CLEANUP (if found):
--    - Review with customer: "Did you mean to order twice?"
--    - Refund duplicate if confirmed
--    - Update inventory
-- ============================================