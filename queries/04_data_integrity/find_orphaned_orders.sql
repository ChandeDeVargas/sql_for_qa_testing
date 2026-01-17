-- ============================================
-- FIND ORPHANED ORDERS - Data Integrity Check
-- ============================================
-- Purpose: Find orders that do not have a corresponding user in the users table.
-- QA Focus: Data integrity and foreign key relationships.
-- Bug Impact: Orphaned orders can cause application crashes, incorrect reports, 
-- and financial reconciliation issues.
-- ============================================

SELECT o.*
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- ============================================
-- Expected findings:
-- [id 6 it is orphaned]
-- ============================================