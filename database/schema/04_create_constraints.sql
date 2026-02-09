-- =====================================================
-- Database Constraints
-- =====================================================
-- This file contains additional constraints beyond those defined
-- in the table creation file. Many constraints (CHECK, UNIQUE, NOT NULL,
-- FOREIGN KEY) are already defined inline with table definitions.
--
-- Portfolio Project Note: This demonstrates understanding of data
-- integrity rules appropriate for a retail analytics system. A
-- production system would include additional constraints, more
-- sophisticated validation, and possibly application-level checks.
-- =====================================================


-- =====================================================
-- CHECK Constraints
-- =====================================================
-- These constraints ensure data values meet business rules
-- Note: Some CHECK constraints are already defined in table definitions
-- (e.g., price >= 0, stock_quantity >= 0, quantity > 0)

-- Users Table Constraints
-- -----------------------
-- Add email format validation
ALTER TABLE users ADD CONSTRAINT chk_email_format
    CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Add phone format validation (if standardized format required)
ALTER TABLE users ADD CONSTRAINT chk_phone_format
    CHECK (phone REGEXP '^[0-9]{10}$' OR phone IS NULL);

-- Add password length validation (minimum 8 characters)
ALTER TABLE users ADD CONSTRAINT chk_password_length
    CHECK (CHAR_LENGTH(user_password) >= 8);


-- Vendors Table Constraints
-- --------------------------
-- Add commission rate range validation (0-100%)
ALTER TABLE vendors ADD CONSTRAINT chk_commission_rate
    CHECK (commission_rate >= 0 AND commission_rate <= 100);

-- Add business rule: approved vendors must have approved_at timestamp
ALTER TABLE vendors ADD CONSTRAINT chk_approved_vendor_timestamp
    CHECK (
        (v_status = 'active' AND approved_at IS NOT NULL) OR
        (v_status != 'active')
    );


-- Categories Table Constraints
-- -----------------------------
-- Prevent self-referencing categories
ALTER TABLE categories ADD CONSTRAINT chk_no_self_reference
    CHECK (category_id != parent_category_id);

-- Add slug format validation (lowercase, hyphens only)
ALTER TABLE categories ADD CONSTRAINT chk_slug_format
    CHECK (slug REGEXP '^[a-z0-9-]+$');


-- Products Table Constraints
-- ---------------------------
-- Add product name length validation
ALTER TABLE products ADD CONSTRAINT chk_product_name_length
    CHECK (CHAR_LENGTH(p_name) >= 3);


-- Orders Table Constraints
-- -------------------------
-- Add subtotal validation (must be non-negative)
ALTER TABLE orders ADD CONSTRAINT chk_subtotal_nonnegative
    CHECK (subtotal >= 0);

-- Add tax percentage validation (reasonable range)
ALTER TABLE orders ADD CONSTRAINT chk_tax_percentage_range
    CHECK (tax_perc >= 0 AND tax_perc <= 50);

-- Add shipping cost validation (must be non-negative)
ALTER TABLE orders ADD CONSTRAINT chk_shipping_cost_nonnegative
    CHECK (shipping_cost >= 0);

-- Add date logic validation (shipped_date must be after order_date)
ALTER TABLE orders ADD CONSTRAINT chk_shipped_after_order
    CHECK (
        (shipped_date IS NULL) OR
        (shipped_date IS NOT NULL AND order_date IS NOT NULL AND shipped_date >= order_date)
    );
-- Add date logic validation (delivered_date must be after shipped_date)
ALTER TABLE orders ADD CONSTRAINT chk_delivered_after_shipped
    CHECK (
        (delivered_date IS NULL) OR
        (delivered_date IS NOT NULL AND shipped_date IS NOT NULL AND delivered_date >= shipped_date)
    );

-- Add business rule: cancelled orders should not have shipped/delivered dates
ALTER TABLE orders ADD CONSTRAINT chk_cancelled_no_ship_dates
    CHECK (
        (o_status = 'cancelled' AND shipped_date IS NULL AND delivered_date IS NULL) OR
        (o_status != 'cancelled')
    );

-- Add business rule: delivered orders must have both shipped and delivered dates
ALTER TABLE orders ADD CONSTRAINT chk_delivered_has_dates
    CHECK (
        (o_status = 'delivered' AND shipped_date IS NOT NULL AND delivered_date IS NOT NULL) OR
        (o_status != 'delivered')
    );

-- Order Items Table Constraints
-- ------------------------------

-- Add unit price validation (must be non-negative)
ALTER TABLE order_items ADD CONSTRAINT chk_unit_price_nonnegative
    CHECK (unit_price >= 0);

-- Payments Table Constraints
-- ---------------------------
-- TODO: Add payment amount validation (must be positive)
ALTER TABLE payments ADD CONSTRAINT chk_payment_amount_positive
    CHECK (amount > 0);


-- =====================================================
-- UNIQUE Constraints
-- =====================================================

-- Products Table
-- --------------
-- Add unique constraint for product name per vendor (prevent duplicates)
ALTER TABLE products ADD CONSTRAINT uq_product_name_per_vendor
    UNIQUE (vendor_id, p_name);
