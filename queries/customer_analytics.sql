-- Add RFM analysis query for customer segmentation and churn (inactive > 160 days); includes value tier and risk labeling
WITH customer_orders AS (
    SELECT
        u.user_id,
        MIN(DATEDIFF(CURDATE(), o.order_date)) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(p.amount) AS monetary
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE u.customer_type = 'customer'
      AND p.pay_status = 'completed'
    GROUP BY u.user_id
),
rfm_scores AS (
    SELECT
        c.*,
        -- Scoring: 5 = best (most recent, most freq, highest spending), 1 = worst
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_orders c
),
rfm_final AS (
    SELECT
        r.*,
        (recency_score + frequency_score + monetary_score) AS rfm_score
    FROM rfm_scores r
)
SELECT
    rf.*,
    CASE
        WHEN rf.rfm_score >= 13 THEN 'Champion'
        WHEN rf.rfm_score >= 10 THEN 'Loyal'
        WHEN rf.rfm_score >= 7 THEN 'Potential'
        WHEN rf.rfm_score >= 5 THEN 'At Risk'
        ELSE 'Hibernating'
    END AS segment,
    CASE
		WHEN recency > 160 THEN 'YES'
        ELSE 'NO'
	END as 'Churn Risk?'
FROM rfm_final rf
ORDER BY rf.rfm_score DESC, rf.monetary DESC;
