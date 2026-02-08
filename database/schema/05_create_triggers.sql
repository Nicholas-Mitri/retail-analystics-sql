-- =====================================================
-- Drop existing triggers if they exist
-- =====================================================

-- Drop triggers for categories table
DROP TRIGGER IF EXISTS prevent_category_delete;

-- Drop triggers for addresses table
DROP TRIGGER IF EXISTS prevent_address_delete;

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

-- Drop triggers for variants table
DROP TRIGGER IF EXISTS before_variant_delete;


-- =====================================================
-- Database Triggers
-- =====================================================
-- This file contains triggers that maintain data integrity
-- and automatically update calculated fields across tables.

-- =====================================================
-- Triggers for categories table
-- =====================================================
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
CREATE TRIGGER prevent_address_delete
BEFORE DELETE ON addresses
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Addresses cannot be deleted.';
END//
DELIMITER ;


-- =====================================================
-- Triggers for order_items table
-- =====================================================
DELIMITER //
-- /* ACTIVATE AFTER INSERT
-- BEFORE INSERT trigger - check if order allows modifications
CREATE TRIGGER before_order_item_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status_val VARCHAR(20);

    SELECT o_status INTO order_status_val
    FROM orders
    WHERE order_id = NEW.order_id;

    IF order_status_val NOT IN ('pending') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot add items to orders that are not pending';
    END IF;
END//
-- */
-- AFTER INSERT trigger - update totals (only runs if BEFORE trigger passes)
CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET subtotal = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;

END//

-- BEFORE UPDATE trigger - prevent modifying shipped/completed orders
CREATE TRIGGER before_order_item_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status_val VARCHAR(20);

    SELECT o_status INTO order_status_val
    FROM orders
    WHERE order_id = NEW.order_id;

    IF order_status_val NOT IN ('pending') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify items in orders that are not pending';
    END IF;
END//

-- AFTER UPDATE trigger - recalculate totals
CREATE TRIGGER after_order_item_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET subtotal = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;


END//

-- BEFORE DELETE trigger - prevent deleting from shipped/completed orders
CREATE TRIGGER before_order_item_delete
BEFORE DELETE ON order_items
FOR EACH ROW
BEGIN
    DECLARE order_status_val VARCHAR(20);

    SELECT o_status INTO order_status_val
    FROM orders
    WHERE order_id = OLD.order_id;

    IF order_status_val NOT IN ('pending') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete items from orders that are not pending';
    END IF;
END//

-- AFTER DELETE trigger - recalculate totals
CREATE TRIGGER after_order_item_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
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
CREATE TRIGGER before_order_update
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Prevent modification of orders that are already shipped, delivered, or cancelled
    IF OLD.o_status IN ('shipped', 'delivered', 'cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order status can no longer be modified';
    END IF;

    -- Prevent changing the user who placed the order
    IF NEW.user_id <> OLD.user_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User ID cannot be modified';
    END IF;

    -- Prevent direct modification of subtotal (should be calculated from order_items)
    IF NEW.subtotal <> OLD.subtotal THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subtotal cannot be modified directly. Update order items instead.';
    END IF;

    -- Prevent status regression
    IF NEW.shipped_date IS NOT NULL AND NEW.o_status IN ('pending', 'processing') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot move order back to pending/processing after shipping';
    END IF;

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

END//

DELIMITER ;


DELIMITER //
CREATE TRIGGER before_order_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN

    -- Prevent orders from being added with non-zero subtotal
    IF NEW.subtotal > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subtotal cannot be manually entered. Insert order items instead.';
    END IF;

    -- Prevent orders from being added with non-null shipping date
    IF NEW.shipped_date IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipping date cannot be entered manually.';
    END IF;


    -- Prevent orders from being added with non-null delivered date
    IF NEW.delivered_date IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivered date cannot be entered manually.';
    END IF;

END //
DELIMITER ;
-- */

DELIMITER //
CREATE TRIGGER before_order_delete
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Orders cannot be deleted. Use UPDATE orders SET o_status = "cancelled" instead.';
END//
DELIMITER ;

/*
Update Todos

Uncomment and activate before_order_item_insert trigger

Create payment validation triggers (validate amount matches total, prevent modifications)

Create inventory management triggers (decrement stock on order placement)

Create inventory restoration triggers (restore stock on order cancellation)

Create stock validation trigger (prevent orders with insufficient inventory)

Create product/variant soft delete triggers (prevent hard deletes)

Create product-to-variant cascade trigger (discontinue variants when product discontinued)

Create vendor validation triggers (auto-set approved_at, validate commission_rate)

Create vendor deletion prevention trigger (block if vendor has products)

Create address default uniqueness trigger (ensure one default per user per type)
*/
