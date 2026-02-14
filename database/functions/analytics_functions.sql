-- ---------------------------------------------------
-- Function: fn_vendor_commission
-- Calculates the commission amount owed to a vendor within a specified date range.
-- Parameters:
--   vendor_id   : INT    - The vendor's unique ID
--   start_date  : DATE   - The start of the date range (inclusive)
--   end_date    : DATE   - The end of the date range (inclusive)
-- Returns:
--   DECIMAL(10,2) representing the total commission earned by the vendor
--
-- Logic:
--   - Finds all delivered orders containing products sold by the specified vendor.
--   - Includes only orders within the given date range.
--   - Commission is summed over all eligible order items as:
--     item_total_price * vendor's commission rate.
-- ---------------------------------------------------

DELIMITER //

CREATE FUNCTION fn_vendor_commission(
    vendor_id INT,
    start_date DATE,
    end_date DATE
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_commission DECIMAL(10, 2) DEFAULT 10.00;
    DECLARE p_vendor_id INT;

    SELECT vendor_id
      INTO p_vendor_id
      FROM vendors
     WHERE vendor_id = vendor_id;

    IF p_vendor_id IS NULL THEN
        RETURN 0.00;
    END IF;

    -- Sum commission for all items from this vendor in delivered orders within the period
    SELECT SUM(oi.total_price * v.commission_rate / 100)
      INTO total_commission
      FROM orders o
      JOIN order_items oi      ON o.order_id = oi.order_id
      JOIN product_variants pv ON oi.variant_id = pv.variant_id
      JOIN products p          ON pv.product_id = p.product_id
      JOIN vendors v           ON p.vendor_id = v.vendor_id
     WHERE v.vendor_id = vendor_id
       AND o.o_status = 'delivered'
       AND o.order_date BETWEEN start_date AND end_date;

    RETURN IFNULL(total_commission, 0.00);
END //

DELIMITER ;

-- Commission calculation function call example:
-- Returns the total commission amount owed for vendor_id=1 for 2025.
SELECT fn_vendor_commission(1, '2025-01-01', '2025-12-31') AS commission_2025_vendor1;
