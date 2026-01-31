-- ============================================
-- ORDER ANALYSIS - Financial Impact Check
-- ============================================
-- Business Impact: Wrong totals = Customer disputes, chargebacks
-- QA Question: "Are we charging customers correctly?"
-- ============================================

USE sql_for_qa_testing;

-- Analyze all orders with financial validation
SELECT
    o.order_id,
    u.full_name AS customer,
    o.order_total,
    o.order_date,
    o.order_status,
    
    -- Calculate items total (will compare later)
    (SELECT COALESCE(SUM(oi.line_total), 0) 
     FROM order_items oi 
     WHERE oi.order_id = o.order_id) AS items_total,
    
    -- QA Validation
    CASE
        WHEN o.order_total < 0 THEN 
            'NEGATIVE TOTAL - We\'re paying the customer?'
        WHEN o.order_total = 0 THEN 
            'ZERO TOTAL - Free order or bug?'
        WHEN o.order_date > NOW() THEN
            'FUTURE DATE - Time travel order'
        WHEN o.order_total != (SELECT COALESCE(SUM(oi.line_total), 0) 
                                FROM order_items oi 
                                WHERE oi.order_id = o.order_id) THEN
            'TOTAL MISMATCH - Billing error!'
        ELSE 'OK'
    END AS financial_issue,
    
    -- Risk ranking
    RANK() OVER (ORDER BY ABS(o.order_total) DESC) AS revenue_risk_rank
    
FROM orders o
JOIN users u ON o.user_id = u.user_id
ORDER BY 
    CASE 
        WHEN o.order_total < 0 THEN 1
        WHEN o.order_total = 0 THEN 2
        WHEN o.order_date > NOW() THEN 3
        ELSE 4
    END,
    o.order_id;

-- ============================================
-- Critical bugs found: 4
-- ============================================
-- Order 4: Total = -$299.99
--   → Impact: Customer paid negative amount (refund without request?)
--   → Revenue loss: $299.99
--
-- Order 8: Total = $0.00  
--   → Impact: Free order processed
--   → Revenue loss: Check items_total
--
-- Order 7: Future date (2027-12-25)
--   → Impact: Reports will be wrong, analytics broken
--
-- Order 11: Total mismatch (stored vs calculated)
--   → Impact: Customer charged wrong amount
--   → Potential lawsuit/chargeback
--
-- QA Recommendation: 
-- - Block orders with total <= 0
-- - Validate total = SUM(items) before saving
-- - Add date validation (can't be future)
-- ============================================