-- ============================================
-- SQL FOR QA TESTING - Seed Data
-- ============================================
-- WARNING: This dataset contains intentional bugs for QA practice
-- Purpose: Simulate real-world data quality issues
-- ============================================

USE sql_qa_testing;

-- Clear existing data (respecting foreign keys)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE products;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- USERS DATA
-- Bugs: duplicates emails, empty names, future dates.
-- ============================================

INSERT INTO users (user_id, email, full_name, created_at, account_status) VALUES
-- Valid users
(1, 'john.doe@email.com', 'John Doe', '2024-01-15 10:00:00', 'active'),
(2, 'jane.smith@email.com', 'Jane Smith', '2024-02-20 14:30:00', 'active'),
(3, 'bob.wilson@email.com', 'Bob Wilson', '2024-03-10 09:15:00', 'active'),

-- BUG: Duplicate email
(4, 'john.doe@email.com', 'John Duplicate', '2024-04-05 11:20:00', 'active'),

-- BUG: Empty name (simulating null/missing data)
(5, 'empty.user@email.com', '', '2024-05-12 16:45:00', 'active'),

-- Valid users
(6, 'alice.brown@email.com', 'Alice Brown', '2024-06-18 08:30:00', 'inactive'),
(7, 'charlie.davis@email.com', 'Charlie Davis', '2024-07-22 13:00:00', 'active'),

-- BUG: Future creation date (impossible)
(8, 'future.user@email.com', 'Future User', '2027-12-31 23:59:59', 'active'),

-- Valid user (but suspended - edge case)
(9, 'diana.evans@email.com', 'Diana Evans', '2024-08-14 10:20:00', 'suspended'),

-- BUG: Another duplicate email
(10, 'jane.smith@email.com', 'Jane Duplicate', '2024-09-01 12:00:00', 'active'),

-- EDGE CASE: User who will never place an order (for LEFT JOIN testing)
(11, 'no.orders@email.com', 'Never Bought', '2024-10-01 08:00:00', 'active'),
(12, 'another.ghost@email.com', 'Ghost User', '2024-11-05 14:00:00', 'active');

-- ============================================
-- PRODUCTS DATA
-- Bugs: zero prices, negative prices, negative stock.
-- ============================================

INSERT INTO products(product_id, product_name, price, stock_quantity, created_at) VALUES
-- Valid products
(1, 'Laptop Pro 15"', 1299.99, 50, '2024-01-01 00:00:00'),
(2, 'Wireless Mouse', 29.99, 200, '2024-01-01 00:00:00'),
(3, 'USB-C Cable', 15.99, 500, '2024-01-01 00:00:00'),

-- BUG: Price is $0 (pricing error)
(4, 'Free Keyboard', 0.00, 100, '2024-01-01 00:00:00'),

-- Valid product
(5, 'Monitor 24"', 299.99, 75, '2024-01-01 00:00:00'),

-- BUG: Negative price (data entry error)
(6, 'Broken Headphones', -50.00, 10, '2024-01-01 00:00:00'),

-- BUG: Negative stock (inventory system bug)
(7, 'Webcam HD', 89.99, -5, '2024-01-01 00:00:00'),

-- Valid products
(8, 'External SSD 1TB', 149.99, 30, '2024-01-01 00:00:00'),
(9, 'Mechanical Keyboard', 129.99, 40, '2024-01-01 00:00:00'),

-- BUG: Price $0 AND stock 0 (double issue)
(10, 'Out of Stock Item', 0.00, 0, '2024-01-01 00:00:00'),

-- EDGE CASE: Product that will never be ordered (dead inventory)
(11, 'Unpopular Gadget', 999.99, 100, '2024-01-01 00:00:00'),
(12, 'Ancient Accessory', 5.99, 5, '2024-01-01 00:00:00');


-- ============================================
-- ORDERS DATA (Header/Summary)
-- Bugs: negative totals, futures dates, orphaned records
-- ============================================

INSERT INTO orders (order_id, user_id, order_total, order_date, order_status) VALUES
-- Valid orders
(1, 1, 1299.99, '2024-03-15 14:30:00', 'completed'),
(2, 2, 59.98, '2024-03-16 10:20:00', 'completed'),
(3, 3, 79.95, '2024-03-17 16:45:00', 'pending'),

-- BUG: Negative total (calculation error)
(4, 1, -299.99, '2024-03-18 09:15:00', 'completed'),

-- Valid orders
(5, 2, 149.99, '2024-03-19 11:30:00', 'completed'),
(6, 7, 129.99, '2024-03-22 10:00:00', 'completed'),

-- BUG: Future order date (impossible)
(7, 1, 89.97, '2027-12-25 00:00:00', 'pending'),

-- BUG: Order with $0 total (billing issue)
(8, 3, 0.00, '2024-03-26 11:00:00', 'pending'),

-- Valid orders
(9, 6, 1299.99, '2024-03-24 09:30:00', 'cancelled'),
(10, 7, 599.98, '2024-03-25 16:00:00', 'completed'),

-- BUG: Order total doesn't match items (will create in order_items)
(11, 2, 100.00, '2024-03-23 14:00:00', 'completed'),

-- Valid order
(12, 9, 89.99, '2024-03-28 10:45:00', 'completed'),

-- EDGE CASE: Order without items (orphaned order - no items will be added)
(13, 3, 500.00, '2024-04-01 10:00:00', 'pending');

-- ============================================
-- ORDER ITEMS DATA (Line Items/Details)
-- Bugs: broken product references, total mismatches
-- ============================================

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, line_total) VALUES
-- Order 1: Valid
(1, 1, 1, 1, 1299.99, 1299.99),

-- Order 2: Valid
(2, 2, 2, 2, 29.99, 59.98),

-- Order 3: Valid
(3, 3, 3, 5, 15.99, 79.95),

-- Order 4: Valid items (but order total is negative - bug in orders table)
(4, 4, 5, 1, 299.99, 299.99),

-- Order 5: Valid
(5, 5, 8, 1, 149.99, 149.99),

-- Order 6: Valid
(6, 6, 9, 1, 129.99, 129.99),

-- Order 7: Valid items (but order date is future - bug in orders table)
(7, 7, 2, 3, 29.99, 89.97),

-- Order 8: Valid items (but order total is $0 - bug in orders table)
(8, 8, 2, 1, 29.99, 29.99),

-- Order 9: Valid
(9, 9, 1, 1, 1299.99, 1299.99),

-- Order 10: Valid (2 items in same order)
(10, 10, 5, 2, 299.99, 599.98),

-- Order 11: BUG - Total mismatch (items = $159.90, but order total = $100.00)
(11, 11, 3, 10, 15.99, 159.90),

-- Order 12: Valid
(12, 12, 7, 1, 89.99, 89.99),

-- BUG: Item references non-existent product_id
(13, 5, 999, 1, 50.00, 50.00),

-- BUG: Negative quantity
(14, 6, 8, -2, 149.99, -299.98),

-- BUG: Quantity is 0
(15, 3, 2, 0, 29.99, 0.00);

SET FOREIGN_KEY_CHECKS = 1;

-- Order 13 has NO items (intentionally orphaned)

-- ============================================
-- SUMMARY OF BUGS PLANTED:
-- ============================================

-- USERS:
-- - 2 duplicate emails (user_id 184, 2&10)
-- - 1 empty name (user_id 5)
-- - 1 future date (user_id 8)
-- - 2 users with no orders (user_id 11, 12)

-- PRODUCTS:
-- - 2 products with price = $0 (product_id 4, 10))
-- - 1 product with negative price (product_id 6)
-- - 1 product with negative stock (product_id 7)
-- - 2 products never ordered (product_id 11, 12)

-- ORDERS:
-- - 1 order with negative total (order_id 4)
-- - 1 order with future date (order_id 7)
-- - 1 order with $0 total (order_id 8)
-- - 1 order with total mismatch (order_id 11)
-- - 1 oder without items (order_id 13)

-- ORDER_ITEMS:
-- - 1 item with non-existent product (item_id 13, product_id 999)
-- - 1 item with negative quantity (item_id 14)
-- - 1 item with zero quantity (item_id 15)

-- TOTAL BUGS: ~15

-- ============================================
-- END OF SEED DATA
-- ============================================
