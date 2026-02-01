-- ============================================
-- DUPLICATE USERS - Identity Conflict Detection
-- Business Impact: Login failures, password reset conflicts, support nightmares
-- QA Question: "Can two people use the same email to login?"
-- Real-world scenario: User tries to register → "Email already exists" → Confusion
-- ============================================

USE sql_qa_testing;

-- Find all users with duplicate emails
SELECT
    u.user_id,
    u.email,
    u.full_name,
    u.created_at,
    u.account_status,

    -- Show how many accounts share this email
    (SELECT COUNT(*)
    FROM users u2
    WHERE u2.email = u.email) AS duplicate_count,

    -- Severity assessment
    CASE
        WHEN (SELECT COUNT(*) FROM users u2 WHERE u2.email = u.email) > 1 THEN
        'CRITICAL: Email collision - Login system broken'
        ELSE 'Unique'

    END AS issue_severity,

    -- Days between duplicate accounts
    DATEDIFF(
        u.created_at,
        (SELECT MIN(u3.created_At)
        FROM users u3
        WHERE u3.email = u.email)
    ) AS days_after_first_account

FROM users u
WHERE EXISTS (
    SELECT 1 
    FROM users u2 
    WHERE u2.email = u.email 
    AND u2.user_id <> u.user_id
)
ORDER BY u.email, u.created_at;

-- ============================================
-- CRITICAL BUGS FOUND:
-- ============================================
-- Email: john.doe@email.com
--   → User 1: "John Doe" (created first - 2024-01-15)
--   → User 4: "John Duplicate" (created later - 2024-04-05)
--   → Gap: 80 days between accounts
--   → Impact: Which account logs in? Password reset goes to which one?
--
-- Email: jane.smith@email.com
--   → User 2: "Jane Smith" (created first - 2024-02-20)
--   → User 10: "Jane Duplicate" (created later - 2024-09-01)
--   → Gap: 193 days
--   → Impact: Same login conflicts
--
-- TOTAL AFFECTED: 2 emails, 4 user accounts
--
-- REAL-WORLD CONSEQUENCES:
-- ============================================
-- Scenario 1: Login attempt
--   → User enters john.doe@email.com
--   → System: "Which account?" (but user doesn't know there are 2)
--   → Result: Login fails or wrong account accessed
--
-- Scenario 2: Password reset
--   → User clicks "Forgot password"
--   → System sends reset email
--   → But which account gets reset?
--   → User 1 or User 4?
--
-- Scenario 3: New registration
--   → New user tries to register with john.doe@email.com
--   → System: "Email already exists"
--   → But there are already 2 accounts!
--
-- QA ACTIONS:
-- ============================================
-- 1. IMMEDIATE: Add UNIQUE constraint on email column
--    ALTER TABLE users ADD UNIQUE (email);
--
-- 2. DATA CLEANUP: Decide which accounts to keep
--    - Keep oldest account (User 1, User 2)
--    - Merge data if needed
--    - Delete duplicates (User 4, User 10)
--
-- 3. PREVENTION: Frontend validation
--    - Check email availability before registration
--    - Show clear error if email exists
--
-- 4. INVESTIGATION: How did this happen?
--    - Bug in registration form?
--    - Missing database constraint?
--    - Data migration error?
-- ============================================