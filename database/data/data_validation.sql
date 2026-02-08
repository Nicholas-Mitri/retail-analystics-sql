-- =====================================================
-- DATA VALIDATION TESTS OUTLINE
-- Retail Analytics Database
-- Run these queries after insert_sample_data.sql to validate data integrity
-- =====================================================

-- -----------------------------------------------------
-- 1. REFERENTIAL INTEGRITY
-- -----------------------------------------------------
-- 1.1 Orphaned vendors: vendors with user_id not in users
-- 1.2 Orphaned addresses: addresses with user_id not in users
-- 1.3 Orphaned products: products with vendor_id or category_id not found
-- 1.4 Orphaned product_variants: variants with product_id not in products
-- 1.5 Orphaned orders: orders with user_id not in users or address_id not in addresses
-- 1.6 Orphaned order_items: order_items with order_id or variant_id not found
-- 1.7 Orphaned payments: payments with order_id not in orders

-- -----------------------------------------------------
-- 2. UNIQUENESS CONSTRAINTS
-- -----------------------------------------------------
-- 2.1 Duplicate emails in users
-- 2.2 Duplicate user_id in vendors (one vendor per user)
-- 2.3 Duplicate slugs in categories
-- 2.4 Duplicate (category_name, parent_category_id) in categories
-- 2.5 Duplicate SKUs in product_variants
-- 2.6 Duplicate order_id in payments (one payment per order)

-- -----------------------------------------------------
-- 3. CATEGORY HIERARCHY
-- -----------------------------------------------------
-- 3.1 Self-referencing categories: parent_category_id = category_id
-- 3.2 Orphaned parent references: parent_category_id not in category_id
-- 3.3 Deep hierarchy: categories with depth > 3 (sample data expects max 3 levels)
-- 3.4 Circular references (requires recursive CTE to detect cycles)

-- -----------------------------------------------------
-- 4. NUMERIC RANGES & BUSINESS RULES
-- -----------------------------------------------------
-- 4.1 vendor commission_rate outside 0-100%
-- 4.2 product_variants with price < 0
-- 4.3 product_variants with stock_quantity < 0
-- 4.4 order_items with quantity <= 0
-- 4.5 order_items with unit_price <= 0
-- 4.6 payments with amount <= 0
-- 4.7 orders with subtotal < 0, tax_amount < 0, or shipping_cost < 0

-- -----------------------------------------------------
-- 5. COMPUTED COLUMN CONSISTENCY
-- -----------------------------------------------------
-- 5.1 orders: total_amount != subtotal + tax_amount + shipping_cost
-- 5.2 order_items: total_price != unit_price * quantity
-- 5.3 orders: subtotal vs sum of order_items.total_price for same order_id

-- -----------------------------------------------------
-- 6. ORDER-PAYMENT RELATIONSHIPS
-- -----------------------------------------------------
-- 6.1 payments.amount != orders.total_amount for same order
-- 6.2 Orders with status 'delivered' but no payment with pay_status 'completed'
-- 6.3 Orders with pay_status 'completed' but order still 'pending' or 'cancelled'

-- -----------------------------------------------------
-- 7. SAMPLE DATA EXPECTED COUNTS (Sanity Checks)
-- -----------------------------------------------------
-- 7.1 users: expect 20 (14 customers + 5 vendors + 1 admin)
-- 7.2 vendors: expect 5
-- 7.3 categories: expect 16 (3 main + subcategories)
-- 7.4 products: expect 30
-- 7.5 product_variants: expect 56 (or count per product)
-- 7.6 addresses: expect specific count per user

-- -----------------------------------------------------
-- 8. ENUM & NULL VALIDATION
-- -----------------------------------------------------
-- 8.1 users.customer_type: only 'customer', 'vendor', 'admin'
-- 8.2 vendors.v_status: only 'active', 'deactivated', 'pending', 'suspended'
-- 8.3 products.p_status: only 'active', 'inactive', 'discontinued'
-- 8.4 product_variants.pv_status: only 'active', 'inactive', 'discontinued'
-- 8.5 addresses.type: only 'shipping', 'billing'
-- 8.6 orders.o_status: only valid enum values
-- 8.7 payments.payment_method, pay_status: valid enum values
-- 8.8 Required fields: users.email, users.first_name, users.last_name non-empty
-- 8.9 vendors with v_status 'active' should have approved_at NOT NULL

-- -----------------------------------------------------
-- 9. ADDRESS VALIDATION
-- -----------------------------------------------------
-- 9.1 Users with no addresses (if customers must have at least one shipping)
-- 9.2 Multiple is_default = TRUE per user_id (should be at most one per user)
-- 9.3 postal_code format (basic format check for Canadian postal codes if applicable)
-- 9.4 Empty or whitespace-only street_address, city, state, country

-- -----------------------------------------------------
-- 10. JSON ATTRIBUTES (product_variants.attributes)
-- -----------------------------------------------------
-- 10.1 Invalid JSON syntax in attributes column
-- 10.2 Expected structure/keys if schema is defined (optional)

-- -----------------------------------------------------
-- 11. TIMESTAMP LOGIC
-- -----------------------------------------------------
-- 11.1 orders: delivered_date before shipped_date
-- 11.2 orders: shipped_date before order_date
-- 11.3 payments: processed_at NULL when pay_status = 'completed' (inconsistent)
