-- ============================================
-- NEGATIVE TOTALS - Financial Disaster Detection
-- ============================================
-- Business Impact: We're PAYING customers instead of charging them
-- QA Question: "Are we losing money on these orders?"
-- Severity: CRITICAL - Direct revenue loss
-- ============================================

USE sql_qa_testing;

SELECT
    o.order_id,
    u.full_name AS customer,
    o.order_total AS charged_amount,
    o.order_date,
    o.order_status,

    -- Calculate what it should be
    COALESCE(SUM(oi.line_total), 0) AS actual_items_total,

    -- Financial damage assessment
    CASE
        WHEN o.order_total < 0 THEN
        CONCAT('CRITICAL: REFUNDED $', ABS(o.order_total), ' without request')
        WHEN o.order_total = 0 THEN 'CRITICAL: FREE ORDER - $0 charged'
        ELSE 'OK'
    END AS financial_severity,

    -- Calcualte loss
    ABS(o.order_total) AS direct_revenue_loss,

    -- Root cause indicator
    CASE
        WHEN o.order_total != COALESCE(SUM(oi.line_total), 0) THEN
        'Bugs: Total calculation error'
        WHEN EXISTS (SELECT 1 FROM order_items oi2
                    WHERE oi2.order_id = o.order_id
                    AND oi2.quantity < 0) THEN
            'Bugs: Negative quantity in items'
        ELSE 'Bug: Unknown cause'
    END AS likely_root_cause

FROM orders o
JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_total <= 0
GROUP BY o.order_id, u.full_name, o.order_total, o.order_date, o.order_status
ORDER BY o.order_total ASC;

-- ============================================
-- CRITICAL BUGS FOUND:
-- ============================================
-- Order 4: Total = -$299.99
--   → Customer "refunded" $299.99 automatically
--   → They didn't request a refund
--   → Revenue loss: $299.99
--   → Status: "completed" (should be refunded?)
--
-- Order 8: Total = $0.00
--   → Customer got items for FREE
--   → Items total: $29.99 (1x Mouse)
--   → Revenue loss: $29.99
--   → Pricing bug or promo code error?
--
-- TOTAL REVENUE LOSS: $329.98 from just 2 orders
--
-- QA ACTION:
-- 1. URGENT: Add constraint CHECK (order_total > 0)
-- 2. Block checkout if calculated total <= 0
-- 3. Alert finance team about these orders
-- 4. Investigate: Are customers aware? Refund them properly
-- 5. Fix calculation bug in checkout system
-- ============================================