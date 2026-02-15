-- -------------------------------------------------
-- Business Intelligence Views for Portfolio Project
-- -------------------------------------------------
--
-- vw_product_catalog:
--   Combines product, vendor, category, and variant details. Includes stock status.
-- vw_customer_orders:
--   Captures customer order/payment history, including basic user info and payment state.
-- vw_vendor_dashboard:
--   Vendor metrics: product counts, sales and commission (only completed transactions).
-- vw_sales_summary:
--   Windowed monthly & yearly sales aggs for trend analysis.
-- vw_month_to_month_sales:
--   Month-over-month sales with lag to calculate change/delta and percent.

-- Product Catalog with Stock Status
 CREATE OR REPLACE VIEW vw_product_catalog AS
    SELECT
        p.product_id AS 'Product ID',
        p.p_name AS 'Product',
        c.category_name AS 'Category',
        v.company_name AS 'Vendor',
        pv.variant_id AS 'Variant ID',
        pv.attributes AS 'Variant Attributes',
        pv.stock_quantity AS 'Available Stock',
        -- Stock status indicator
        CASE
            WHEN pv.stock_quantity < 5 THEN 'LOW STOCK'
            WHEN pv.stock_quantity = 0 THEN 'OUT OF STOCK'
            ELSE 'IN STOCK'
        END AS STATUS
    FROM
        products p
            JOIN
        vendors v ON p.vendor_id = v.vendor_id
            JOIN
        categories c ON p.category_id = c.category_id
            JOIN
        product_variants pv ON p.product_id = pv.product_id
    ORDER BY p.p_name ASC;

-- Customer Order History + Payment Status
CREATE OR REPLACE VIEW vw_customer_orders AS
    SELECT
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        o.order_id,
        o.order_date,
        p.transaction_id,
        CONCAT('$', p.amount) AS total,
        p.pay_status
    FROM
        users u
            JOIN
        orders o ON u.user_id = o.user_id
            JOIN
        payments p ON o.order_id = p.order_id
    WHERE
        u.customer_type = 'customer';

-- Vendor Dashboard Metrics (only completed sales)
CREATE OR REPLACE VIEW vw_vendor_dashboard AS
    SELECT
        v.vendor_id AS 'Vendor ID',
        v.company_name AS 'Vendor Name',
        COUNT(DISTINCT p.product_id) AS 'Number of Products',
        CONCAT(v.commission_rate, '%') AS 'Commission Rate',
        CONCAT('$', SUM(oi.total_price)) AS 'Total Sales',
        CONCAT('$',
                ROUND(SUM(oi.total_price * v.commission_rate / 100),
                        2)) AS 'Commission Earned'
    FROM
        vendors v
            JOIN
        products p ON v.vendor_id = p.vendor_id
            JOIN
        product_variants pv ON p.product_id = pv.product_id
            JOIN
        order_items oi ON pv.variant_id = oi.variant_id
            JOIN
        orders o ON oi.order_id = o.order_id
            JOIN
        payments py ON o.order_id = py.order_id
    WHERE
        py.pay_status = 'completed'
    GROUP BY v.vendor_id , v.company_name;

-- Sales Summary with Windowed Monthly/Yearly Totals
CREATE OR REPLACE VIEW vw_sales_summary AS
	SELECT
		YEAR(o.order_date) AS 'Year',
		MONTH(o.order_date) AS 'Month',
		SUM(o.total_amount) OVER (
		PARTITION BY YEAR(o.order_date), MONTH(o.order_date)
		ORDER BY o.order_date
		) AS 'Monthly Total',
		SUM(o.total_amount) OVER (
		PARTITION BY YEAR(o.order_date)
		ORDER BY o.order_date
		) AS 'Yearly Total'
    FROM orders o
	JOIN payments p ON o.order_id = p.order_id
	WHERE p.pay_status = 'completed'
	ORDER BY o.order_date ASC;

-- Month-over-Month Sales Trend/Change
CREATE OR REPLACE VIEW vw_month_to_month_sales AS
WITH monthly_sales AS (
    SELECT
        YEAR(o.order_date)  AS yr,
        MONTH(o.order_date) AS mo,
        SUM(o.total_amount) AS monthly_total
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE p.pay_status = 'completed'
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
),
with_lag AS (
    SELECT
        yr,
        mo,
        monthly_total,
        LAG(monthly_total) OVER (ORDER BY yr, mo) AS prev_month_total
    FROM monthly_sales
)
SELECT
    yr                                                        AS 'Year',
    mo                                                        AS 'Month',
    monthly_total                                             AS 'Monthly Total',
    prev_month_total                                          AS 'Previous Month Total',
    monthly_total - prev_month_total                          AS 'Change in Sales',
    ROUND(
        (monthly_total - prev_month_total) / prev_month_total * 100
    , 2)                                                      AS 'Change (%)'
FROM with_lag
ORDER BY yr, mo;
