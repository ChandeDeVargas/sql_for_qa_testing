-- ============================================
-- ZERO PRICES - Free Money Detection
-- ============================================
-- Business Impact: Customers getting items for FREE = Revenue loss
-- QA Question: "Are we giving away products accidentally?"
-- Severity: HIGH - Direct financial impact
-- ============================================

USE sql_qa_testing;

-- ============================================
-- Check 1: Products with suspicious pricing
-- ============================================
SELECT
    product_id,
    product_name,
    price,
    stock_quantity,
    
    -- Severity assessment
    CASE
        WHEN price < 0 THEN 
            CONCAT('CRITICAL: NEGATIVE $', ABS(price), ' - System will PAY customer')
        WHEN price = 0 AND stock_quantity > 0 THEN 
            CONCAT('CRITICAL: FREE ITEM - ', stock_quantity, ' units at risk')
        WHEN price = 0 AND stock_quantity = 0 THEN 
            'LOW RISK: $0 + no stock (can\'t be ordered)'
        ELSE 'Valid'
    END AS pricing_issue,
    
    -- Calculate potential loss
    CASE
        WHEN price = 0 AND stock_quantity > 0 THEN
            stock_quantity * 30.00  -- Assume avg $30 value
        WHEN price < 0 THEN
            ABS(price) * stock_quantity
        ELSE 0
    END AS estimated_revenue_at_risk,
    
    -- Already sold at bad price?
    (SELECT COUNT(*) 
     FROM order_items oi 
     WHERE oi.product_id = p.product_id) AS times_already_sold

FROM products p
WHERE price <= 0
ORDER BY 
    CASE 
        WHEN price < 0 THEN 1
        WHEN price = 0 AND stock_quantity > 0 THEN 2
        ELSE 3
    END,
    estimated_revenue_at_risk DESC;

-- ============================================
-- Check 2: Orders that charged $0 (already happened)
-- ============================================
SELECT
    o.order_id,
    u.full_name AS customer,
    o.order_total,
    o.order_date,
    o.order_status,
    
    -- What they got for free
    GROUP_CONCAT(p.product_name SEPARATOR ', ') AS free_items,
    SUM(oi.line_total) AS should_have_paid,
    
    'CRITICAL: Revenue lost' AS impact

FROM orders o
JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE o.order_total = 0
GROUP BY o.order_id, u.full_name, o.order_total, o.order_date, o.order_status;

-- ============================================
-- CRITICAL BUGS FOUND: 4
-- ============================================
-- Product 4: "Free Keyboard" - $0.00, stock 100
--   → 100 keyboards available for FREE
--   → Estimated value: $3,000 (100 × $30)
--   → Already sold: Check times_already_sold column
--   → ACTION: Set correct price IMMEDIATELY
--
-- Product 6: "Broken Headphones" - NEGATIVE $50.00
--   → If someone buys this, we PAY them $50
--   → Stock: 10 units
--   → Potential loss: $500
--   → ACTION: Delete or fix price NOW
--
-- Product 10: "Out of Stock" - $0.00, stock 0
--   → Low risk (can't be ordered)
--   → But still wrong data
--
-- Order 8: Customer got $29.99 item for $0
--   → Already happened, money lost
--   → ACTION: Contact customer, issue corrected invoice?
--
-- TOTAL REVENUE AT RISK: $3,500+
--
-- QA ACTION:
-- 1. URGENT: Block checkout for price <= 0 items
-- 2. Add constraint: CHECK (price > 0)
-- 3. Audit: How many orders already affected?
-- 4. Fix all $0 prices in database
-- 5. Alert finance team
-- ============================================