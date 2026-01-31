-- ============================================
-- FIND PRODUCTS WITH $0 PRICE
-- ============================================
-- Business Impact: Revenue loss, customer gets free items
-- QA Question: "Can our system handle $0 prices correctly?"
-- ============================================

USE sql_for_qa_testing;

-- Find products with suspicious pricing
SELECT
    product_id,
    product_name,
    price,
    stock_quantity,

    -- Calculaate potential revenue
    CASE
        WHEN price = 0 AND stock_quantity > 0 THEN
            CONCAT('FREE ITEM - ', stock_quantity, ' units at risk')
        WHEN price < 0 THEN
            'NEGATIVE PRICE - Critical billing bug'
        WHEN PRICE = 0 AND stock_quantity = 0 THEN
            'Zero price + no stock  (low risk)'
        ELSE 'OK'
    END AS severity

FROM products
WHERE price <= 0
ORDER BY
    CASE
        WHEN price < 0 THEN 1
        WHEN price = 0 AND stock_quantity > 0 THEN 2
        ELSE 3
    END;

-- ============================================
-- Bugs found: 3
-- ============================================
-- Product 4: "Free Keyboard" - $0.00, stock 100
--   → Impact: 100 keyboards could be ordered for free
--   → Revenue loss: ~$3,000 (assuming $30 keyboard)
--
-- Product 6: "Broken Headphones" - NEGATIVE price
--   → Impact: System might PAY customer to buy it
--   → Critical billing bug
--
-- Product 10: "Out of Stock Item" - $0.00, stock 0  
--   → Impact: Low (can't be ordered anyway)
--
-- QA Action: Block checkout for price <= 0 items
-- ============================================