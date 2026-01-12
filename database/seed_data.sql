-- ============================================
-- SQL FOR QA TESTING - Seed Data
-- WARNING: This dataset contains intentional bugs for QA practice
-- ============================================

USE sql_for_qa_testing;

-- Clear existing data
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE orders;
TRUNCATE TABLE users;
TRUNCATE TABLE products;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- USERS DATA
-- Bugs included: duplicates, null values, invalid data
-- ============================================

INSERT INTO users (id, email, name, created_at, status) VALUES
-- Valid users
(1, 'john.doe@email.com', 'John Doe', '2024-01-15 10:00:00', 'active'),
(2, 'jane.smith@email.com', 'Jane Smith', '2024-02-20 14:30:00', 'active'),
(3, 'bob.wilson@email.com', 'Bob Wilson', '2024-03-10 09:15:00', 'active'),

-- BUG: Duplicate email
(4, 'john.doe@email.com', 'John Duplicate', '2024-04-05 11:20:00', 'active'),

-- BUG: NULL in required field (name is empty string, simulating null)
(5, 'empty.user@email.com', '', '2024-05-12 16:45:00', 'active'),

-- Valid users
(6, 'alice.brown@email.com', 'Alice Brown', '2024-06-18 08:30:00', 'inactive'),
(7, 'charlie.davis@email.com', 'Charlie Davis', '2024-07-22 13:00:00', 'active'),

-- BUG: Invalid future date
(8, 'future.user@email.com', 'Future User', '2027-12-31 23:59:59', 'active'),

-- Valid user
(9, 'diana.evans@email.com', 'Diana Evans', '2024-08-14 10:20:00', 'banned'),

-- BUG: Another duplicate email
(10, 'jane.smith@email.com', 'Jane Duplicate', '2024-09-01 12:00:00', 'active');

-- ============================================
-- PRODUCTS DATA
-- Bugs included: zero/negative prices, invalid stock
-- ============================================

INSERT INTO products(id, name, price, stock,created_at)
VALUES
-- Valid products
(1, 'Laptop Pro 15"', 1299.99, 50, '2024-01-01 00:00:00'),
(2, 'Wireless Mouse', 29.99, 200, '2024-01-01 00:00:00'),
(3, 'USB-C Cable', 15.99, 500, '2024-01-01 00:00:00'),

-- BUG: Price is 0
(4, 'Free Keyboard', 0.00, 100, '2024-01-01 00:00:00'),

-- Valid product
(5, 'Monitor 24"', 299.99, 75, '2024-01-01 00:00:00'),

-- BUG: Negative price
(6, 'Broken Headphones', -50.00, 10, '2024-01-01 00:00:00'),

-- BUG: Negative stock
(7, 'Webcam HD', 89.99, -5, '2024-01-01 00:00:00'),

-- Valid products
(8, 'External SSD 1TB', 149.99, 30, '2024-01-01 00:00:00'),
(9, 'Mechanical Keyboard', 129.99, 40, '2024-01-01 00:00:00'),

-- BUG: Price 0 and stock 0
(10, 'Out of Stock Item', 0.00, 0, '2024-01-01 00:00:00');

-- ============================================
-- ORDERS DATA
-- Bugs included: orphaned orders, negative totals, invalid dates, broken references
-- ============================================

INSERT INTO orders (id, user_id, product_id, quantity, total, order_date, status) VALUES
-- Valid orders
(1, 1, 1, 1, 1299.99, '2024-03-15 14:30:00', 'completed'),
(2, 2, 2, 2, 59.98, '2024-03-16 10:20:00', 'completed'),
(3, 3, 3, 5, 79.95, '2024-03-17 16:45:00', 'pending'),

-- BUG: Negative total
(4, 1, 5, 1, -299.99, '2024-03-18 09:15:00', 'completed'),

-- Valid order
(5, 2, 8, 1, 149.99, '2024-03-19 11:30:00', 'completed'),

-- BUG: user_id doesn't exist (orphaned order)
(6, 999, 1, 1, 1299.99, '2024-03-20 13:00:00', 'pending'),

-- BUG: product_id doesn't exist (broken reference)
(7, 3, 999, 1, 99.99, '2024-03-21 15:20:00', 'pending'),

-- Valid order
(8, 7, 9, 1, 129.99, '2024-03-22 10:00:00', 'completed'),

-- BUG: Future order date
(9, 1, 2, 3, 89.97, '2027-12-25 00:00:00', 'pending'),

-- BUG: Total doesn't match calculation (quantity * price)
(10, 2, 3, 10, 100.00, '2024-03-23 14:00:00', 'completed'), -- Should be 159.90

-- Valid orders
(11, 6, 1, 1, 1299.99, '2024-03-24 09:30:00', 'cancelled'),
(12, 7, 5, 2, 599.98, '2024-03-25 16:00:00', 'completed'),

-- BUG: Quantity is 0
(13, 3, 2, 0, 0.00, '2024-03-26 11:00:00', 'pending'),

-- BUG: Negative quantity
(14, 1, 8, -2, -299.98, '2024-03-27 12:30:00', 'pending'),

-- Valid order
(15, 9, 7, 1, 89.99, '2024-03-28 10:45:00', 'completed');