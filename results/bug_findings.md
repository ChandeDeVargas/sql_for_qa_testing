# Bug Findings Report - E-Commerce Data Quality Assessment

> **Assessment Date:** February 2, 2026
> **Database:** sql_qa_testing
> **QA Engineer:** Chande Mauricio De Vargas Brazoban
> **Total Bugs Found:** 16

---

## Excutive Summary

A comprehensive data quality assessment was conducted on the e-commerce database. **16 critical data integrity issues** were identified across users, products, orders, and order items tables.

**Severity Breakdown:**

- **Critical (P0):** 10 Bugs - Revenue Impact, System Failures
- **High (P1):** 4 Bugs - UX issues, data inconsistencies
- **Medium (P2):** 2 Bugs - Edge cases, historical data

**Financial Impact:** Estimated **$3,800+ at risk** from pricing errors and invalid orders.

---

## Critical Bugs (P0) - Immediate Action Required

### Bug #1: Duplicate User Emails - Login System Broken

**Category:** Data Quality - Duplicates
**Table:** `users`
**Query:** `03_duplicates/find_duplicate_users.sql`

**Details:**

- 2 email addresses used by multiple accounts
- Total affected: 4 user accounts

| Email                | User IDs | Impact                |
| -------------------- | -------- | --------------------- |
| john.doe@email.com   | 1, 4     | Login conflicts       |
| jane.smith@email.com | 2, 10    | Password reset errors |

**Business Impact:**

- Users cannot login (system doesn't know which account)
- Password reset sends email to wrong account
- "Email already existes" errors on registration

**Root Cause:** Missing UNIQUE constraint on email column

**Recommended Fix:**

```sql
-- 1. Delete duplicate accounts (keep oldest)
DELETE FROM users WHERE user_id IN (4, 10);

-- 2. Add unique constraint
ALTER TABLE users ADD UNIQUE KEY unique_email (email);
```

**Priority:** **CRITICAL** - Fix immediately

---

### Bug #2: Products with $0 Price - Free items

**Category:** Data Quality - Pricing
**Table:** `products`
**Query:** `02_data_quality/find_zero_prices.sql`

**Details:**

- 2 products with price = $0.00

| Product ID | Name              | Price | Stock | Risk           |
| ---------- | ----------------- | ----- | ----- | -------------- |
| 4          | Free Keyboard     | $0.00 | 100   | $3,000 at risk |
| 10         | Out of Stock Item | $0.00 | 0     | Low (no stock) |

**Business Impact:**

- Customers can order items for FREE
- Revenue loss: ~$3,000 (100 keyboras x $30 avg)
- Pricing credibility damaged

**Root Cause:** Data entry error or pricing system bug

**Recommended Fix:**

```sql
-- Set correct prices
UPDATE products SET price = 29.99 WHERE product_id = 4;
UPDATE products SET price = 19.99 WHERE product_id = 10;

-- Add constraint
ALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);
```

**Priority:** **CRITICAL** - Fix before next sale

---

### Bug #3: Produt with NEGATIVE Price

**Category:** Data Quality - Pricing
**Table:** `products`
**Query:** `02_data_quality/find_zero_prices.sql`

**Details:**

- Product ID 6: "Broken Headphones" = **-$50.00**

**Business Impact:**

- System would PAY customer $50 to buy this product
- Potential loss: $500 (10 units × $50)
- Critical billing bug

**Root Cause:** Database allows negative values (no constraint)

**Recommended Fix:**

```sql
-- Fix price
UPDATE products SET price = 50.00 WHERE product_id = 6;


**Priority:** **CRITICAL** - Delete or fix immediately

---
```

---

### Bug #4: Product with Negative Stock

**Category:** Data Quality - Inventor
**Table:** `products`
**Query:** `02_data_quality/find_zero_prices.sql`

**Details:**

- Product ID 7: "Webcam HD" = **-5 units** in stock

**Business Impact:**

- Inventory reports are wrong
- Can't fulfill orders (no stock)
- Overselling risk if not caught

**Root Cause:** Stock not update after orders OR returns bugs

**Recommended Fix:**

```sql
-- Reset to 0 or correct value
UPDATE products SET stock_quantity = 0 WHERE product_id = 7;

-- Add constraint
ALTER TABLE products ADD CONSTRAINT chk_stock CHECK (stock_quantity >= 0);
```

**Priority:** 🔥 **CRITICAL** - Investigate inventory system

---

### Bug #5: Order with Negative Total

**Category:** Data Quality - Financial  
**Table:** `orders`  
**Query:** `02_data_quality/find_negative_totals.sql`

**Details:**

- Order ID 4: Total = **-$299.99**

**Business Impact:**

- Customer "refunded" $299.99 without request
- Revenue loss: $299.99
- Accounting reconciliation fails

**Root Cause:** Order total calculation bug

**Recommended Fix:**

```sql
-- Investigate if items total matches
SELECT order_id, order_total,
       (SELECT SUM(line_total) FROM order_items WHERE order_id = 4) AS actual_total
FROM orders WHERE order_id = 4;

-- Fix total
UPDATE orders SET order_total = 299.99 WHERE order_id = 4;

-- Add constraint
ALTER TABLE orders ADD CONSTRAINT chk_total CHECK (order_total > 0);
```

**Priority:** 🔥 **CRITICAL** - Contact customer, fix billing

---

### Bug #6: Order with $0 Total

**Category:** Data Quality - Financial  
**Table:** `orders`  
**Query:** `02_data_quality/find_zero_prices.sql`

**Details:**

- Order ID 8: Total = **$0.00** (status: pending)

**Business Impact:**

- Free order processed
- Revenue loss: Check order_items for actual value
- Billing system broken

**Root Cause:** Checkout didn't calculate total OR promo code bug

**Recommended Fix:**

```sql
-- Check what items are in this order
SELECT SUM(line_total) FROM order_items WHERE order_id = 8;

-- Update to correct total
UPDATE orders SET order_total = (
    SELECT SUM(line_total) FROM order_items WHERE order_id = 8
) WHERE order_id = 8;
```

**Priority:** 🔥 **CRITICAL** - Fix checkout calculation

---

### Bug #7: Order with Future Date

**Category:** Data Quality - Dates  
**Table:** `orders`  
**Query:** `02_data_quality/find_invalid_dates.sql`

**Details:**

- Order ID 7: Date = **2027-12-25** (3+ years in future)

**Business Impact:**

- "Recent orders" reports show future orders
- Analytics broken (sales in 2027?)
- Inventory forecasting wrong

**Root Cause:** Date validation missing OR test data not cleaned

**Recommended Fix:**

```sql
-- Fix date to current date
UPDATE orders SET order_date = NOW() WHERE order_id = 7;

-- Add constraint
ALTER TABLE orders ADD CONSTRAINT chk_date CHECK (order_date <= NOW());
```

**Priority:** 🔥 **CRITICAL** - Fix reports immediately

---

### Bug #8: User Created in Future

**Category:** Data Quality - Dates  
**Table:** `users`  
**Query:** `02_data_quality/find_invalid_dates.sql`

**Details:**

- User ID 8: created_at = **2027-12-31** (future date)

**Business Impact:**

- "New users" reports include impossible data
- Marketing metrics skewed
- Analytics dashboards broken

**Root Cause:** Date validation missing

**Recommended Fix:**

```sql
-- Fix creation date
UPDATE users SET created_at = NOW() WHERE user_id = 8;

-- Add constraint
ALTER TABLE users ADD CONSTRAINT chk_created CHECK (created_at <= NOW());
```

**Priority:** 🔥 **CRITICAL** - Fix analytics

---

### Bug #9: User with Empty Name

**Category:** Data Quality - Required Fields  
**Table:** `users`  
**Query:** `01_basic_validation/list_users.sql`

**Details:**

- User ID 5: full_name = **''** (empty string)

**Business Impact:**

- Email templates: "Hello, !" (broken personalization)
- Support tickets show no name
- User can't be searched by name

**Root Cause:** Frontend validation missing

**Recommended Fix:**

```sql
-- Update with placeholder
UPDATE users SET full_name = '[Name Not Provided]' WHERE user_id = 5;

-- Add constraint (prevent future empty names)
ALTER TABLE users ADD CONSTRAINT chk_name CHECK (TRIM(full_name) != '');
```

**Priority:** 🔥 **CRITICAL** - Fix user experience

---

### Bug #10: Order Total Doesn't Match Items

**Category:** Data Integrity - Calculation  
**Tables:** `orders`, `order_items`  
**Query:** `04_data_integrity/validate_relationships.sql`

**Details:**

- Order ID 11: Stored total = $100.00, Actual items total = $159.90

**Business Impact:**

- Customer undercharged by $59.90 (revenue loss)
- OR overcharged (customer dispute)
- Accounting can't reconcile

**Root Cause:** Order total not recalculated after cart changes

**Recommended Fix:**

```sql
-- Check actual total
SELECT order_id, order_total,
       (SELECT SUM(line_total) FROM order_items WHERE order_id = 11) AS calculated
FROM orders WHERE order_id = 11;

-- Fix total
UPDATE orders SET order_total = 159.90 WHERE order_id = 11;

-- Add trigger to auto-calculate totals
```

**Priority:** 🔥 **CRITICAL** - Fix checkout logic

---

## ⚠️ High Priority Bugs (P1) - Fix This Sprint

### Bug #11: Order Without Items (Orphaned)

**Category:** Data Integrity - Relationships  
**Table:** `orders`  
**Query:** `04_data_integrity/find_orphaned_orders.sql`

**Details:**

- Order ID 13: Has total ($500.00) but **zero items**

**Business Impact:**

- Can't fulfill order (nothing to ship)
- Customer charged but gets nothing
- Order stuck in system

**Root Cause:** Order created before items added OR items deletion bug

**Recommended Fix:**

```sql
-- Cancel the order
UPDATE orders SET order_status = 'cancelled' WHERE order_id = 13;

-- Add check: Orders must have items before completing
```

**Priority:** ⚠️ **HIGH** - Investigate order flow

---

### Bug #12: Order Item References Non-Existent Product

**Category:** Data Integrity - Broken References  
**Table:** `order_items`  
**Query:** `04_data_integrity/find_broken_references.sql`

**Details:**

- Item ID 13: References product_id **999** (doesn't exist)

**Business Impact:**

- Order history shows "[Product Not Found]"
- Returns/exchanges broken
- Customer support escalations

**Root Cause:** Product deleted after order placed

**Recommended Fix:**

```sql
-- Create placeholder product
INSERT INTO products (product_id, product_name, price, stock_quantity)
VALUES (999, '[Deleted Product]', 50.00, 0);

-- Add foreign key constraint
ALTER TABLE order_items
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id) REFERENCES products(product_id)
ON DELETE RESTRICT;
```

**Priority:** ⚠️ **HIGH** - Fix customer experience

---

### Bug #13: Order Item with Negative Quantity

**Category:** Data Quality - Inventory  
**Table:** `order_items`  
**Query:** `01_basic_validation/order_results.sql`

**Details:**

- Item ID 14: Quantity = **-2**

**Business Impact:**

- Inventory calculation wrong
- Negative line total
- Billing error

**Root Cause:** Returns processing bug OR calculation error

**Recommended Fix:**

```sql
-- Fix quantity
UPDATE order_items SET quantity = 2 WHERE item_id = 14;

-- Add constraint
ALTER TABLE order_items ADD CONSTRAINT chk_qty CHECK (quantity > 0);
```

**Priority:** ⚠️ **HIGH** - Fix inventory system

---

### Bug #14: Order Item with Zero Quantity

**Category:** Data Quality - Inventory  
**Table:** `order_items`  
**Query:** `01_basic_validation/order_results.sql`

**Details:**

- Item ID 15: Quantity = **0**

**Business Impact:**

- Empty line item in order
- Cart calculation wrong
- Customer confusion

**Root Cause:** Cart not validated before checkout

**Recommended Fix:**

```sql
-- Delete empty line item
DELETE FROM order_items WHERE item_id = 15;

-- Add constraint (already in Bug #13)
```

**Priority:** ⚠️ **HIGH** - Fix cart validation

---

## ℹ️ Medium Priority Bugs (P2) - Monitor & Fix When Possible

### Bug #15: Users with No Orders (Onboarding Issue?)

**Category:** Edge Case - Business Intelligence  
**Table:** `users`  
**Query:** `02_joins.sql` (users with no orders)

**Details:**

- 2 users never placed an order (IDs: 11, 12)

**Business Impact:**

- Onboarding problem? UX issue?
- Marketing opportunity (re-engage)
- Low immediate risk

**Root Cause:** Normal behavior OR sign-up friction

**Recommended Action:**

- Monitor signup-to-purchase conversion rate
- A/B test onboarding flow
- Send re-engagement emails

**Priority:** ℹ️ **MEDIUM** - Analytics/Marketing task

---

### Bug #16: Products Never Ordered (Dead Inventory)

**Category:** Edge Case - Business Intelligence  
**Table:** `products`  
**Query:** `02_joins.sql` (products never ordered)

**Details:**

- 2 products never ordered (IDs: 11, 12)

**Business Impact:**

- Inventory taking up space
- Pricing too high? Poor marketing?
- Low immediate risk

**Root Cause:** Product launched but not promoted OR overpriced

**Recommended Action:**

- Run promotion/discount
- Improve product page SEO
- Consider discontinuing if no sales in 90 days

**Priority:** ℹ️ **MEDIUM** - Inventory management

---

## 📈 Summary Statistics

| Category          | Count  | Percentage |
| ----------------- | ------ | ---------- |
| **Critical (P0)** | 10     | 62.5%      |
| **High (P1)**     | 4      | 25%        |
| **Medium (P2)**   | 2      | 12.5%      |
| **Total Bugs**    | **16** | **100%**   |

### Bugs by Table:

| Table         | Bugs Found |
| ------------- | ---------- |
| `users`       | 3          |
| `products`    | 5          |
| `orders`      | 5          |
| `order_items` | 3          |

### Bugs by Type:

| Type                 | Count |
| -------------------- | ----- |
| Pricing errors       | 3     |
| Invalid dates        | 2     |
| Negative values      | 3     |
| Duplicates           | 2     |
| Broken relationships | 2     |
| Missing data         | 2     |
| Calculation errors   | 2     |

---

## 💰 Financial Impact Assessment

| Issue                  | Estimated Loss/Risk |
| ---------------------- | ------------------- |
| $0 price products      | $3,000              |
| Negative price product | $500                |
| Negative total order   | $300                |
| $0 total order         | $30 (estimated)     |
| Total mismatch order   | $60 (undercharge)   |
| **TOTAL AT RISK**      | **~$3,890**         |

**Note:** This is from a TEST database. In production, multiply by actual transaction volume.

---

## 🎯 Recommended Actions

### Immediate (This Week):

1. ✅ Fix all P0 bugs (10 critical issues)
2. ✅ Add database constraints (UNIQUE, CHECK)
3. ✅ Contact affected customers (negative totals, $0 orders)
4. ✅ Fix pricing on products 4, 6, 10

### Short-term (This Sprint):

5. ✅ Fix P1 bugs (4 high priority)
6. ✅ Add foreign key constraints
7. ✅ Implement frontend validation
8. ✅ Add backend validation (double-check)

### Long-term (Next Quarter):

9. ✅ Implement automated data quality checks (run these queries daily)
10. ✅ Add monitoring/alerts for data anomalies
11. ✅ Review and improve checkout flow
12. ✅ Train team on data integrity best practices

---

## 🛡️ Prevention Strategy

### Database Level:

```sql
-- Add constraints to prevent future bugs
ALTER TABLE users ADD UNIQUE KEY (email);
ALTER TABLE users ADD CONSTRAINT chk_name CHECK (TRIM(full_name) != '');
ALTER TABLE users ADD CONSTRAINT chk_user_date CHECK (created_at <= NOW());

ALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);
ALTER TABLE products ADD CONSTRAINT chk_stock CHECK (stock_quantity >= 0);

ALTER TABLE orders ADD CONSTRAINT chk_total CHECK (order_total > 0);
ALTER TABLE orders ADD CONSTRAINT chk_order_date CHECK (order_date <= NOW());

ALTER TABLE order_items ADD CONSTRAINT chk_quantity CHECK (quantity > 0);
ALTER TABLE order_items ADD CONSTRAINT fk_product
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT;
```

### Application Level:

- ✅ Frontend validation (disable future dates, require fields)
- ✅ Backend validation (double-check all inputs)
- ✅ Checkout validation (verify total = sum of items)
- ✅ Inventory checks (can't order if stock <= 0)

### Monitoring:

- ✅ Run data quality queries daily
- ✅ Alert if anomalies detected
- ✅ Dashboard showing data health score
- ✅ Weekly data quality report

---

## ✅ Conclusion

This assessment identified **16 data quality issues**, with **10 critical bugs requiring immediate attention**. The estimated financial risk is **$3,800+** from pricing errors and invalid orders.

**Key Takeaway:** Data validation at the database level (constraints) would have prevented 90% of these bugs.

**Next Steps:**

1. Fix all P0 bugs immediately
2. Implement database constraints
3. Add application-level validation
4. Set up automated monitoring

---

**Report Prepared By:** Chande Mauricio De Vargas Brazoban - QA Engineer
**Date:** February 2026  
**Status:** ✅ Complete  
**Follow-up:** Schedule in 1 week to verify fixes
