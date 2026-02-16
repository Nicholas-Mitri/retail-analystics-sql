# Retail Analytics Database System

An MySQL database system designed for multi-vendor retail operations with analytics capabilities, customer segmentation, inventory management, and business intelligence reporting.

## Project Overview

This project demonstrates database design and advanced SQL analytics for a retail e-commerce platform. It models a simplified but complex retail ecosystem supporting multiple vendors, product variants, order processing, payment handling, and customer analytics excluding website/app level and payment processing features.

##

**Business Context:**

- Multi-vendor marketplace platform
- Real-time inventory tracking with automated triggers
- Customer behavior analysis using RFM segmentation
- Vendor performance monitoring and commission management
- Sales trend analysis with time-series metrics

## Key Features

### Database Architecture

- **9 Core Tables:** users, vendors, categories, products, product_variants, orders, order_items, payments, addresses
- **Normalized Schema:** 3NF design with proper relationship modeling
- **Self-Referential Hierarchy:** Category tree structure for nested categorization
- **JSON Support:** Flexible product variant attributes

### Advanced SQL Features

- **23 Triggers:** Automated stock management, order tracking, data validation
- **8 Stored Procedures:** Customer segmentation, inventory operations, order processing
- **3 Custom Functions:** Analytics calculations, business metrics
- **5 Business Intelligence Views:** Pre-aggregated metrics for reporting dashboards

### Data Integrity & Performance

- **Comprehensive Constraints:** Foreign keys, check constraints, unique constraints
- **Strategic Indexing:** Optimized for common query patterns (7+ indexes)
- **Cascading Logic:** Automated status updates across related tables
- **Audit Trails:** Timestamp tracking on all major entities

## Database Schema Highlights

| Table                | Purpose                               | Key Relationships                               |
| -------------------- | ------------------------------------- | ----------------------------------------------- |
| **users**            | Core user authentication & profiles   | Parent to vendors, orders, addresses            |
| **vendors**          | Vendor accounts & commission tracking | Links to users, products                        |
| **categories**       | Self-referential category hierarchy   | Parent to products                              |
| **products**         | Product master data                   | Belongs to vendor & category                    |
| **product_variants** | SKU-level inventory & pricing         | Belongs to product, has JSON attributes         |
| **orders**           | Order headers with status tracking    | Belongs to user, has shipping/billing addresses |
| **order_items**      | Line items with pricing snapshot      | Links orders to product variants                |
| **payments**         | Payment transactions & status         | Belongs to order                                |
| **addresses**        | Customer shipping/billing addresses   | Belongs to user                                 |

**Cardinality:**

- Users → Orders (1:N)
- Orders → Order Items (1:N)
- Products → Variants (1:N)
- Categories → Categories (1:N, self-referential)
- Vendors → Products (1:N)

## Setup Instructions

### Prerequisites

- MySQL 8.0 or higher
- Bash shell (macOS/Linux) or Git Bash (Windows)
- MySQL client tools

### Quick Start

1. **Clone the Repository**

   ```bash
   cd /path/to/your/workspace
   git clone <repository-url>
   cd "Retail Analytics"
   ```

2. **Set MySQL Password**

   ```bash
   export MYSQL_PASSWORD='your_mysql_password'
   ```

3. **Run Master Setup Script**
   ```bash
   chmod +x scripts/master_setup.sh
   ./scripts/master_setup.sh
   ```

The [master_setup.sh](scripts/master_setup.sh) script automatically:

- Creates the `retail_analytics` database
- Builds all 9 tables with proper structure
- Applies triggers for automated business logic
- Loads 500+ lines of sample data
- Sets up post-data triggers
- Creates constraints and indexes for performance

### Manual Setup (Alternative)

If you prefer manual execution:

```bash
mysql -u root -p retail_analytics < database/schema/01_create_database.sql
mysql -u root -p retail_analytics < database/schema/02_create_tables.sql
mysql -u root -p retail_analytics < database/schema/05_create_triggers.sql
mysql -u root -p retail_analytics < database/data/insert_sample_data.sql
mysql -u root -p retail_analytics < database/schema/06_create_triggers_after_data_insert.sql
mysql -u root -p retail_analytics < database/schema/04_create_constraints.sql
mysql -u root -p retail_analytics < database/schema/03_create_indexes.sql
mysql -u root -p retail_analytics < database/procedures/customer_procedures.sql
mysql -u root -p retail_analytics < database/procedures/inventory_procedures.sql
mysql -u root -p retail_analytics < database/functions/analytics_functions.sql
mysql -u root -p retail_analytics < database/views/business_views.sql
```

### Verification

```sql
USE retail_analytics;
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM orders;
```

## Query Showcase

### 1. RFM Customer Segmentation with Churn Prediction

**Business Value:** Identifies customer segments (Champion, Loyal, At Risk, Hibernating) for targeted marketing campaigns and retention strategies.

```sql
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
```

**Techniques Used:** Multi-level CTEs, Window Functions (NTILE), CASE statements, Date calculations

---

### 2. Product Performance by Category with Revenue Ranking

**Business Value:** Identifies top-performing products within each category for inventory planning and promotional focus.

```sql
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
GROUP BY c.category_id, c.category_name, p.product_id, p.p_name
ORDER BY c.category_name, total_revenue DESC;
```

**Techniques Used:** Window Functions (RANK with PARTITION BY), Multi-table JOINs, Aggregation

---

### 3. Month-over-Month Sales Growth Analysis

**Business Value:** Tracks sales momentum and identifies growth trends for forecasting and performance evaluation.

```sql
SELECT
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(oi.total_price) AS monthly_sales,
    LAG(SUM(oi.total_price)) OVER (ORDER BY YEAR(o.order_date), MONTH(o.order_date)) AS previous_month_sales,
    SUM(oi.total_price) - LAG(SUM(oi.total_price)) OVER (ORDER BY YEAR(o.order_date), MONTH(o.order_date)) AS sales_change,
    ROUND(
        ((SUM(oi.total_price) - LAG(SUM(oi.total_price)) OVER (ORDER BY YEAR(o.order_date), MONTH(o.order_date)))
        / LAG(SUM(oi.total_price)) OVER (ORDER BY YEAR(o.order_date), MONTH(o.order_date))) * 100,
        2
    ) AS percent_change
FROM
    orders o
    JOIN order_items oi ON o.order_id = oi.order_id
WHERE
    o.o_status = 'delivered'
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year, month;
```

**Techniques Used:** Window Functions (LAG), Time-series analysis, Percentage calculations

## Key Business Insights

Based on the sample data and analytics queries:

1. **Customer Segmentation:** RFM analysis enables targeted marketing—Champions receive loyalty rewards, At-Risk customers get re-engagement campaigns, and Hibernating customers receive win-back offers.

2. **Inventory Optimization:** Automated stock tracking via triggers prevents overselling, while slow-moving product identification helps optimize warehouse space.

3. **Vendor Performance:** Commission tracking and sales metrics help identify top vendors and enforce accountability.

4. **Sales Trends:** Month-over-month analysis reveals seasonal patterns and growth trajectories for strategic planning.

5. **Category Performance:** Revenue ranking identifies winning products per category, informing procurement and merchandising decisions.

## Project Structure

```
Retail Analytics/
├── database/
│   ├── schema/
│   │   ├── 01_create_database.sql
│   │   ├── 02_create_tables.sql
│   │   ├── 03_create_indexes.sql
│   │   ├── 04_create_constraints.sql
│   │   ├── 05_create_triggers.sql
│   │   └── 06_create_triggers_after_data_insert.sql
│   ├── data/
│   │   ├── insert_sample_data.sql
│   │   └── data_validation.sql
│   ├── procedures/
│   │   ├── customer_procedures.sql
│   │   └── inventory_procedures.sql
│   ├── functions/
│   │   └── analytics_functions.sql
│   └── views/
│       └── business_views.sql
├── queries/
│   ├── customer_analytics.sql
│   └── product_analytics.sql
├── scripts/
│   └── master_setup.sh
├── GUIDELIINE.md
├── LICENSE
└── README.md
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
