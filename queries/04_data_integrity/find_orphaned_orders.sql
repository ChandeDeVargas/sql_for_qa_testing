-- ============================================
-- ORPHANED ORDERS - Ghost Orders Detection
-- ============================================
-- Business Impact: Orders exist but user deleted/never existed = Lost revenue tracking
-- QA Question: "Can we fulfill orders for users that don't exist?"
-- Real-world scenario: User deletes account but orders remain orphaned
-- ============================================

USE sql_qa_testing;

-- Find orders withou a valid user
SELECT
    o.order_id,
    o.user_id AS missing_user_id,
    o.order_total,
    o.order_date,
    o.order_status,

    -- Show what items are in this ghost order
    (SELECT GROUP_CONCAT(p.product_name SEPARATOR ', ')
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = o.order_id) AS items_orderder,

    -- Calculate age of orphaned order
    DATEDIFF(NOW(), o.order_date) AS days_orphaned,

    -- Financial impact
    CASE
        WHEN o.order_status = 'completed' THEN
        CONCAT('CRITICAL: Completed order with no user - Revenue: $', o.order_total)
        WHEN o.order_status = 'Pending' THEN
        CONCAT('WARNING: Pending order orphaned - Cannot contact customer')
        WHEN o.order_status = 'Cancelled' THEN
        'LOW: Cancelled order (already handled)'
        ELSE 'Unknow status'
    END AS severity

FROM orders o
LEFT JOIN users u ON o.user_id = u.user_id
WHERE u.user_id IS NULL
ORDER BY o.order_date, o.order_total DESC;

-- ============================================
-- CRITICAL BUG FOUND (if using old schema):
-- ============================================
-- NOTE: With NEW schema (4 tables), this won't find bugs
-- because we removed orphaned orders from seed_data.
--
-- IF you find orphaned orders, impact is:
--
-- Example: Order 6 (old schema)
--   → user_id: 999 (doesn't exist)
--   → total: $1,299.99
--   → status: pending
--   → Problem: Who placed this order?
--
-- REAL-WORLD CONSEQUENCES:
-- ============================================
-- Scenario 1: Order fulfillment
--   → Warehouse prepares order
--   → Tries to get shipping address
--   → ERROR: User not found
--   → Order stuck in limbo
--
-- Scenario 2: Customer communication
--   → System tries to send "Order shipped" email
--   → No user = No email address
--   → Customer never notified
--
-- Scenario 3: Financial reconciliation
--   → Revenue report: $1,299.99
--   → Customer report: No matching customer
--   → Accounting can't reconcile
--   → Audit flags as suspicious
--
-- Scenario 4: Returns/Refunds
--   → Customer wants to return item
--   → Support can't find user account
--   → Can't process refund
--   → Customer escalates to credit card chargeback
--
-- HOW DID THIS HAPPEN?
-- ============================================
-- Possible causes:
--   1. User deleted account AFTER placing order
--      → Missing ON DELETE CASCADE constraint
--   2. Data migration error
--      → Old system user IDs didn't match new system
--   3. Manual database edit
--      → Someone deleted user without checking orders
--   4. Bug in registration
--      → Order created before user fully registered
--
-- QA ACTIONS:
-- ============================================
-- 1. PREVENTION: Add foreign key constraint with proper handling
--    ALTER TABLE orders 
--    ADD CONSTRAINT fk_order_user 
--    FOREIGN KEY (user_id) REFERENCES users(user_id)
--    ON DELETE RESTRICT;  -- ← Prevent deleting users with orders
--
-- 2. CLEANUP (if found):
--    Option A: Create placeholder user
--      - INSERT INTO users (user_id, email, full_name)
--        VALUES (999, 'deleted@system.com', '[Deleted User]');
--    
--    Option B: Cancel orphaned orders
--      - UPDATE orders SET order_status = 'cancelled'
--        WHERE user_id NOT IN (SELECT user_id FROM users);
--
-- 3. MONITORING: Daily check
--    - Run this query daily
--    - Alert if orphaned orders > 0
--    - Investigate immediately
-- ============================================