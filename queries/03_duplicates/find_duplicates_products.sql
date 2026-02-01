-- ============================================
-- DUPLICATE PRODUCTS - Catalog Integrity Check
-- ============================================
-- Business Impact: Inventory confusion, pricing conflicts, customer complaints
-- QA Question: "Are we selling the same product twice under different IDs?"
-- Real-world scenario: Same laptop listed twice with different prices
-- ============================================

USE sql_qa_testing;

-- Find products with duplicate names (case-insensitive)
SELECT
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity,
    
    -- Show how many products have this name
    (SELECT COUNT(*) 
     FROM products p2 
     WHERE LOWER(p2.product_name) = LOWER(p.product_name)) AS duplicate_count,
    
    -- Price variation check
    (SELECT MAX(p3.price) - MIN(p3.price)
     FROM products p3
     WHERE LOWER(p3.product_name) = LOWER(p.product_name)) AS price_difference,
    
    -- Severity assessment
    CASE
        WHEN (SELECT COUNT(*) FROM products p2 WHERE LOWER(p2.product_name) = LOWER(p.product_name)) > 1 
             AND (SELECT MAX(p3.price) - MIN(p3.price) FROM products p3 WHERE LOWER(p3.product_name) = LOWER(p.product_name)) > 0 
        THEN 'CRITICAL: Same product, different prices - Customer confusion'
        
        WHEN (SELECT COUNT(*) FROM products p2 WHERE LOWER(p2.product_name) = LOWER(p.product_name)) > 1 
        THEN 'WARNING: Duplicate name - Inventory tracking issue'
        
        ELSE 'Unique'
    END AS issue_severity,
    
    -- How many times ordered (helps decide which to keep)
    (SELECT COUNT(*) 
     FROM order_items oi 
     WHERE oi.product_id = p.product_id) AS times_ordered

FROM products p
WHERE EXISTS (
    SELECT 1 
    FROM products p2 
    WHERE LOWER(p2.product_name) = LOWER(p.product_name) 
    AND p2.product_id <> p.product_id
)
ORDER BY LOWER(p.product_name), p.price;

-- ============================================
-- EXPECTED FINDINGS:
-- ============================================
-- Current data: NO duplicate product names found ✅
--
-- IF duplicates existed, impact would be:
--
-- Example: "Laptop Pro 15"" appears twice
--   → Product 1: $1,299.99, stock 50
--   → Product 2: $1,199.99, stock 30
--   → Problem: Same laptop, different prices
--   → Impact: Which one shows on website?
--            Customer sees $1,199, but gets charged $1,299
--            Inventory split across 2 IDs
--
-- REAL-WORLD CONSEQUENCES:
-- ============================================
-- Scenario 1: Pricing inconsistency
--   → Customer finds product via search: $1,199
--   → Clicks "Buy Now", cart shows: $1,299
--   → Customer: "This is a scam!" → Abandoned cart
--
-- Scenario 2: Inventory tracking
--   → Warehouse has 80 Laptops total
--   → System shows: 50 + 30 (in 2 records)
--   → Reports think we have 2 different products
--   → Restock orders wrong quantities
--
-- Scenario 3: Analytics broken
--   → "Top selling products" report
--   → Shows both entries separately
--   → Laptop sales split across 2 IDs
--   → Can't identify true bestseller
--
-- QA ACTIONS:
-- ============================================
-- 1. PREVENTION: Add composite unique constraint
--    CREATE UNIQUE INDEX idx_product_name 
--    ON products(LOWER(product_name));
--
-- 2. DATA CLEANUP (if duplicates found):
--    - Identify which product to keep (most orders? lowest ID?)
--    - Update order_items to point to kept product
--    - Merge stock quantities
--    - Delete duplicate
--
-- 3. BUSINESS LOGIC: Product matching
--    - Add SKU/UPC fields for true uniqueness
--    - Name alone isn't enough (e.g., "USB Cable" could be many)
--    - Consider: name + brand + model for uniqueness
-- ============================================