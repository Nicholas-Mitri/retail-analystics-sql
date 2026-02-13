-- =========================================================
-- Inventory Procedures
-- =========================================================

-- Drops
DROP PROCEDURE IF EXISTS sp_update_stock;
DROP PROCEDURE IF EXISTS sp_check_availability;
DROP PROCEDURE IF EXISTS sp_low_stock_alert;

DELIMITER //

-- =========================================================
-- sp_update_stock
-- Updates the stock quantity for a given product variant.
-- Inputs:
--   p_variant_id INT - the product variant to update
--   p_quantity   INT - the new stock quantity (must be > 0)
-- Throws error if p_quantity is not positive.
-- =========================================================
CREATE PROCEDURE sp_update_stock (
    IN p_variant_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE variant_exists INT;

    SELECT COUNT(*) INTO variant_exists
    FROM product_variants
    WHERE variant_id = p_variant_id;

    IF variant_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Variant does not exist';
    END IF;

    IF p_quantity > 0 THEN
        UPDATE product_variants
        SET stock_quantity = p_quantity
        WHERE variant_id = p_variant_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid stock quantity';
    END IF;
END //

-- =========================================================
-- sp_check_availability
-- Returns stock quantity and status for a specific variant,
-- including product name.
-- Input:
--   p_variant_id INT - the variant to check
-- Output: variant_id, stock_quantity, p_name, stock_status
-- =========================================================
CREATE PROCEDURE sp_check_availability(
    IN p_variant_id INT
)
BEGIN
    DECLARE variant_exists INT;

    SELECT COUNT(*) INTO variant_exists
    FROM product_variants
    WHERE variant_id = p_variant_id;

    IF variant_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Variant does not exist';
    END IF;

    SELECT
        pv.variant_id,
        pv.stock_quantity,
        p.p_name,
        CASE
            WHEN pv.stock_quantity > 0 THEN 'In Stock'
            WHEN pv.stock_quantity = 0 THEN 'Out of Stock'
        END AS stock_status
    FROM product_variants pv
    JOIN products p ON pv.product_id = p.product_id
    WHERE pv.variant_id = p_variant_id;
END //

-- =========================================================
-- sp_low_stock_alert
-- Returns all product variants with stock_quantity < 5,
-- including product name and variant attributes.
-- No input parameters.
-- Output: variant_id, product, variant attributes, stock_quantity
-- =========================================================
CREATE PROCEDURE sp_low_stock_alert()
BEGIN
    SELECT
        pv.variant_id,
        p.p_name AS 'product',
        pv.attributes as 'variant attributes',
        pv.stock_quantity
    FROM product_variants pv
    JOIN products p ON pv.product_id = p.product_id
    WHERE pv.stock_quantity < 5;
END //
DELIMITER ;

-- =========================================================
-- Simple procedure tests for inventory procedures
-- =========================================================
-- Set a test variant_id for demonstration
SET @test_variant_id = 21;

-- Test: Check availability for the test variant
CALL sp_check_availability(@test_variant_id);

-- Test: Update stock to a value; should succeed if input > 0
CALL sp_update_stock(@test_variant_id, 4);

-- Test: low stock alert (should include variants below threshold)
CALL sp_low_stock_alert();
