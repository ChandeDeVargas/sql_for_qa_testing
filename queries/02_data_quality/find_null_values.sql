-- ============================================
-- NULL VALUES - Missing Critical Data
-- ============================================
-- Business Impact: App crashes, emails fail, reports break
-- QA Question: "Can the system function with missing data?"
-- ============================================

USE sql_for_qa_testing;

-- ============================================
-- Check 1: Users with incomplete profiles
-- ============================================
SELECT
    user_id,
    full_name,
    email,
    account_status,
    
    -- Identify what's missing
    CASE
        WHEN full_name IS NULL THEN 
            'CRITICAL: NULL name - Email template will crash'
        WHEN TRIM(full_name) = '' THEN 
            'WARNING: Empty name - "Hello, !" in emails'
        WHEN email IS NULL THEN 
            'CRITICAL: NULL email - Can\'t contact user'
        WHEN TRIM(email) = '' THEN 
            'WARNING: Empty email - Invalid account'
        WHEN email NOT LIKE '%@%' THEN
            'WARNING: Invalid email format - Bounced emails'
        ELSE 'Complete'
    END AS data_issue,
    
    -- Business impact
    CASE
        WHEN full_name IS NULL OR TRIM(full_name) = '' THEN
            'Can\'t personalize: Welcome emails, support tickets'
        WHEN email IS NULL OR TRIM(email) = '' THEN
            'Can\'t contact: Password reset, order updates'
        ELSE 'N/A'
    END AS impact

FROM users
WHERE full_name IS NULL 
   OR TRIM(full_name) = '' 
   OR email IS NULL 
   OR TRIM(email) = ''
   OR email NOT LIKE '%@%';

-- Expected: User 5 with empty name

-- ============================================
-- Check 2: Products with incomplete catalog data
-- ============================================
SELECT
    product_id,
    product_name,
    price,
    stock_quantity,
    
    CASE
        WHEN product_name IS NULL THEN 
            'CRITICAL: NULL name - Can\'t display product'
        WHEN TRIM(product_name) = '' THEN
            'WARNING: Empty name - Shows as blank'
        WHEN price IS NULL THEN 
            'CRITICAL: NULL price - Checkout will crash'
        ELSE 'Complete'
    END AS data_issue

FROM products
WHERE product_name IS NULL 
   OR TRIM(product_name) = ''
   OR price IS NULL;

-- Expected: No NULL bugs in products (schema enforces NOT NULL)

-- ============================================
-- Check 3: Orders with missing references
-- ============================================
SELECT
    order_id,
    user_id,
    order_total,
    order_status,
    
    CASE
        WHEN user_id IS NULL THEN 
            'CRITICAL: NULL user_id - Orphaned order'
        WHEN order_total IS NULL THEN 
            'CRITICAL: NULL total - Billing impossible'
        WHEN order_status IS NULL THEN 
            'WARNING: NULL status - Can\'t track order'
        ELSE 'Complete'
    END AS data_issue

FROM orders
WHERE user_id IS NULL 
   OR order_total IS NULL 
   OR order_status IS NULL;

-- Expected: No NULL bugs (foreign keys enforce this)

-- ============================================
-- REAL-WORLD IMPACT:
-- ============================================
-- User 5: Empty name ('')
--   → Email template: "Hello, !" (looks unprofessional)
--   → Support ticket: "Ticket from " (no name)
--   → Can't search for user by name
--
-- If we HAD NULL emails:
--   → Can't send order confirmations
--   → Can't reset passwords
--   → Account is unusable
--
-- QA ACTION:
-- 1. Add NOT NULL constraints to critical columns
-- 2. Frontend validation: Require name and email
-- 3. Backend validation: Reject empty strings
-- 4. Data cleanup: Fix user 5's empty name
-- ============================================