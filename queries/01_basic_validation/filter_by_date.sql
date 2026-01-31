-- ============================================
-- DATE VALIDATION - Time-Based Data Quality
-- ============================================
-- Business Impact: Bad dates break reports, analytics, forecasts
-- QA Question: "Are order dates realistic?"
-- ============================================

USE sql_for_qa_testing;

-- Find orders with suspicious dates

SELECT
    order_id,
    user_id,
    order_total,
    order_date,
    order_status,
    
    -- Date validation
    CASE
        WHEN order_date > NOW() THEN 
            CONCAT('FUTURE DATE - ', DATEDIFF(order_date, NOW()), ' days ahead')
        WHEN order_date < '2020-01-01' THEN 
            'Very old order (before system launch?)'
        WHEN order_total <= 0 THEN 
            'Invalid total (not date issue, but still bad)'
        ELSE 'OK'
    END AS date_issue,
    
    DATEDIFF(NOW(), order_date) AS days_ago
    
FROM orders
WHERE 
    order_date > NOW()                    -- Future orders
    OR order_date < '2020-01-01'          -- Suspiciously old
    OR order_total <= 0                   -- Include financial bugs too
ORDER BY order_date DESC;

-- ============================================
-- Bugs found: 3
-- ============================================
-- Order 7: Date = 2027-12-25 (3+ years in future)
--   → Impact: 
--     - "Recent orders" report shows this
--     - Analytics thinks we have sales in 2027
--     - Inventory forecasting is wrong
--
-- Order 4: Negative total (-$299.99)
-- Order 8: Zero total ($0.00)
--   → Not date bugs, but caught here for completeness
--
-- QA Action:
-- - Add constraint: order_date <= NOW()
-- - Validate dates on frontend AND backend
-- ============================================