-- =======================================================================================
-- Product Analytics Queries
-- =======================================================================================

-- 1. Best performing products by revenue and units sold (delivered orders only)
SELECT
    p.product_id,
    p.p_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.total_price) AS total_revenue
FROM
    products p
    JOIN product_variants pv ON p.product_id = pv.product_id
    JOIN order_items oi ON pv.variant_id = oi.variant_id
    JOIN orders o ON oi.order_id = o.order_id
WHERE
    o.o_status = 'delivered'
GROUP BY p.product_id, p.p_name
ORDER BY total_revenue DESC;

-- 2. Product performance by category with revenue ranking
SELECT
    c.category_id,
    c.category_name,
    p.product_id,
    p.p_name,
    SUM(oi.total_price) AS total_revenue,
    RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(oi.total_price) DESC) AS `Rank`
FROM
    products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN product_variants pv ON p.product_id = pv.product_id
    JOIN order_items oi ON pv.variant_id = oi.variant_id
    JOIN orders o ON oi.order_id = o.order_id
WHERE
    o.o_status = 'delivered'
GROUP BY p.product_id, p.p_name
ORDER BY c.category_name, total_revenue DESC;

-- 3. Monthly inventory activity: flag slow moving and dead stock products by quantity sold
SELECT
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    c.category_id,
    c.category_name,
    p.product_id,
    p.p_name,
    SUM(oi.quantity) AS `quantity sold`,
    CASE
        WHEN SUM(oi.quantity) < 2 THEN 'SLOW MOVING'
        WHEN SUM(oi.quantity) = 0 THEN 'DEAD STOCK'
        ELSE 'NORMAL'
    END AS `activity`
FROM
    products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN product_variants pv ON p.product_id = pv.product_id
    JOIN order_items oi ON pv.variant_id = oi.variant_id
    JOIN orders o ON oi.order_id = o.order_id
WHERE
    o.o_status = 'delivered'
GROUP BY YEAR(o.order_date), MONTH(o.order_date), p.product_id, p.p_name
ORDER BY p.p_name, year, month ASC;

-- 4. 3-month rolling analysis for dead/slow-moving stock for a specific product (example: product_id=10)
--    Uses fn_monthly_units_sold() function
WITH RECURSIVE months AS (
    SELECT 2025 AS yr, 1 AS mo
    UNION ALL
    SELECT
        IF(mo = 12, yr + 1, yr),
        IF(mo = 12, 1, mo + 1)
    FROM months
    WHERE yr < 2026 OR mo < 12
),
monthly_units_sold AS (
    SELECT
        yr,
        mo,
        fn_monthly_units_sold(10, yr, mo) AS `monthly units`
    FROM months
),
rolling AS (
    SELECT
        mus.*,
        SUM(mus.`monthly units`) OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_sum
    FROM monthly_units_sold mus
)
SELECT
    *,
    CASE
        WHEN rolling_sum = 0 THEN 'DEAD STOCK'
        WHEN rolling_sum < 2 THEN 'SLOW MOVING'
        ELSE 'NORMAL'
    END AS activity
FROM rolling;
