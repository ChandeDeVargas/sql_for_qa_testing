-- ============================================
-- LIST USERS - Basic Validation
-- ============================================
-- Purpose: List all users and identify potential data issues
-- QA Focus: Empty names, invalid emails, suspicious dates
-- ============================================

-- List all users with key information
SELECT 
    id,
    email,
    name,
    created_at,
    status,
    -- Flag potential issues
    CASE 
        WHEN name = '' THEN 'WARNING: Empty name'
        WHEN created_at > NOW() THEN 'WARNING: Future date'
        WHEN email NOT LIKE '%@%' THEN 'WARNING: Invalid email'
        ELSE 'OK'
    END AS validation_status
FROM users
ORDER BY id;

-- ============================================
-- Expected bugs to find:
-- - User ID 5: Empty name
-- - User ID 8: Future creation date
-- - User ID 1 & 4: Duplicate email (will detect in duplicates section)
-- - User ID 2 & 10: Duplicate email
-- ============================================