-- ============================================
-- FIND NULL VALUES - Data Quality Check
-- ============================================
-- Purpose: Detect incomplete records with missing mandatory fields
-- QA Focus: Data completeness
-- ============================================

-- Query 1: Users with missing mandatory fields
SELECT
    id,
    name,
    email,
    created_at,
    CASE
        WHEN name IS NULL THEN 'Critical: Missing Name'
        WHEN name = '' THEN 'Warning: Empty Name'
        WHEN email IS NULL THEN 'Critical: Missing Email'
        WHEN email = '' THEN 'Warning: Empty Email'
    END AS missing_field
FROM users
WHERE name IS NULL OR email IS NULL OR trim(name) = '' OR trim(email) = '';

-- Query 2: Products with missing mandatory fields
SELECT
    id,
    name,
    price,
    created_at,
    CASE
        WHEN name IS NULL THEN 'Critical: Missing Name'
        WHEN price IS NULL THEN 'Critical: Missing Price'
    END AS missing_field
FROM products
WHERE name IS NULL OR price IS NULL;

-- Query 3: Orders with missing mandatory fields
SELECT
    id,
    user_id,
    product_id,
    total,
    status,
    order_date,
    CASE
        WHEN user_id IS NULL THEN 'Critical: Missing User ID'
        WHEN product_id IS NULL THEN 'Critical: Missing Product ID'
        WHEN total IS NULL THEN 'Critical: Missing Total'
        WHEN status IS NULL THEN 'Critical: Missing Status'
    END AS missing_field
FROM orders
WHERE user_id IS NULL 
   OR product_id IS NULL 
   OR total IS NULL 
   OR status IS NULL;

-- ============================================
-- Findings:
-- - No null values found in critical columns (Users, Products, Orders).
-- - Data completeness verified successfully.
-- ============================================
