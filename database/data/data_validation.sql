-- =====================================================
-- DATA VALIDATION GUIDE
-- =====================================================
-- This file contains queries to validate data integrity, constraint
-- compliance, and business rule adherence in the retail_analytics database.
--
-- Portfolio Project Note: These validation queries demonstrate understanding
-- of data quality principles suitable for a production-ready system without
-- being overly complex. In a real production environment, these would be
-- automated as part of a data quality monitoring pipeline.
-- =====================================================


-- =====================================================
-- 1. CONSTRAINT INTEGRITY CHECKS
-- =====================================================
-- Validate that data adheres to defined constraints

-- 1.1 Check for negative prices (should be prevented by CHECK constraint)
-- Expected result: 0 rows
-- TODO: Query product_variants joined with products to find any prices < 0


-- 1.2 Check for negative stock quantities (should be prevented by CHECK constraint)
-- Expected result: 0 rows
-- TODO: Query product_variants joined with products to find stock_quantity < 0


-- 1.3 Check for invalid email formats (should be prevented by CHECK constraint)
-- Expected result: 0 rows
-- TODO: Query users table to find emails that don't match the regex pattern


-- 1.4 Check for invalid phone formats (should be prevented by CHECK constraint)
-- Expected result: 0 rows
-- TODO: Query users table to find phones that don't match the expected format


-- 1.5 Check for short passwords (should be prevented by CHECK constraint)
-- Expected result: 0 rows
-- TODO: Query users table to find passwords with CHAR_LENGTH < 8


-- 1.6 Check commission rates are within valid range (0-100%)
-- Expected result: 0 rows
-- TODO: Query vendors table to find commission_rate outside 0-100 range


-- =====================================================
-- 2. FOREIGN KEY RELATIONSHIP VALIDATION
-- =====================================================
-- Verify referential integrity across related tables

-- 2.1 Check for orphaned products (products without valid vendor)
-- Expected result: 0 rows
-- TODO: LEFT JOIN products with vendors to find products with NULL vendor


-- 2.2 Check for orphaned product variants (variants without valid product)
-- Expected result: 0 rows
-- TODO: LEFT JOIN product_variants with products to find variants with NULL product


-- 2.3 Check for orphaned order items (items without valid order)
-- Expected result: 0 rows
-- TODO: LEFT JOIN order_items with orders to find items with NULL order


-- 2.4 Check for vendors without corresponding user accounts
-- Expected result: 0 rows
-- TODO: LEFT JOIN vendors with users to find vendors with NULL user


-- =====================================================
-- 3. BUSINESS RULE VALIDATIONS
-- =====================================================
-- Validate data adheres to business logic

-- 3.1 Check order date sequence: shipped_date >= order_date
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query orders where shipped_date is NOT NULL but shipped_date < order_date


-- 3.2 Check order date sequence: delivered_date >= shipped_date
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query orders where delivered_date is NOT NULL but shipped_date is NULL or delivered_date < shipped_date


-- 3.3 Check cancelled orders have no ship/delivery dates
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query orders with status 'cancelled' but shipped_date or delivered_date is NOT NULL


-- 3.4 Check delivered orders have both shipped and delivered dates
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query orders with status 'delivered' but missing shipped_date or delivered_date


-- 3.5 Check active vendors have approval timestamps
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query vendors with status 'active' but approved_at IS NULL


-- 3.6 Validate all vendor users have 'vendor' customer_type
-- Expected result: 0 rows
-- TODO: JOIN vendors with users to find vendors where customer_type != 'vendor'


-- =====================================================
-- 4. DATA QUALITY CHECKS
-- =====================================================
-- Identify potential data quality issues

-- 4.1 Check for duplicate email addresses (should be prevented by UNIQUE constraint)
-- Expected result: 0 rows
-- TODO: Use GROUP BY email with HAVING COUNT(*) > 1 to find duplicates


-- 4.2 Check for duplicate SKUs (should be prevented by UNIQUE constraint)
-- Expected result: 0 rows
-- TODO: Use GROUP BY sku with HAVING COUNT(*) > 1 to find duplicates


-- 4.3 Check for duplicate product names per vendor (should be prevented by UNIQUE constraint)
-- Expected result: 0 rows
-- TODO: Use GROUP BY vendor_id, p_name with HAVING COUNT(*) > 1


-- 4.4 Check for products with very short names (less than 3 characters)
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query products where CHAR_LENGTH(p_name) < 3


-- 4.5 Check for invalid slug formats (lowercase and hyphens only)
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query categories where slug doesn't match regex pattern '^[a-z0-9-]+$'


-- 4.6 Check for products with no available variants
-- Portfolio note: This is a data quality check, not a constraint violation
-- Some products may legitimately have no variants yet
-- TODO: LEFT JOIN products with product_variants, GROUP BY product, HAVING COUNT(variants) = 0


-- =====================================================
-- 5. PAYMENT AND ORDER VALIDATION
-- =====================================================
-- Validate payment amounts and order consistency

-- 5.1 Check for payments with zero or negative amounts
-- Expected result: 0 rows (constraint should prevent this)
-- TODO: Query payments where amount <= 0


-- 5.2 Verify payment amounts match calculated order totals
-- Expected result: 0 rows (or small rounding differences < 0.01)
-- Note: This checks if the payment amount equals (subtotal + shipping) * (1 + tax/100)
-- TODO: JOIN payments with orders, compare amount with total_amount using ABS(difference)


-- 5.3 Check for completed payments with NULL processed_at timestamp
-- Portfolio note: Business rule validation
-- TODO: Query payments where pay_status = 'completed' AND processed_at IS NULL


-- 5.4 Check for orders without payments
-- Portfolio note: Valid for processing/pending orders, investigate for delivered orders
-- TODO: LEFT JOIN orders with payments to find orders with NULL payment_id


-- 5.5 Check for failed payments with processed_at timestamp
-- Expected result: 0 rows (failed payments shouldn't be processed)
-- TODO: Query payments where pay_status = 'failed' AND processed_at IS NOT NULL


-- =====================================================
-- 6. CALCULATED FIELD ACCURACY
-- =====================================================
-- Verify computed/stored generated columns

-- 6.1 Verify order_items total_price = unit_price * quantity
-- Expected result: 0 rows
-- TODO: Query order_items where ABS(total_price - (unit_price * quantity)) > 0.01


-- 6.2 Verify orders total_amount calculation
-- Formula: (subtotal + shipping_cost) * (1 + tax_perc/100)
-- Expected result: 0 rows (or tiny rounding differences)
-- TODO: Query orders comparing total_amount with calculated value


-- 6.3 Verify order subtotal matches sum of order items
-- Portfolio note: This checks if triggers are maintaining subtotals correctly
-- TODO: JOIN orders with SUM of order_items total_price, compare with order subtotal


-- =====================================================
-- 7. STATUS CONSISTENCY CHECKS
-- =====================================================
-- Validate status fields are logically consistent

-- 7.1 Check for inactive/discontinued products with active variants
-- Portfolio note: Business logic - inactive products should have inactive variants
-- TODO: JOIN products with product_variants where product is inactive/discontinued but variant is active


-- 7.2 Check for pending payments on delivered orders
-- Portfolio note: Delivered orders should have completed payments
-- TODO: JOIN orders with payments where order status is 'delivered' but payment is 'pending'


-- 7.3 Check for shipped/delivered orders with failed payments
-- Portfolio note: Orders shouldn't be shipped if payment failed
-- TODO: JOIN orders with payments where order is shipped/delivered but payment is 'failed'


-- =====================================================
-- 8. CATEGORY HIERARCHY VALIDATION
-- =====================================================
-- Validate category tree structure

-- 8.1 Check for circular category references (category is its own parent)
-- Expected result: 0 rows
-- TODO: Query categories where category_id = parent_category_id


-- 8.2 Check for deep category nesting (more than 3 levels)
-- Portfolio note: This demonstrates recursive query understanding
-- The database has max 3 levels, so this should return 0 rows
-- TODO: Use recursive CTE to calculate depth level, find any categories with depth > 3


-- 8.3 Check for duplicate category names within same parent
-- Expected result: 0 rows (UNIQUE constraint should prevent this)
-- TODO: GROUP BY parent_category_id, category_name with HAVING COUNT(*) > 1


-- =====================================================
-- 9. ADDRESS VALIDATION
-- =====================================================
-- Validate address data consistency

-- 9.1 Check for users with multiple default shipping addresses
-- Portfolio note: Each user should have at most one default shipping address
-- TODO: Query addresses where type='shipping' AND is_default=TRUE, GROUP BY user_id, HAVING COUNT(*) > 1


-- 9.2 Check for orders using addresses that don't belong to the ordering user
-- Expected result: 0 rows
-- TODO: JOIN orders with addresses where order.user_id != address.user_id


-- 9.3 Check for users without any addresses
-- Portfolio note: May be valid for admin users or newly registered accounts
-- TODO: LEFT JOIN users with addresses, GROUP BY user, HAVING COUNT(addresses) = 0


-- =====================================================
-- 10. TIMESTAMP CONSISTENCY CHECKS
-- =====================================================
-- Validate timestamp fields are logically ordered

-- 10.1 Check for records where updated_at is before created_at
-- Expected result: 0 rows
-- TODO: Use UNION ALL to query users, products, categories, product_variants where updated_at < created_at


-- 10.2 Check for payments created after order was placed
-- Portfolio note: Small delays are normal, but large gaps indicate issues
-- TODO: JOIN payments with orders, check where payment.created_at < order.order_date or DATEDIFF > 7 days


-- =====================================================
-- 11. INVENTORY AND STOCK VALIDATION
-- =====================================================
-- Check for potential inventory issues

-- 11.1 Identify low stock items (less than 10 units)
-- Portfolio note: Not a validation error, but useful for business monitoring
-- TODO: JOIN product_variants with products and vendors where stock_quantity < 10 AND status is active


-- 11.2 Check for out-of-stock items with active status
-- Portfolio note: Active items with 0 stock may need status update
-- TODO: JOIN product_variants with products where stock_quantity = 0 AND pv_status = 'active'


-- =====================================================
-- VALIDATION SUMMARY REPORT
-- =====================================================
-- Portfolio note: This provides a quick overview of all validations
-- In production, this would be automated and logged
-- TODO: Create a summary query showing validation completion status and timestamp
