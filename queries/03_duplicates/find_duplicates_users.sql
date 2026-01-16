-- ============================================
-- FIND DUPLICATE USERS - Duplicate Detection
-- ============================================
-- Purpose: Detected duplicate users
-- QA Focus: Validation of unique data
-- Bug Impact: Duplicate emails can cause authentication and account management problems
-- ============================================


SELECT * FROM USERS
WHERE email IN (
    SELECT email FROM users
    GROUP BY email
    HAVING COUNT(*) > 1
)
ORDER BY email;

-- ============================================
-- Expected findings:
-- [After running, note which emails are duplicated]
-- Emails duplicated: ID 10 and 4.
-- ============================================