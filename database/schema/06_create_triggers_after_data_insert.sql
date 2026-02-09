-- =====================================================
-- Triggers for orders table
-- =====================================================

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

-- Ensure only one default address per user by unsetting other defaults
CREATE TRIGGER after_address_update
AFTER UPDATE ON addresses
FOR EACH ROW
BEGIN
    -- If this address is being set as default, unset all other defaults for this user
    IF NEW.is_default = TRUE AND OLD.is_default = FALSE THEN
        UPDATE addresses
        SET is_default = FALSE
        WHERE user_id = NEW.user_id
        AND address_id != NEW.address_id
        AND is_default = TRUE;
    END IF;
END//

-- Ensure only one default address per user on insert
CREATE TRIGGER after_address_insert
AFTER INSERT ON addresses
FOR EACH ROW
BEGIN
    -- If this new address is default, unset all other defaults for this user
    IF NEW.is_default = TRUE THEN
        UPDATE addresses
        SET is_default = FALSE
        WHERE user_id = NEW.user_id
        AND address_id != NEW.address_id
        AND is_default = TRUE;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- Triggers for order_items table
-- =====================================================

DELIMITER //

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

DELIMITER ;
