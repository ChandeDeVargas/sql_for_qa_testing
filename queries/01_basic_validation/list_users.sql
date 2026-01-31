-- ============================================
-- LIST USERS - Data Quality Check
-- ============================================
-- Business Impact: Bad user data = Failed emails, support tickets, lost customers
-- QA Question: "Can our system handle these users correctly?"
-- ============================================

USE sql_qa_testing;

-- Full user audit with validation flags
SELECT 
    user_id,
    email,
    full_name,
    created_at,
    account_status,
    
    -- QA Validation Flags
    CASE 
        WHEN full_name = '' OR full_name IS NULL THEN 'Empty name - Email personalization will fail'
        WHEN created_at > NOW() THEN 'Future date - Impossible data'
        WHEN email NOT LIKE '%@%' THEN 'Invalid email - Can\'t send notifications'
        ELSE 'OK'
    END AS issue_detected,
    
    -- Additional context
    DATEDIFF(NOW(), created_at) AS days_since_signup
    
FROM users
ORDER BY 
    CASE 
        WHEN full_name = '' THEN 1
        WHEN created_at > NOW() THEN 2
        ELSE 3
    END,
    user_id;

-- ============================================
--  What QA is looking for:
-- Bugs found: 2
-- ============================================
--  Valid users: Should display correctly, emails work
--  User 5: Empty name → "Welcome, !" in emails
--  User 8: Future date → Reports will be wrong
--  Users 1&4, 2&10: Duplicate emails → Login conflicts (see duplicates query)
--
-- Real-world impact:
-- - Empty names break email templates
-- - Future dates break analytics dashboards  
-- - Duplicates cause "email already exists" errors
-- ============================================