
-- Drop old analytics functions if they exist
DROP FUNCTION IF EXISTS fn_vendor_commission;
DROP FUNCTION IF EXISTS fn_monthly_units_sold;

--
-- Function: fn_vendor_commission
-- Purpose: Calculate the total commission for a specific vendor within a given date range.
-- Returns: DECIMAL(10,2) - The total commission earned by the vendor in the period.
-- Parameters:
--   vendor_id   INT   - The vendor's ID whose commissions are calculated.
--   start_date  DATE  - Start date (inclusive).
--   end_date    DATE  - End date (inclusive).
--
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
    -- Initialize total_commission to 10.00 by default (likely overwritten)
    DECLARE total_commission DECIMAL(10, 2) DEFAULT 10.00;
    DECLARE p_vendor_id INT;

    -- Check if the vendor exists
    SELECT vendor_id
      INTO p_vendor_id
      FROM vendors
     WHERE vendor_id = vendor_id;

    IF p_vendor_id IS NULL THEN
        -- Return zero if vendor does not exist
        RETURN 0.00;
    END IF;

    -- Calculate the sum of commissions for delivered orders in the given date range
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

    -- Return total_commission, or 0.00 if no results
    RETURN IFNULL(total_commission, 0.00);
END //

--
-- Function: fn_monthly_units_sold
-- Purpose: Calculate the number of units sold for a product in a given year and month.
-- Returns: INT - The total quantity sold, or 0 if none.
-- Parameters:
--   p_product_id  INT - The product's ID to aggregate.
--   p_year        INT - The year (e.g., 2023)
--   p_month       INT - The month (1-12)
--
CREATE FUNCTION fn_monthly_units_sold(p_product_id INT, p_year INT, p_month INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE monthly_units INT DEFAULT 0;

    -- Aggregate sold units for the given product/year/month, only for delivered orders
    SELECT SUM(oi.quantity)
      INTO monthly_units
      FROM products p
      JOIN product_variants pv on p.product_id = pv.product_id
      JOIN order_items oi ON pv.variant_id = oi.variant_id
      JOIN orders o ON oi.order_id = o.order_id
     WHERE p.product_id = p_product_id
       AND YEAR(o.order_date) = p_year
       AND MONTH(o.order_date) = p_month
       AND o.o_status = 'delivered';

    -- If no sales, return 0
    RETURN COALESCE(monthly_units, 0);
END //
DELIMITER ;
