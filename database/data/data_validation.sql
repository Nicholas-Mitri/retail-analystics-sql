-- =====================================================
-- DATA VALIDATION GUIDE
-- =====================================================
-- This file contains queries to validate data integrity, constraint compliance, and business rule adherence in the retail_analytics database.
-- =====================================================

-- =====================================================
-- 1. CONSTRAINT INTEGRITY CHECKS
-- =====================================================
-- Validate that data adheres to defined constraints

CREATE OR REPLACE VIEW integrity_checks AS

-- Check 1: No negative prices in product_variants
SELECT
    'NO NEGATIVE PRICE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM product_variants
WHERE price < 0

UNION ALL

-- Check 2: No negative stock in product_variants
SELECT
    'NO NEGATIVE STOCK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM product_variants
WHERE stock_quantity < 0

UNION ALL

-- Check 3: No invalid emails in users
SELECT
    'NO INVALID EMAIL',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM users
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{3,}$'

UNION ALL

-- Check 4: No invalid phone numbers in users
SELECT
    'NO INVALID PHONE',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM users
WHERE phone NOT REGEXP '^[0-9]{3}-[0-9]{4}$'
    AND phone IS NOT NULL

UNION ALL

-- Check 5: No short passwords in users
SELECT
    'NO SHORT PASSWORD',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM users
WHERE CHAR_LENGTH(user_password) < 8

UNION ALL

-- Check 6: No invalid commission rate values for vendors
SELECT
    'NO INVALID COMMISION',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM vendors
WHERE commission_rate NOT BETWEEN 0 AND 100;


-- =====================================================
-- 2. BUSINESS RULE VALIDATIONS
-- =====================================================
-- Validate data adheres to business logic
CREATE OR REPLACE VIEW business_rule_checks AS

-- 2.1 Check order date sequence: shipped_date >= order_date
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'SHIPPED AFTER ORDER DATE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
WHERE shipped_date IS NOT NULL AND order_date IS NOT NULL AND shipped_date < order_date

UNION ALL

-- 2.2 Check order date sequence: delivered_date >= shipped_date
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'DELIVERED AFTER SHIPPING DATE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
WHERE shipped_date IS NOT NULL AND delivered_date IS NOT NULL AND delivered_date < shipped_date

UNION ALL

-- 2.3 Check cancelled orders have no ship/delivery dates
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'NO SHIP/DELIVERY DATES ON CANCELLED ORDERS' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
WHERE o_status = 'cancelled' AND shipped_date IS NOT NULL AND delivered_date IS NOT NULL

UNION ALL

-- 2.4 Check delivered orders have both shipped and delivered dates
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'DELIVERED ORDERS FULLY DATED' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
WHERE o_status = 'delivered' AND (shipped_date IS NULL AND delivered_date IS NULL);

-- 2.5 Check active vendors have approval timestamps
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'APPROVAL TIMESTAMPS ON ACTIVE VENDORS' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM vendors
WHERE v_status='active' AND approved_at IS NULL

UNION ALL

-- 2.6 Validate all vendor users have 'vendor' customer_type
-- Expected result: 0 rows
SELECT
    'VENDORS APPROPRIATELY ASSIGNED' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM vendors
JOIN users ON users.user_id = vendors.user_id
WHERE users.customer_type != 'vendor';

-- =====================================================
-- 4. DATA QUALITY CHECKS
-- =====================================================
-- Identify potential data quality issues
CREATE OR REPLACE VIEW data_quality_checks AS

-- 4.1 Check for duplicate SKUs (should be prevented by UNIQUE constraint)
-- Expected result: 0 rows
SELECT
    'NO DUPLICATE SKUS' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM (
    SELECT sku
    FROM product_variants
    GROUP BY sku
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

-- 4.2 Check for products with very short names (less than 3 characters)
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'NO SHORT PRODUCT NAMES' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM products
WHERE CHAR_LENGTH(p_name) < 3

UNION ALL

-- 4.3 Check for invalid slug formats (lowercase and hyphens only)
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'VALID SLUG FORMATS' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM categories
WHERE slug NOT REGEXP '^[a-z0-9-]+$';

-- 4.6 Check for products with no available variants
-- This is a data quality check, not a constraint violation
-- Some products may legitimately have no variants yet
-- SET @num_of_variants = 0;

-- SELECT p.product_id, p_name, COUNT(sku)
-- FROM products p
-- LEFT JOIN product_variants pv ON p.product_id = pv.product_id
-- GROUP BY p.product_id, p_name
-- HAVING COUNT(sku) = @num_of_variants;

-- =====================================================
-- 5. PAYMENT AND ORDER VALIDATION
-- =====================================================
-- Validate payment amounts and order consistency
CREATE OR REPLACE VIEW payment_checks AS

-- 5.1 Check for payments with zero or negative amounts
-- Expected result: 0 rows (constraint should prevent this)
SELECT
    'NO NEGATIVE PRICE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM payments
WHERE amount <= 0

UNION ALL

-- 5.2 Verify payment amounts match calculated order totals
SELECT
    'NO NEGATIVE PRICE' AS 'CHECK',
    CASE COUNT(*)
        WHEN SUM(p_join_o.payment_order_match) THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM (
    SELECT ABS(p.amount - o.total_amount) < 0.01 AS payment_order_match
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
) AS p_join_o

UNION ALL

-- 5.3 Check for completed payments with NULL processed_at timestamp
-- Portfolio note: Business rule validation
SELECT
    'NO NEGATIVE PRICE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM payments
WHERE pay_status = 'completed' AND processed_at IS NULL

UNION ALL

-- 5.4 Check for orders without payments
-- Portfolio note: Valid for processing/pending orders, investigate for delivered orders
-- TODO: LEFT JOIN orders with payments to find orders with NULL payment_id
SELECT
    'NO NEGATIVE PRICE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
LEFT JOIN payments ON orders.order_id = payments.order_id
WHERE payments.payment_id IS NULL

UNION ALL

-- 5.5 Check for failed payments with processed_at timestamp
-- Expected result: 0 rows (failed payments shouldn't be processed)
-- TODO: Query payments where pay_status = 'failed' AND processed_at IS NOT NULL
SELECT
    'NO NEGATIVE PRICE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM payments
WHERE pay_status = 'failed' AND processed_at IS NOT NULL;

-- =====================================================
-- 6. CALCULATED FIELD ACCURACY
-- =====================================================
-- Verify computed/stored generated columns
CREATE OR REPLACE VIEW calculated_field_checks_v AS

-- 6.1 Verify order_items total_price = unit_price * quantity
SELECT
    'ORDER ITEM TOTAL CALCULATION' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM order_items
WHERE ABS(total_price - (unit_price * quantity)) > 0.01

UNION ALL

-- 6.2 Verify orders total_amount calculation
-- Formula: (subtotal + shipping_cost) * (1 + tax_perc/100)
SELECT
    'ORDER TOTAL CALCULATION' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
WHERE ABS(total_amount - ((subtotal + shipping_cost) * (1 + tax_perc/100))) > 0.01

UNION ALL

-- 6.3 Verify order subtotal matches sum of order items
-- Portfolio note: This checks if triggers are maintaining subtotals correctly
SELECT
    'ORDER SUBTOTAL MATCHES ORDER ITEMS' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM (
    SELECT orders.order_id
    FROM orders
    JOIN order_items ON orders.order_id = order_items.order_id
    GROUP BY orders.order_id
    HAVING ABS(SUM(order_items.total_price) - MAX(orders.subtotal)) > 0.01
) AS mismatches;

-- SELECT * FROM calculated_field_checks_v;

-- =====================================================
-- 7. STATUS CONSISTENCY CHECKS
-- =====================================================
-- Validate status fields are logically consistent
CREATE OR REPLACE VIEW status_consistency_checks_v AS

-- 7.1 Check for pending payments on delivered orders
-- Portfolio note: Delivered orders should have completed payments
SELECT 'ALL DELIVERED ORDERED PAID' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
JOIN payments ON orders.order_id = payments.order_id
WHERE orders.o_status = 'delivered' AND payments.pay_status != 'completed'

UNION ALL

-- 7.2 Check for shipped/delivered orders with failed payments
-- Portfolio note: Orders shouldn't be shipped if payment failed
-- TODO: JOIN orders with payments where order is shipped/delivered but payment is 'failed'
SELECT 'ALL DELIVERED ORDERED PAID',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM orders
JOIN payments ON orders.order_id = payments.order_id
WHERE orders.o_status IN ('delivered', 'shipped') AND payments.pay_status != 'completed';

-- SELECT * FROM status_consistency_checks_v;

-- =====================================================
-- 8. CATEGORY HIERARCHY VALIDATION
-- =====================================================
-- Validate category tree structure
SET @category_hierarchy_depth = 0;

-- 8.1 Check for deep category nesting (more than 3 levels)
-- Portfolio note: This demonstrates recursive query understanding
-- The database has max 3 levels, so this should return 0 rows
-- TODO: Use recursive CTE to calculate depth level, find any categories with depth > 3
WITH RECURSIVE category_hierarchy AS (
    -- Base case: Top-level managers (no supervisor)
    SELECT
        category_id,
        parent_category_id,
        1 AS level
    FROM categories
    WHERE parent_category_id IS NULL

    UNION ALL

    -- Recursive case: Employees with supervisors
    SELECT
        c.category_id,
        c.parent_category_id,
        ch.level + 1
    FROM categories c
    JOIN category_hierarchy ch ON c.parent_category_id = ch.category_id
    WHERE ch.level < 10  -- Prevent infinite recursion
)
SELECT MAX(level) INTO @category_hierarchy_depth FROM category_hierarchy;

SELECT
    '3-Tiered MAX CATEGORY HIERARCHY' AS 'CHECK',
    CASE @category_hierarchy_depth
        WHEN 3 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT';

CREATE OR REPLACE VIEW category_hierarchy_validation_v AS

-- 8.2 Check for circular category references (category is its own parent)
-- Expected result: 0 rows
SELECT 'CIRCULAR CATEGORY REFERENCE' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS RESULT
FROM categories
WHERE category_id = parent_category_id

UNION ALL

-- 8.3 Check for duplicate category names within same parent
-- Expected result: 0 rows (UNIQUE constraint should prevent this)
-- TODO: GROUP BY parent_category_id, category_name with HAVING COUNT(*) > 1
SELECT
    'DUPLICATE NAMES PER CATEGORY PARENT',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM (
    SELECT parent_category_id, category_name
    FROM categories
    GROUP BY parent_category_id, category_name
    HAVING COUNT(*) > 1
) AS duplicate_categories_per_parent;

-- SELECT * FROM category_hierarchy_validation_v;

-- =====================================================
-- 9. ADDRESS VALIDATION
-- =====================================================
-- Validate address data consistency
CREATE OR REPLACE VIEW address_validation_v AS

-- 9.1 Check for users with multiple default shipping addresses
-- Portfolio note: Each user should have at most one default shipping address
SELECT 'SINGLE DEFAULT SHIPPING ADDRESSES' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM (
    SELECT COUNT(*)
    FROM addresses
    WHERE type = 'shipping' AND is_default = TRUE
    GROUP BY user_id
    HAVING COUNT(*) > 1
) AS grouped_addresses

UNION ALL

-- 9.2 Check for orders using addresses that don't belong to the ordering user
-- Expected result: 0 rows
-- TODO: JOIN orders with addresses where order.user_id != address.user_id
SELECT 'ORDER ADDRESSES MATCH USER' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM orders
JOIN addresses ON orders.address_id = addresses.address_id
WHERE orders.user_id != addresses.user_id;

-- SELECT * FROM address_validation_v;

-- =====================================================
-- 10. TIMESTAMP CONSISTENCY CHECKS
-- =====================================================
-- Validate timestamp fields are logically ordered

-- 10.1 Check for records where updated_at is before created_at
-- Expected result: 0 rows
SELECT 'UPDATED AFTER CREATED' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM (
    SELECT u.created_at, u.updated_at FROM users u
    UNION ALL
    SELECT p.created_at, p.updated_at FROM products p
    UNION ALL
    SELECT c.created_at, c.updated_at FROM categories c
    UNION ALL
    SELECT pv.created_at, pv.updated_at FROM product_variants pv
) AS combined_dated_tables
WHERE updated_at < created_at;

-- =====================================================
-- VALIDATION SUMMARY REPORT
-- =====================================================
-- Portfolio note: This provides a quick overview of all validations
-- In production, this would be automated and logged
-- TODO: Create a summary query showing validation completion status and timestamp

SELECT 'INTEGRITY CHECKS' AS 'CHECK', '----------------------' AS 'RESULT'
UNION ALL
SELECT * FROM integrity_checks
UNION ALL
SELECT 'CALCULATED FIELD CHECKS' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT * FROM calculated_field_checks_v
UNION ALL
SELECT 'STATUS CONSISTENCY CHECKS' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT * FROM status_consistency_checks_v
UNION ALL
SELECT 'CATEGORY HIERARCHY VALIDATION' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT
    '3-TIERED MAX CATEGORY HIERARCHY' AS 'CHECK',
    CASE @category_hierarchy_depth
        WHEN 3 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
UNION ALL
SELECT * FROM category_hierarchy_validation_v
UNION ALL
SELECT 'ADDRESS VALIDATION' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT * FROM address_validation_v
UNION ALL
SELECT 'BUSINESS RULE CHECKS' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT * FROM business_rule_checks
UNION ALL
SELECT 'DATA QUALITY CHECKS' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT * FROM data_quality_checks
UNION ALL
SELECT 'PAYMENT CHECKS' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT * FROM payment_checks
UNION ALL
SELECT 'TIMESTAMP CONSISTENCY CHECKS' AS 'CHECK', '---------------------' AS 'RESULT'
UNION ALL
SELECT 'UPDATED AFTER CREATED' AS 'CHECK',
    CASE COUNT(*)
        WHEN 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS 'RESULT'
FROM (
    SELECT u.created_at, u.updated_at FROM users u
    UNION ALL
    SELECT p.created_at, p.updated_at FROM products p
    UNION ALL
    SELECT c.created_at, c.updated_at FROM categories c
    UNION ALL
    SELECT pv.created_at, pv.updated_at FROM product_variants pv
) AS combined_dated_tables
WHERE updated_at < created_at;
