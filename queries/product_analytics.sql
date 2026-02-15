-- ## database/queries/product_analytics.sql
-- - [x] Write query for best/worst performing products by revenue and units sold
-- - [x] Write query for product performance by category with rankings
-- - [ ] Write query for inventory turnover rate analysis
-- - [ ] Write query to identify slow-moving/dead stock items


SELECT 
    p.product_id,
    p.p_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.total_price) AS total_revenue
FROM
    products p
        JOIN
    product_variants pv ON p.product_id = pv.product_id
        JOIN
    order_items oi ON pv.variant_id = oi.variant_id
        JOIN
    orders o ON oi.order_id = o.order_id
WHERE
    o.o_status = 'delivered'
GROUP BY p.product_id , p.p_name
ORDER BY total_revenue DESC;


SELECT 
c.category_id,
    c.category_name,
    p.product_id,
    p.p_name,
    SUM(oi.total_price) AS total_revenue,
    RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(oi.total_price) DESC) AS 'Rank'
FROM
    products p
        JOIN
    categories c ON p.category_id = c.category_id
        JOIN
    product_variants pv ON p.product_id = pv.product_id
        JOIN
    order_items oi ON pv.variant_id = oi.variant_id
        JOIN
    orders o ON oi.order_id = o.order_id
WHERE
    o.o_status = 'delivered' 
GROUP BY p.product_id , p.p_name
ORDER BY c.category_name , total_revenue DESC;
