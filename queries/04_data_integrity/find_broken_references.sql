-- ============================================
-- BROKEN PRODUCT REFERENCES - Missing Inventory Links
-- ============================================
-- Business Impact: Orders reference products that don't exist = Display errors, reports broken
-- QA Question: "Are we selling products that aren't in our catalog?"
-- Real-world scenario: Product deleted but order_items still reference it
-- ============================================

USE sql_qa_testing;

-- Find order items pointing to non-existent products
SELECT
    oi.item_id,
    oi.order_id,
    oi.product_id AS missing_product_id,
    oi.quantity,
    oi.unit_price,
    oi.line_total,

    -- Get order details
    o.order_date,
    o.order_status,
    u.full_name AS customer,

    -- Severity assessment
    CASE
        WHEN o.order_status = 'Completed' THEN
        CONCAT('CRITICAL: Completed order, product missing - Cannot process returns')
        WHEN o.order_status = 'Pending' THEN
        CONCAT('CRITICAL: Pending order, product missing - Cannot fulfill')
        WHEN o.order_status = 'Cancelled' THEN
        CONCAT('LOW: Cancelled order (already handled)')
        ELSE 'Unknown status'
    END AS severity,

    -- Calculate financial impact
    oi.line_total AS revenue_affected

FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN users u ON o.user_id = u.user_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
ORDER BY o.order_status, oi.line_total DESC;

-- ============================================
-- CRITICAL BUG FOUND:
-- ============================================
-- Order Item 13: References product_id 999 (doesn't exist)
--   → order_id: 5
--   → quantity: 1
--   → price: $50.00
--   → Customer: Jane Smith
--   → Status: completed
--
-- REAL-WORLD CONSEQUENCES:
-- ============================================
-- Scenario 1: Order history page
--   → Customer views "My Orders"
--   → Clicks on order #5
--   → Item shows: "[Product Not Found]"
--   → Customer confused: "What did I buy?"
--   → Support ticket created
--
-- Scenario 2: Returns/Exchanges
--   → Customer wants to return item
--   → System tries to load product details
--   → ERROR: Product 999 not found
--   → Return form crashes
--   → Customer can't return item
--
-- Scenario 3: Inventory reconciliation
--   → Monthly inventory report
--   → Order items reference product 999
--   → But product doesn't exist
--   → Report shows "Unknown" product
--   → Accounting can't reconcile
--
-- Scenario 4: Re-order functionality
--   → Customer clicks "Buy Again"
--   → System tries to add product 999 to cart
--   → ERROR: Product not found
--   → Feature broken
--
-- HOW DID THIS HAPPEN?
-- ============================================
-- Possible causes:
--   1. Product deleted AFTER order placed
--      → Missing ON DELETE RESTRICT constraint
--   2. Manual database cleanup
--      → Someone deleted "discontinued" products
--      → Didn't check if they're in orders
--   3. Data migration error
--      → Product IDs changed between systems
--      → Order items not updated
--   4. Bug in product deletion feature
--      → Allows deleting products with existing orders
--
-- QA ACTIONS:
-- ============================================
-- 1. PREVENTION: Add foreign key constraint
--    ALTER TABLE order_items 
--    ADD CONSTRAINT fk_item_product 
--    FOREIGN KEY (product_id) REFERENCES products(product_id)
--    ON DELETE RESTRICT;  -- ← Can't delete products in orders
--
-- 2. CLEANUP (if found):
--    Option A: Restore deleted product (if possible)
--      - Find product in backups
--      - Re-insert with same product_id
--    
--    Option B: Create placeholder product
--      - INSERT INTO products (product_id, product_name, price, stock_quantity)
--        VALUES (999, '[Deleted Product]', 50.00, 0);
--      - Add note: "Product discontinued, reference only"
--
-- 3. BUSINESS PROCESS: Soft delete
--    - Don't physically DELETE products
--    - Add column: is_deleted BOOLEAN
--    - Hide from catalog but keep in database
--    - Preserves order history integrity
-- ============================================