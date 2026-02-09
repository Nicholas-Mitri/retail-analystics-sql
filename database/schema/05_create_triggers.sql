-- =====================================================
-- Drop existing triggers if they exist
-- =====================================================

-- Drop triggers for categories table
DROP TRIGGER IF EXISTS prevent_category_delete;

-- Drop triggers for addresses table
DROP TRIGGER IF EXISTS prevent_address_delete;
DROP TRIGGER IF EXISTS before_address_update;
DROP TRIGGER IF EXISTS before_address_insert;

-- Drop triggers for order_items table
DROP TRIGGER IF EXISTS before_order_item_insert;
DROP TRIGGER IF EXISTS before_order_item_update;
DROP TRIGGER IF EXISTS before_order_item_delete;
DROP TRIGGER IF EXISTS after_order_item_insert;
DROP TRIGGER IF EXISTS after_order_item_update;
DROP TRIGGER IF EXISTS after_order_item_delete;

-- Drop triggers for orders table
DROP TRIGGER IF EXISTS before_order_insert;
DROP TRIGGER IF EXISTS before_order_update;
DROP TRIGGER IF EXISTS before_order_delete;
DROP TRIGGER IF EXISTS after_order_update;

-- Drop triggers for payments table
DROP TRIGGER IF EXISTS before_payment_insert;
DROP TRIGGER IF EXISTS before_payment_update;
DROP TRIGGER IF EXISTS before_payment_delete;

-- Drop triggers for products table
DROP TRIGGER IF EXISTS before_product_delete;
DROP TRIGGER IF EXISTS after_product_update;

-- Drop triggers for variants table
DROP TRIGGER IF EXISTS before_variant_delete;

-- Drop triggers for vendors table
DROP TRIGGER IF EXISTS before_vendor_update;
DROP TRIGGER IF EXISTS before_vendor_delete;

-- =======================================================================
-- Database Triggers
-- =======================================================================
-- This file contains triggers that maintain data integrity
-- and automatically update calculated fields across tables.

-- =====================================================
-- Triggers for categories table
-- =====================================================

-- Prevent hard deletion of categories to maintain referential integrity
DELIMITER //
CREATE TRIGGER prevent_category_delete
BEFORE DELETE ON categories
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Categories cannot be deleted. Use UPDATE categories SET is_active = FALSE instead.';
END//
DELIMITER ;

-- =====================================================
-- Triggers for addresses table
-- =====================================================

DELIMITER //

-- Prevent hard deletion of addresses to maintain order history
CREATE TRIGGER prevent_address_delete
BEFORE DELETE ON addresses
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Addresses cannot be deleted.';
END//

-- Ensure only one default address per user by unsetting other defaults
CREATE TRIGGER before_address_update
BEFORE UPDATE ON addresses
FOR EACH ROW
BEGIN
    -- If this address is being set as default, unset all other defaults for this user
    IF NEW.is_default = TRUE AND OLD.is_default = FALSE THEN
        UPDATE addresses
        SET is_default = FALSE
        WHERE user_id = NEW.user_id AND is_default = TRUE;
    END IF;
END//

-- Ensure only one default address per user on insert
CREATE TRIGGER before_address_insert
BEFORE INSERT ON addresses
FOR EACH ROW
BEGIN
    -- If this new address is default, unset all other defaults for this user
    IF NEW.is_default = TRUE THEN
        UPDATE addresses
        SET is_default = FALSE
        WHERE user_id = NEW.user_id AND is_default = TRUE;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- Triggers for order_items table
-- =====================================================

DELIMITER //

-- /* ACTIVATE AFTER INSERT
-- Validate order item before insertion
CREATE TRIGGER before_order_item_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status_val VARCHAR(20);
    DECLARE variant_quantity INT;
    DECLARE product_status VARCHAR(20);

    -- Check if the product variant is active
    SELECT pv_status INTO product_status
    FROM product_variants
    WHERE variant_id = NEW.variant_id;

    IF product_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot add inactive/discontinued product variants to orders';
    END IF;

    -- Check if there's enough inventory (with row lock to prevent race conditions)
    SELECT stock_quantity INTO variant_quantity
    FROM product_variants
    WHERE variant_id = NEW.variant_id
    FOR UPDATE;

    IF variant_quantity < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough inventory for this variant';
    END IF;

    -- Check if the order is in a state that allows adding items
    SELECT o_status INTO order_status_val
    FROM orders
    WHERE order_id = NEW.order_id;

    IF order_status_val NOT IN ('pending') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot add items to orders that are not pending';
    END IF;
END//
-- */

-- Update order totals and inventory after item insertion
CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    -- Recalculate order subtotal
    UPDATE orders
    SET subtotal = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;

    -- Decrease variant stock quantity
    UPDATE product_variants
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE variant_id = NEW.variant_id;
END//

-- Validate order item updates
CREATE TRIGGER before_order_item_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status_val VARCHAR(20);
    DECLARE pv_unit_price DECIMAL(10, 2);
    DECLARE pv_stock_quantity INT;
    DECLARE product_status VARCHAR(20);

    -- Get current variant price
    SELECT price INTO pv_unit_price
    FROM product_variants
    WHERE variant_id = NEW.variant_id;

    -- Get current variant status
    SELECT pv_status INTO product_status
    FROM product_variants
    WHERE variant_id = NEW.variant_id;

    -- Get current variant stock
    SELECT stock_quantity INTO pv_stock_quantity
    FROM product_variants
    WHERE variant_id = NEW.variant_id;

    -- Get order status
    SELECT o_status INTO order_status_val
    FROM orders
    WHERE order_id = NEW.order_id;

    -- Only allow modifications to pending orders
    IF order_status_val NOT IN ('pending') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify items in orders that are not pending';
    END IF;

    -- Prevent changing the order_id
    IF NEW.order_id <> OLD.order_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify the order of id of the item';
    END IF;

    -- Prevent changing the variant_id
    IF NEW.variant_id <> OLD.variant_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify the variant id of the item';
    END IF;

    -- If unit price is being changed, ensure it matches current variant price
    IF NEW.unit_price <> OLD.unit_price THEN
        IF NEW.unit_price <> pv_unit_price THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order item price does not match variant price';
        END IF;
    END IF;

    -- If quantity is being changed, ensure there's enough inventory
    IF NEW.quantity <> OLD.quantity THEN
        -- Account for the old quantity being returned to stock
        IF NEW.quantity > pv_stock_quantity + OLD.quantity THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough inventory for this variant';
        END IF;
    END IF;
END//

-- Update order totals and inventory after item update
CREATE TRIGGER after_order_item_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    -- Adjust variant stock based on quantity change
    IF NEW.quantity <> OLD.quantity THEN
        UPDATE product_variants
        SET stock_quantity = stock_quantity + OLD.quantity - NEW.quantity
        WHERE variant_id = NEW.variant_id;
    END IF;

    -- Recalculate order subtotal
    UPDATE orders
    SET subtotal = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END//

-- Validate order item deletion
CREATE TRIGGER before_order_item_delete
BEFORE DELETE ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status_val VARCHAR(20);

    -- Get order status
    SELECT o_status INTO order_status_val
    FROM orders
    WHERE order_id = OLD.order_id;

    -- Only allow deletion from pending orders
    IF order_status_val NOT IN ('pending') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete items from orders that are not pending';
    END IF;
END//

-- Update order totals and restore inventory after item deletion
CREATE TRIGGER after_order_item_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    DECLARE pv_stock_quantity INT;

    -- Get current stock quantity
    SELECT stock_quantity INTO pv_stock_quantity
    FROM product_variants
    WHERE variant_id = OLD.variant_id;

    -- Restore variant stock
    UPDATE product_variants
    SET stock_quantity = pv_stock_quantity + OLD.quantity
    WHERE variant_id = OLD.variant_id;

    -- Recalculate order subtotal
    UPDATE orders
    SET subtotal = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END//

DELIMITER ;

-- =====================================================
-- Triggers for orders table
-- =====================================================

-- /* ACTIVATE AFTER DATA INSERTED
DELIMITER //

-- Validate and manage order updates
CREATE TRIGGER before_order_update
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Prevent modification of finalized orders
    IF OLD.o_status IN ('shipped', 'delivered', 'cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order status can no longer be modified';
    END IF;

    -- Prevent changing the user who placed the order
    IF NEW.user_id <> OLD.user_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User ID cannot be modified';
    END IF;

    -- Prevent direct modification of subtotal (calculated from order_items)
    IF NEW.subtotal <> OLD.subtotal THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subtotal cannot be modified directly. Update order items instead.';
    END IF;

    -- Prevent status regression after shipping
    IF NEW.shipped_date IS NOT NULL AND NEW.o_status IN ('pending', 'processing') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot move order back to pending/processing after shipping';
    END IF;

    -- Prevent status regression after delivery
    IF NEW.delivered_date IS NOT NULL AND NEW.o_status IN ('pending', 'processing', 'shipped') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot move order back from delivered status';
    END IF;

    -- Prevent manual modification of shipped_date
    IF NOT (NEW.shipped_date <=> OLD.shipped_date) THEN
       SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipped date cannot be modified directly.';
    END IF;

    -- Prevent manual modification of delivered_date
    IF NOT (NEW.delivered_date <=> OLD.delivered_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivered date cannot be modified directly.';
    END IF;

    -- Automatically set shipped_date and delivered_date when status changes
    IF NEW.o_status <> OLD.o_status THEN
        IF NEW.o_status = 'shipped' THEN
            SET NEW.shipped_date = NOW();
        ELSEIF NEW.o_status = 'delivered' THEN
            SET NEW.delivered_date = NOW();
        END IF;
    END IF;

    -- Restore inventory if order is cancelled
    IF OLD.o_status != 'cancelled' AND NEW.o_status = 'cancelled' THEN
        UPDATE product_variants
        JOIN order_items ON product_variants.variant_id = order_items.variant_id
        SET stock_quantity = stock_quantity + order_items.quantity
        WHERE order_items.order_id = NEW.order_id;
    END IF;
END//

DELIMITER ;

DELIMITER //

-- Validate new order insertion
CREATE TRIGGER before_order_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Prevent orders from being created with non-zero subtotal (calculated from items)
    IF NEW.subtotal > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subtotal cannot be manually entered. Insert order items instead.';
    END IF;

    -- Prevent orders from being created with shipping date already set
    IF NEW.shipped_date IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipping date cannot be entered manually.';
    END IF;

    -- Prevent orders from being created with delivery date already set
    IF NEW.delivered_date IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivered date cannot be entered manually.';
    END IF;
END //

DELIMITER ;
-- */

DELIMITER //

-- Prevent hard deletion of orders to maintain transaction history
CREATE TRIGGER before_order_delete
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Orders cannot be deleted. Use UPDATE orders SET o_status = "cancelled" instead.';
END//

DELIMITER ;

-- =====================================================
-- Triggers for payments table
-- =====================================================

DELIMITER //

-- Validate payment insertion
CREATE TRIGGER before_payment_insert
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(10, 2);

    -- Get the order total
    SELECT total_amount INTO order_total
    FROM orders
    WHERE order_id = NEW.order_id;

    -- Ensure payment amount matches order total
    IF NEW.amount <> order_total THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must match the order total';
    END IF;
END//

DELIMITER ;

DELIMITER //

-- Validate and manage payment updates
CREATE TRIGGER before_payment_update
BEFORE UPDATE ON payments
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(10, 2);

    -- Prevent modification of finalized payments
    IF OLD.pay_status IN ('completed', 'failed') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify completed or failed payments';
    END IF;

    -- For pending payments, enforce field restrictions
    IF OLD.pay_status = 'pending' THEN
        -- Prevent changing the order_id
        IF NEW.order_id <> OLD.order_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order ID cannot be modified';
        END IF;

        -- Prevent changing the payment method
        IF NEW.payment_method <> OLD.payment_method THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment method cannot be modified. Create a new order instead.';
        END IF;

        -- Prevent changing the transaction ID
        IF NOT (NEW.transaction_id <=> OLD.transaction_id) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction ID cannot be modified';
        END IF;

        -- If amount is being changed, validate it matches order total
        IF NEW.amount <> OLD.amount THEN
            -- Get the order total
            SELECT total_amount INTO order_total
            FROM orders
            WHERE order_id = NEW.order_id;

            -- Ensure new amount matches order total
            IF NEW.amount <> order_total THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Payment amount must match the order total';
            END IF;
        END IF;
    END IF;

    -- Automatically set processed_at timestamp when payment is completed
    IF NEW.pay_status = 'completed' AND OLD.pay_status <> 'completed' THEN
        SET NEW.processed_at = NOW();
    END IF;
END//

DELIMITER ;

DELIMITER //

-- Prevent hard deletion of payments to maintain transaction history
CREATE TRIGGER before_payment_delete
BEFORE DELETE ON payments
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payments cannot be deleted';
END//

DELIMITER ;

-- =====================================================
-- Triggers for products table
-- =====================================================

DELIMITER //

-- Prevent hard deletion of products to maintain referential integrity
CREATE TRIGGER before_product_delete
BEFORE DELETE ON products
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Products cannot be deleted. Use UPDATE products SET p_status = "inactive" instead.';
END//

-- Cascade discontinuation to variants and child products
CREATE TRIGGER after_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- When a product is discontinued, discontinue all its variants and child products
    IF OLD.p_status != 'discontinued' AND NEW.p_status = 'discontinued' THEN
        -- Discontinue all variants of this product
        UPDATE product_variants
        SET pv_status = 'discontinued'
        WHERE product_id = NEW.product_id;

        -- Discontinue all child products (recursive - will trigger this trigger again)
        UPDATE products
        SET p_status = 'discontinued'
        WHERE parent_product_id = NEW.product_id;
    END IF;

    -- Prevent reactivation of discontinued products
    IF OLD.p_status = 'discontinued' AND NEW.p_status != 'discontinued' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot reactivate a discontinued product. Create a new product instead.';
    END IF;
END //

DELIMITER ;

-- =====================================================
-- Triggers for product variants table
-- =====================================================

DELIMITER //

-- Prevent hard deletion of variants to maintain referential integrity
CREATE TRIGGER before_variant_delete
BEFORE DELETE ON product_variants
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product variants cannot be deleted. Use UPDATE product_variants SET pv_status = "inactive" instead.';
END//

DELIMITER ;

-- =====================================================
-- Triggers for product vendors table
-- =====================================================

DELIMITER //

-- Manage vendor status changes and approval timestamps
CREATE TRIGGER before_vendor_update
BEFORE UPDATE ON vendors
FOR EACH ROW
BEGIN
    -- Clear approval timestamp when vendor becomes inactive or suspended
    IF (NEW.v_status = 'inactive' OR NEW.v_status = 'suspended') AND OLD.v_status = 'active' THEN
        UPDATE vendors
        SET approved_at = NULL
        WHERE user_id = NEW.user_id;
    END IF;

    -- Set approval timestamp when vendor is activated from pending
    IF NEW.v_status = 'active' AND OLD.v_status = 'pending' THEN
        UPDATE vendors
        SET approved_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
END//

-- Prevent hard deletion of vendors to maintain referential integrity
CREATE TRIGGER before_vendor_delete
BEFORE DELETE ON vendors
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Vendors cannot be deleted. Use UPDATE vendors SET v_status = "inactive" instead.';
END//

DELIMITER ;
