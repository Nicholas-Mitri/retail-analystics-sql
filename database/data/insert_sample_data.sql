INSERT INTO users (email, user_password, first_name, last_name, phone, customer_type, created_at) VALUES
-- Customers (14)
('john.smith@email.com', 'password123', 'John', 'Smith', '555-0101', 'customer', DATE_SUB(NOW(), INTERVAL 12 MONTH)),
('sarah.johnson@email.com', 'password123', 'Sarah', 'Johnson', '555-0102', 'customer', DATE_SUB(NOW(), INTERVAL 12 MONTH)),
('michael.williams@email.com', 'password123', 'Michael', 'Williams', '555-0103', 'customer', DATE_SUB(NOW(), INTERVAL 11 MONTH)),
('emily.brown@email.com', 'password123', 'Emily', 'Brown', '555-0104', 'customer', DATE_SUB(NOW(), INTERVAL 10 MONTH)),
('david.jones@email.com', 'password123', 'David', 'Jones', '555-0105', 'customer', DATE_SUB(NOW(), INTERVAL 9 MONTH)),
('jessica.garcia@email.com', 'password123', 'Jessica', 'Garcia', '555-0106', 'customer', DATE_SUB(NOW(), INTERVAL 9 MONTH)),
('james.miller@email.com', 'password123', 'James', 'Miller', '555-0107', 'customer', DATE_SUB(NOW(), INTERVAL 8 MONTH)),
('ashley.davis@email.com', 'password123', 'Ashley', 'Davis', '555-0108', 'customer', DATE_SUB(NOW(), INTERVAL 7 MONTH)),
('robert.rodriguez@email.com', 'password123', 'Robert', 'Rodriguez', '555-0109', 'customer', DATE_SUB(NOW(), INTERVAL 7 MONTH)),
('amanda.martinez@email.com', 'password123', 'Amanda', 'Martinez', '555-0110', 'customer', DATE_SUB(NOW(), INTERVAL 7 MONTH)),
('christopher.hernandez@email.com', 'password123', 'Christopher', 'Hernandez', '555-0111', 'customer', DATE_SUB(NOW(), INTERVAL 6 MONTH)),
('jennifer.lopez@email.com', 'password123', 'Jennifer', 'Lopez', '555-0112', 'customer', DATE_SUB(NOW(), INTERVAL 6 MONTH)),
('matthew.gonzalez@email.com', 'password123', 'Matthew', 'Gonzalez', '555-0113', 'customer', DATE_SUB(NOW(), INTERVAL 6 MONTH)),
('lisa.wilson@email.com', 'password123', 'Lisa', 'Wilson', '555-0114', 'customer', DATE_SUB(NOW(), INTERVAL 5 MONTH)),

-- Vendors (5)
('techsupplies@vendor.com', 'password123', 'Tech', 'Supplies Inc', '555-0201', 'vendor', DATE_SUB(NOW(), INTERVAL 13 MONTH)),
('globalparts@vendor.com', 'password123', 'Global', 'Parts LLC', '555-0202', 'vendor', DATE_SUB(NOW(), INTERVAL 13 MONTH)),
('premiumgoods@vendor.com', 'password123', 'Premium', 'Goods Co', '555-0203', 'vendor', DATE_SUB(NOW(), INTERVAL 13 MONTH)),
('quickship@vendor.com', 'password123', 'Quick', 'Ship Corp', '555-0204', 'vendor', DATE_SUB(NOW(), INTERVAL 13 MONTH)),
('wholesale@vendor.com', 'password123', 'Wholesale', 'Direct', '555-0205', 'vendor', DATE_SUB(NOW(), INTERVAL 13 MONTH)),

-- Admin (1)
('admin@company.com', 'adminpass456', 'System', 'Administrator', '555-0301', 'admin', DATE_SUB(NOW(), INTERVAL 14 MONTH));

INSERT INTO vendors (user_id, company_name, commission_rate, approved_at, v_status) VALUES
(15, 'Tech Supplies Inc', 12.50, DATE_SUB(NOW(), INTERVAL 12 MONTH), 'active'),
(16, 'Global Parts LLC', 10.00, DATE_SUB(NOW(), INTERVAL 12 MONTH), 'active'),
(17, 'Premium Goods Co', 15.00, DATE_SUB(NOW(), INTERVAL 12 MONTH), 'active'),
(18, 'Quick Ship Corp', 8.50, DATE_SUB(NOW(), INTERVAL 12 MONTH), 'active'),
(19, 'Wholesale Direct', 11.00, DATE_SUB(NOW(), INTERVAL 12 MONTH), 'active');

-- =====================================================
-- Categories Structure
-- =====================================================
--  Computers & Laptops (3 vendors)
--     ├── Laptops
--     │   ├── Gaming Laptops
--     │   └── Business Laptops
--     ├── Desktop Computers
--     └── Computer Accessories
--         ├── Monitors
--         └── Keyboards & Mice
--
--  Mobile & Accessories (2 vendors)
--     ├── Smartphones
--     ├── Phone Cases
--     └── Chargers & Cables
--
--  Audio Equipment (1 vendor, can overlap)
--     ├── Headphones
--     ├── Earbuds
--     └── Bluetooth Speakers
-- =====================================================

INSERT INTO categories (category_id, parent_category_id, category_name, slug, description, is_active, display_order) VALUES
-- Main Categories (Level 1)
(1, NULL, 'Computers & Laptops', 'computers-laptops', 'Desktop computers, laptops, and computer accessories for work and gaming', TRUE, 1),
(2, NULL, 'Mobile & Accessories', 'mobile-accessories', 'Smartphones, cases, chargers, and mobile device accessories', TRUE, 2),
(3, NULL, 'Audio Equipment', 'audio-equipment', 'Headphones, earbuds, speakers, and audio accessories', TRUE, 3),

-- Computers & Laptops Subcategories (Level 2)
(4, 1, 'Laptops', 'laptops', 'Portable computers for work, gaming, and everyday use', TRUE, 1),
(5, 1, 'Desktop Computers', 'desktop-computers', 'Full-sized desktop PCs and workstations', TRUE, 2),
(6, 1, 'Computer Accessories', 'computer-accessories', 'Monitors, keyboards, mice, and other PC peripherals', TRUE, 3),

-- Laptops Subcategories (Level 3)
(7, 4, 'Gaming Laptops', 'gaming-laptops', 'High-performance laptops designed for gaming and creative work', TRUE, 1),
(8, 4, 'Business Laptops', 'business-laptops', 'Professional laptops optimized for productivity and portability', TRUE, 2),

-- Computer Accessories Subcategories (Level 3)
(9, 6, 'Monitors', 'monitors', 'LCD, LED, and gaming monitors in various sizes', TRUE, 1),
(10, 6, 'Keyboards & Mice', 'keyboards-mice', 'Wired and wireless keyboards, mice, and combo sets', TRUE, 2),

-- Mobile & Accessories Subcategories (Level 2)
(11, 2, 'Smartphones', 'smartphones', 'Latest Android and iOS smartphones from top brands', TRUE, 1),
(12, 2, 'Phone Cases', 'phone-cases', 'Protective cases and covers for all phone models', TRUE, 2),
(13, 2, 'Chargers & Cables', 'chargers-cables', 'USB cables, wall chargers, car chargers, and power banks', TRUE, 3),

-- Audio Equipment Subcategories (Level 2)
(14, 3, 'Headphones', 'headphones', 'Over-ear and on-ear headphones for music and gaming', TRUE, 1),
(15, 3, 'Earbuds', 'earbuds', 'In-ear wireless and wired earbuds for portability', TRUE, 2),
(16, 3, 'Bluetooth Speakers', 'bluetooth-speakers', 'Portable and home Bluetooth speakers', TRUE, 3);


INSERT INTO addresses (user_id, type, street_address, city, state, postal_code, country, is_default) VALUES
-- User 1: John Smith (2 addresses - shipping default, billing)
(1, 'shipping', '123 Maple Street', 'Toronto', 'Ontario', 'M5H 2N2', 'Canada', TRUE),
(1, 'billing', '123 Maple Street', 'Toronto', 'Ontario', 'M5H 2N2', 'Canada', FALSE),

-- User 2: Sarah Johnson (1 address)
(2, 'shipping', '456 Oak Avenue', 'Vancouver', 'British Columbia', 'V6B 1A1', 'Canada', TRUE),

-- User 3: Michael Williams (2 addresses - home and work)
(3, 'shipping', '789 Pine Road', 'Montreal', 'Quebec', 'H3B 1A0', 'Canada', TRUE),
(3, 'shipping', '321 Business Park Drive', 'Montreal', 'Quebec', 'H3C 2E5', 'Canada', FALSE),

-- User 4: Emily Brown (1 address)
(4, 'shipping', '234 Elm Street', 'Calgary', 'Alberta', 'T2P 3M4', 'Canada', TRUE),

-- User 5: David Jones (3 addresses - home shipping, billing, cottage)
(5, 'shipping', '567 Birch Lane', 'Ottawa', 'Ontario', 'K1P 5G4', 'Canada', TRUE),
(5, 'billing', '567 Birch Lane', 'Ottawa', 'Ontario', 'K1P 5G4', 'Canada', FALSE),
(5, 'shipping', '88 Lakeside Cottage Road', 'Muskoka', 'Ontario', 'P1L 1K3', 'Canada', FALSE),

-- User 6: Jessica Garcia (1 address)
(6, 'shipping', '890 Cedar Court', 'Edmonton', 'Alberta', 'T5J 2R7', 'Canada', TRUE),

-- User 7: James Miller (2 addresses - shipping and billing different)
(7, 'shipping', '432 Willow Way', 'Winnipeg', 'Manitoba', 'R3C 1A5', 'Canada', TRUE),
(7, 'billing', '100 Corporate Plaza', 'Winnipeg', 'Manitoba', 'R3B 0N2', 'Canada', FALSE),

-- User 8: Ashley Davis (1 address)
(8, 'shipping', '765 Spruce Drive', 'Halifax', 'Nova Scotia', 'B3H 1T1', 'Canada', TRUE),

-- User 9: Robert Rodriguez (2 addresses)
(9, 'shipping', '198 Ash Boulevard', 'Victoria', 'British Columbia', 'V8W 1A1', 'Canada', TRUE),
(9, 'shipping', '42 Apartment Complex, Unit 304', 'Victoria', 'British Columbia', 'V8W 2B3', 'Canada', FALSE),

-- User 10: Amanda Martinez (1 address)
(10, 'shipping', '543 Poplar Street', 'Saskatoon', 'Saskatchewan', 'S7K 1M5', 'Canada', TRUE),

-- User 11: Christopher Hernandez (2 addresses - home and parents)
(11, 'shipping', '876 Walnut Avenue', 'Regina', 'Saskatchewan', 'S4P 2H1', 'Canada', TRUE),
(11, 'shipping', '22 Family Home Road', 'Regina', 'Saskatchewan', 'S4R 3K8', 'Canada', FALSE),

-- User 12: Jennifer Lopez (1 address)
(12, 'shipping', '321 Chestnut Lane', 'London', 'Ontario', 'N6A 1A1', 'Canada', TRUE),

-- User 13: Matthew Gonzalez (2 addresses - condo and office)
(13, 'shipping', '654 Beech Street, Unit 12B', 'Mississauga', 'Ontario', 'L5B 1M2', 'Canada', TRUE),
(13, 'billing', '1500 Tech Park Boulevard', 'Mississauga', 'Ontario', 'L5C 3E4', 'Canada', FALSE),

-- User 14: Lisa Wilson (1 address)
(14, 'shipping', '987 Sycamore Road', 'Brampton', 'Ontario', 'L6T 2K5', 'Canada', TRUE),

-- User 15: Tech Supplies Inc (Vendor)
(15, 'billing', '1200 Industrial Parkway, Suite 300', 'Markham', 'Ontario', 'L3R 8G5', 'Canada', TRUE),

-- User 16: Global Parts LLC (Vendor)
(16, 'billing', '450 Distribution Center Road', 'Burnaby', 'British Columbia', 'V5C 6B2', 'Canada', TRUE),

-- User 17: Premium Goods Co (Vendor)
(17, 'billing', '88 Luxury Lane, Building B', 'Toronto', 'Ontario', 'M4W 3E2', 'Canada', TRUE),

-- User 18: Quick Ship Corp (Vendor)
(18, 'billing', '2500 Warehouse Boulevard', 'Brampton', 'Ontario', 'L6S 6H3', 'Canada', TRUE),

-- User 19: Wholesale Direct (Vendor)
(19, 'billing', '3600 Commerce Drive', 'Richmond', 'British Columbia', 'V6X 2T2', 'Canada', TRUE),

-- User 20: System Administrator (Admin)
(20, 'billing', '100 Head Office Plaza, 10th Floor', 'Toronto', 'Ontario', 'M5J 2V5', 'Canada', TRUE);


INSERT INTO products (vendor_id, category_id, p_name, description, p_status) VALUES
-- Tech Supplies Inc (vendor 1) - Computers & Laptops
(1, 7, 'Pro Gaming Laptop X1', 'High-performance gaming laptop with RTX 4070 and 16GB RAM', 'active'),
(1, 8, 'Business Elite Ultrabook', 'Slim professional laptop with 14-inch display and all-day battery', 'active'),
(1, 5, 'Tower Workstation Pro', 'Powerful desktop workstation for creative and engineering work', 'active'),
(1, 9, '27" 4K IPS Monitor', 'Ultra HD monitor with wide color gamut and thin bezels', 'active'),
(1, 10, 'Wireless Keyboard & Mouse Combo', 'Ergonomic wireless set with long battery life', 'active'),
(1, 8, 'Budget Laptop 15', 'Affordable 15-inch laptop for students and everyday use', 'active'),

-- Global Parts LLC (vendor 2) - Mixed categories
(2, 7, 'Apex Gaming Laptop', 'Gaming laptop with high-refresh display and RGB keyboard', 'active'),
(2, 11, 'Mid-Range Smartphone Pro', 'Feature-packed smartphone with great camera and battery', 'active'),
(2, 12, 'Universal Silicone Phone Case', 'Flexible protective case compatible with multiple models', 'active'),
(2, 13, 'Fast Charging USB-C Cable Pack', '3-pack of durable USB-C to USB-A cables, 6ft each', 'active'),
(2, 14, 'Over-Ear Studio Headphones', 'Professional monitoring headphones with flat frequency response', 'active'),
(2, 9, '24" Full HD Monitor', 'Compact monitor ideal for dual-screen setups', 'active'),

-- Premium Goods Co (vendor 3) - Premium items
(3, 7, 'Ultra Gaming Beast Laptop', 'Top-tier gaming laptop with RTX 4090 and 32GB RAM', 'active'),
(3, 11, 'Flagship Smartphone Max', 'Premium smartphone with pro camera system and ceramic build', 'active'),
(3, 14, 'Noise-Canceling Premium Headphones', 'Luxury wireless headphones with 40hr battery', 'active'),
(3, 15, 'Pro Wireless Earbuds', 'High-fidelity true wireless earbuds with ANC', 'active'),
(3, 16, 'Portable Bluetooth Speaker Pro', 'Premium waterproof speaker with 360-degree sound', 'active'),
(3, 5, 'Compact Mini PC', 'Tiny powerhouse for home office and media center', 'active'),

-- Quick Ship Corp (vendor 4) - Fast-shipping staples
(4, 11, 'Value Smartphone', 'Affordable smartphone with large display and decent battery', 'active'),
(4, 12, 'Clear Hard Phone Case', 'Transparent case that shows your phone design', 'active'),
(4, 13, 'Portable Power Bank 20000mAh', 'High-capacity power bank with fast charging support', 'active'),
(4, 15, 'Budget Wireless Earbuds', 'Reliable wireless earbuds for calls and music', 'active'),
(4, 16, 'Mini Bluetooth Speaker', 'Pocket-sized speaker for on-the-go listening', 'active'),
(4, 10, 'Gaming Mechanical Keyboard', 'RGB mechanical keyboard with hot-swappable switches', 'active'),

-- Wholesale Direct (vendor 5) - Bulk/wholesale
(5, 8, 'Enterprise Laptop Bulk', 'Reliable business laptop for corporate deployments', 'active'),
(5, 13, 'USB-C Charging Station 4-Port', 'Desktop charging station for multiple devices', 'active'),
(5, 14, 'Wired Gaming Headset', 'Affordable gaming headset with microphone', 'active'),
(5, 15, 'Sport Wireless Earbuds', 'Sweat-resistant earbuds for workouts', 'active'),
(5, 16, 'Outdoor Bluetooth Speaker', 'Rugged waterproof speaker for outdoor use', 'active');

INSERT INTO product_variants (product_id, sku, attributes, price, stock_quantity, pv_status) VALUES
-- Product 1: Pro Gaming Laptop X1
(1, 'TS-GAMING-X1-16-512', '{"RAM": "16GB", "storage": "512GB SSD"}', 1299.99, 25, 'active'),
(1, 'TS-GAMING-X1-32-1TB', '{"RAM": "32GB", "storage": "1TB SSD"}', 1599.99, 15, 'active'),

-- Product 2: Business Elite Ultrabook
(2, 'TS-ULTRA-8GB', '{"RAM": "8GB"}', 899.99, 40, 'active'),
(2, 'TS-ULTRA-16GB', '{"RAM": "16GB"}', 1049.99, 30, 'active'),

-- Product 3: Tower Workstation Pro
(3, 'TS-WORK-32GB', '{"RAM": "32GB"}', 1899.99, 12, 'active'),
(3, 'TS-WORK-64GB', '{"RAM": "64GB"}', 2499.99, 8, 'active'),

-- Product 4: 27" 4K IPS Monitor
(4, 'TS-MON-27-BLK', '{"color": "black"}', 349.99, 50, 'active'),
(4, 'TS-MON-27-SLV', '{"color": "silver"}', 349.99, 35, 'active'),

-- Product 5: Wireless Keyboard & Mouse Combo
(5, 'TS-KBMOUSE-BLK', '{"color": "black"}', 79.99, 100, 'active'),
(5, 'TS-KBMOUSE-WHT', '{"color": "white"}', 79.99, 80, 'active'),

-- Product 6: Budget Laptop 15
(6, 'TS-BUDGET-8GB', '{"RAM": "8GB"}', 449.99, 75, 'active'),
(6, 'TS-BUDGET-16GB', '{"RAM": "16GB"}', 549.99, 50, 'active'),

-- Product 7: Apex Gaming Laptop
(7, 'GP-APEX-4060', '{"GPU": "RTX 4060"}', 999.99, 30, 'active'),
(7, 'GP-APEX-4070', '{"GPU": "RTX 4070"}', 1249.99, 20, 'active'),

-- Product 8: Mid-Range Smartphone Pro
(8, 'GP-PHONE-128', '{"storage": "128GB"}', 449.99, 60, 'active'),
(8, 'GP-PHONE-256', '{"storage": "256GB"}', 529.99, 45, 'active'),

-- Product 9: Universal Silicone Phone Case
(9, 'GP-CASE-BLK', '{"color": "black"}', 14.99, 200, 'active'),
(9, 'GP-CASE-BLU', '{"color": "blue"}', 14.99, 180, 'active'),
(9, 'GP-CASE-CLR', '{"color": "clear"}', 14.99, 150, 'active'),

-- Product 10: Fast Charging USB-C Cable Pack
(10, 'GP-CABLE-3PK', NULL, 19.99, 300, 'active'),

-- Product 11: Over-Ear Studio Headphones
(11, 'GP-STUDIO-BLK', '{"color": "black"}', 129.99, 80, 'active'),
(11, 'GP-STUDIO-WHT', '{"color": "white"}', 129.99, 65, 'active'),

-- Product 12: 24" Full HD Monitor
(12, 'GP-MON24-BLK', '{"color": "black"}', 179.99, 90, 'active'),

-- Product 13: Ultra Gaming Beast Laptop
(13, 'PG-BEAST-32-1TB', '{"RAM": "32GB", "storage": "1TB SSD"}', 2499.99, 10, 'active'),
(13, 'PG-BEAST-64-2TB', '{"RAM": "64GB", "storage": "2TB SSD"}', 3199.99, 5, 'active'),

-- Product 14: Flagship Smartphone Max
(14, 'PG-FLAG-256', '{"storage": "256GB"}', 999.99, 40, 'active'),
(14, 'PG-FLAG-512', '{"storage": "512GB"}', 1199.99, 25, 'active'),

-- Product 15: Noise-Canceling Premium Headphones
(15, 'PG-NC-BLK', '{"color": "black"}', 349.99, 45, 'active'),
(15, 'PG-NC-SLV', '{"color": "silver"}', 349.99, 35, 'active'),

-- Product 16: Pro Wireless Earbuds
(16, 'PG-EARBUD-BLK', '{"color": "black"}', 249.99, 70, 'active'),
(16, 'PG-EARBUD-WHT', '{"color": "white"}', 249.99, 55, 'active'),

-- Product 17: Portable Bluetooth Speaker Pro
(17, 'PG-SPEAKER-BLK', '{"color": "black"}', 199.99, 60, 'active'),
(17, 'PG-SPEAKER-BLU', '{"color": "blue"}', 199.99, 50, 'active'),

-- Product 18: Compact Mini PC
(18, 'PG-MINIPC-16', '{"RAM": "16GB"}', 599.99, 35, 'active'),
(18, 'PG-MINIPC-32', '{"RAM": "32GB"}', 749.99, 25, 'active'),

-- Product 19: Value Smartphone
(19, 'QS-VALUE-64', '{"storage": "64GB"}', 199.99, 120, 'active'),
(19, 'QS-VALUE-128', '{"storage": "128GB"}', 249.99, 90, 'active'),

-- Product 20: Clear Hard Phone Case
(20, 'QS-CLEAR-UNI', NULL, 12.99, 250, 'active'),

-- Product 21: Portable Power Bank 20000mAh
(21, 'QS-POWER-20K', NULL, 34.99, 150, 'active'),

-- Product 22: Budget Wireless Earbuds
(22, 'QS-EARBUD-BLK', '{"color": "black"}', 39.99, 200, 'active'),
(22, 'QS-EARBUD-WHT', '{"color": "white"}', 39.99, 180, 'active'),

-- Product 23: Mini Bluetooth Speaker
(23, 'QS-MINI-BLK', '{"color": "black"}', 29.99, 175, 'active'),
(23, 'QS-MINI-PNK', '{"color": "pink"}', 29.99, 140, 'active'),
(23, 'QS-MINI-BLU', '{"color": "blue"}', 29.99, 155, 'active'),

-- Product 24: Gaming Mechanical Keyboard
(24, 'QS-KB-GAME-BLK', '{"color": "black"}', 89.99, 85, 'active'),
(24, 'QS-KB-GAME-WHT', '{"color": "white"}', 89.99, 70, 'active'),

-- Product 25: Enterprise Laptop Bulk
(25, 'WD-ENT-8GB', '{"RAM": "8GB"}', 649.99, 100, 'active'),
(25, 'WD-ENT-16GB', '{"RAM": "16GB"}', 799.99, 75, 'active'),

-- Product 26: USB-C Charging Station 4-Port
(26, 'WD-CHARGE-4P', NULL, 49.99, 120, 'active'),

-- Product 27: Wired Gaming Headset
(27, 'WD-HEADSET-BLK', '{"color": "black"}', 59.99, 150, 'active'),
(27, 'WD-HEADSET-GRN', '{"color": "green"}', 59.99, 130, 'active'),

-- Product 28: Sport Wireless Earbuds
(28, 'WD-SPORT-BLK', '{"color": "black"}', 44.99, 180, 'active'),
(28, 'WD-SPORT-BLU', '{"color": "blue"}', 44.99, 160, 'active'),

-- Product 29: Outdoor Bluetooth Speaker
(29, 'WD-OUTDOOR-BLK', '{"color": "black"}', 79.99, 95, 'active'),
(29, 'WD-OUTDOOR-GRN', '{"color": "green"}', 79.99, 80, 'active');

INSERT INTO orders (user_id, address_id, o_status, order_date, shipped_date, delivered_date) VALUES
    (1, 1, 'delivered', '2025-03-10', '2025-03-15', '2025-03-17'),
    (1, 1, 'delivered', '2025-06-02', '2025-06-07', '2025-06-09'),
    (2, 3, 'delivered', '2025-03-10', '2025-03-15', '2025-03-17'),
    (2, 3, 'delivered', '2025-04-02', '2025-04-07', '2025-04-09'),
    (2, 3, 'delivered', '2025-05-10', '2025-05-15', '2025-05-17'),
    (3, 4, 'delivered', '2025-06-02', '2025-06-07', '2025-06-09'),
    (3, 4, 'delivered', '2025-08-10', '2025-08-15', '2025-08-17'),
    (4, 6, 'delivered', '2025-05-02', '2025-05-07', '2025-05-09'),
    (5, 7, 'delivered', '2025-06-10', '2025-06-15', '2025-06-17'),
    (6, 10, 'delivered', '2025-06-02', '2025-06-07', '2025-06-09'),
    (7, 11, 'delivered', '2025-07-10', '2025-07-15', '2025-07-17'),
    (7, 11, 'delivered', '2025-08-02', '2025-08-07', '2025-08-09'),
    (8, 13, 'delivered', '2025-08-10', '2025-08-15', '2025-08-17'),
    (9, 14, 'delivered', '2025-08-14', '2025-08-19', '2025-08-21'),
    (9, 14, 'delivered', '2025-09-18', '2025-09-23', '2025-09-25'),
    (9, 14, 'delivered', '2025-09-26', '2025-10-01', '2025-10-03'),
    (10, 16, 'delivered', '2025-08-10', '2025-08-15', '2025-08-17'),
    (10, 16, 'cancelled', '2025-08-22', NULL, NULL),
    (10, 16, 'delivered', '2025-09-10', '2025-09-15', '2025-09-17'),
    (10, 16, 'delivered', '2025-09-21', '2025-09-26', '2025-09-28'),
    (11, 17, 'delivered', '2025-09-10', '2025-09-15', '2025-09-17'),
    (11, 17, 'delivered', '2025-09-02', '2025-09-07', '2025-09-09'),
    (12, 19, 'delivered', '2025-10-10', '2025-10-15', '2025-10-17'),
    (13, 20, 'delivered', '2025-10-02', '2025-10-07', '2025-10-09'),
    (14, 22, 'delivered', '2025-10-10', '2025-10-15', '2025-10-17'),
    (14, 22, 'shipped', '2026-01-09', '2026-01-13', NULL),
    (14, 22, 'processing', '2026-01-20', NULL, NULL);

INSERT INTO order_items (order_id, variant_id, quantity, unit_price) VALUES
-- Order 1 (user 1, Mar 2025) - Gaming laptop + accessories
(1, 1, 1, 1299.99),  -- Pro Gaming Laptop X1 16GB/512GB
(1, 9, 1, 79.99),    -- Wireless Keyboard & Mouse Combo Black

-- Order 2 (user 1, Jun 2025) - Monitor upgrade
(2, 7, 1, 349.99),   -- 27" 4K IPS Monitor Black
(2, 21, 1, 129.99),  -- Over-Ear Studio Headphones Black

-- Order 3 (user 2, Mar 2025) - Phone + accessories
(3, 15, 1, 449.99),  -- Mid-Range Smartphone Pro 128GB
(3, 17, 1, 14.99),   -- Universal Silicone Phone Case Black
(3, 20, 1, 19.99),   -- Fast Charging USB-C Cable Pack

-- Order 4 (user 2, Apr 2025) - Additional phone case
(4, 18, 2, 14.99),   -- Universal Silicone Phone Case Blue (qty 2)

-- Order 5 (user 2, May 2025) - Power bank
(5, 39, 1, 34.99),   -- Portable Power Bank 20000mAh

-- Order 6 (user 3, Jun 2025) - Budget laptop for work
(6, 11, 1, 449.99),  -- Budget Laptop 15 8GB
(6, 10, 1, 79.99),   -- Wireless Keyboard & Mouse Combo White

-- Order 7 (user 3, Aug 2025) - Upgrade RAM
(7, 12, 1, 549.99),  -- Budget Laptop 15 16GB

-- Order 8 (user 4, May 2025) - Workstation setup
(8, 5, 1, 1899.99),  -- Tower Workstation Pro 32GB
(8, 8, 2, 349.99),   -- 27" 4K IPS Monitor Silver (qty 2)

-- Order 9 (user 5, Jun 2025) - Gaming laptop
(9, 13, 1, 999.99),  -- Apex Gaming Laptop RTX 4060

-- Order 10 (user 6, Jun 2025) - Audio setup
(10, 22, 1, 129.99), -- Over-Ear Studio Headphones White
(10, 32, 1, 199.99), -- Portable Bluetooth Speaker Pro Black

-- Order 11 (user 7, Jul 2025) - Premium flagship phone
(11, 26, 1, 999.99), -- Flagship Smartphone Max 256GB
(11, 30, 1, 249.99), -- Pro Wireless Earbuds Black

-- Order 12 (user 7, Aug 2025) - Phone case + charger
(12, 38, 2, 12.99),  -- Clear Hard Phone Case (qty 2)
(12, 20, 1, 19.99),  -- Fast Charging USB-C Cable Pack

-- Order 13 (user 8, Aug 2025) - Budget phone + accessories
(13, 36, 1, 199.99), -- Value Smartphone 64GB
(13, 40, 1, 39.99),  -- Budget Wireless Earbuds Black
(13, 42, 1, 29.99),  -- Mini Bluetooth Speaker Black

-- Order 14 (user 9, Aug 2025) - Multiple accessories
(14, 20, 2, 19.99),  -- Fast Charging USB-C Cable Pack (qty 2)
(14, 17, 1, 14.99),  -- Universal Silicone Phone Case Black
(14, 39, 1, 34.99),  -- Portable Power Bank 20000mAh

-- Order 15 (user 9, Sep 2025) - Earbuds
(15, 41, 1, 39.99),  -- Budget Wireless Earbuds White

-- Order 16 (user 9, Oct 2025) - Speaker
(16, 43, 1, 29.99),  -- Mini Bluetooth Speaker Pink

-- Order 17 (user 10, Aug 2025) - Premium laptop
(17, 24, 1, 2499.99), -- Ultra Gaming Beast Laptop 32GB/1TB
(17, 23, 1, 179.99),  -- 24" Full HD Monitor Black

-- Order 18 (user 10, Aug 2025 - CANCELLED) - Was going to buy accessories
(18, 45, 1, 89.99),  -- Gaming Mechanical Keyboard Black
(18, 21, 1, 129.99), -- Over-Ear Studio Headphones Black

-- Order 19 (user 10, Sep 2025) - Premium audio
(19, 28, 1, 349.99), -- Noise-Canceling Premium Headphones Black

-- Order 20 (user 10, Sep 2025) - Charging station
(20, 49, 1, 49.99),  -- USB-C Charging Station 4-Port

-- Order 21 (user 11, Sep 2025) - Enterprise laptop
(21, 47, 2, 649.99), -- Enterprise Laptop Bulk 8GB (qty 2)

-- Order 22 (user 11, Sep 2025) - Headsets for office
(22, 50, 3, 59.99),  -- Wired Gaming Headset Black (qty 3)

-- Order 23 (user 12, Oct 2025) - Business ultrabook
(23, 4, 1, 1049.99), -- Business Elite Ultrabook 16GB
(23, 9, 1, 79.99),   -- Wireless Keyboard & Mouse Combo Black

-- Order 24 (user 13, Oct 2025) - Premium phone + accessories
(24, 27, 1, 1199.99), -- Flagship Smartphone Max 512GB
(24, 31, 1, 249.99),  -- Pro Wireless Earbuds White
(24, 38, 1, 12.99),   -- Clear Hard Phone Case

-- Order 25 (user 14, Oct 2025) - Top tier gaming laptop
(25, 2, 1, 1599.99),  -- Pro Gaming Laptop X1 32GB/1TB
(25, 46, 1, 89.99),   -- Gaming Mechanical Keyboard White

-- Order 26 (user 14, Jan 2026 - SHIPPED) - Audio upgrade
(26, 29, 1, 349.99),  -- Noise-Canceling Premium Headphones Silver
(26, 33, 1, 199.99),  -- Portable Bluetooth Speaker Pro Blue

-- Order 27 (user 14, Jan 2026 - PROCESSING) - Monitor
(27, 7, 1, 349.99);   -- 27" 4K IPS Monitor Black



INSERT INTO payments (order_id, amount, payment_method, pay_status, processed_at, created_at) VALUES
-- Order 1: subtotal 1379.98 → (1379.98 + 5) * 1.13 = 1565.03
(1, 1565.03, 'credit_card', 'completed', '2025-03-15', '2025-03-11'),

-- Order 2: subtotal 479.98 → (479.98 + 5) * 1.13 = 548.03
(2, 548.03, 'paypal', 'completed', '2025-06-07', '2025-06-03'),

-- Order 3: subtotal 484.97 → (484.97 + 5) * 1.13 = 553.67
(3, 553.67, 'debit_card', 'completed', '2025-03-15', '2025-03-11'),

-- Order 4: subtotal 29.98 → (29.98 + 5) * 1.13 = 39.53
(4, 39.53, 'credit_card', 'completed', '2025-04-07', '2025-04-03'),

-- Order 5: subtotal 34.99 → (34.99 + 5) * 1.13 = 45.19
(5, 45.19, 'paypal', 'completed', '2025-05-15', '2025-05-11'),

-- Order 6: subtotal 529.98 → (529.98 + 5) * 1.13 = 604.53
(6, 604.53, 'credit_card', 'completed', '2025-06-07', '2025-06-03'),

-- Order 7: subtotal 549.99 → (549.99 + 5) * 1.13 = 627.14
(7, 627.14, 'debit_card', 'completed', '2025-08-15', '2025-08-11'),

-- Order 8: subtotal 2599.97 → (2599.97 + 5) * 1.13 = 2943.62
(8, 2943.62, 'bank_transfer', 'completed', '2025-05-07', '2025-05-03'),

-- Order 9: subtotal 999.99 → (999.99 + 5) * 1.13 = 1135.64
(9, 1135.64, 'credit_card', 'completed', '2025-06-15', '2025-06-11'),

-- Order 10: subtotal 329.98 → (329.98 + 5) * 1.13 = 378.53
(10, 378.53, 'paypal', 'completed', '2025-06-07', '2025-06-03'),

-- Order 11: subtotal 1249.98 → (1249.98 + 5) * 1.13 = 1418.13
(11, 1418.13, 'credit_card', 'completed', '2025-07-15', '2025-07-11'),

-- Order 12: subtotal 45.97 → (45.97 + 5) * 1.13 = 57.60
(12, 57.60, 'debit_card', 'completed', '2025-08-07', '2025-08-03'),

-- Order 13: subtotal 269.97 → (269.97 + 5) * 1.13 = 310.72
(13, 310.72, 'paypal', 'completed', '2025-08-15', '2025-08-11'),

-- Order 14: subtotal 89.96 → (89.96 + 5) * 1.13 = 107.30
(14, 107.30, 'credit_card', 'completed', '2025-08-19', '2025-08-15'),

-- Order 15: subtotal 39.99 → (39.99 + 5) * 1.13 = 50.84
(15, 50.84, 'paypal', 'completed', '2025-09-23', '2025-09-19'),

-- Order 16: subtotal 29.99 → (29.99 + 5) * 1.13 = 39.54
(16, 39.54, 'debit_card', 'completed', '2025-10-01', '2025-09-27'),

-- Order 17: subtotal 2679.98 → (2679.98 + 5) * 1.13 = 3034.03
(17, 3034.03, 'credit_card', 'completed', '2025-08-15', '2025-08-11'),

-- Order 18: CANCELLED - subtotal 219.98 → (219.98 + 5) * 1.13 = 254.23
(18, 254.23, 'credit_card', 'failed', NULL, '2025-08-23'),

-- Order 19: subtotal 349.99 → (349.99 + 5) * 1.13 = 401.14
(19, 401.14, 'paypal', 'completed', '2025-09-15', '2025-09-11'),

-- Order 20: subtotal 49.99 → (49.99 + 5) * 1.13 = 62.14
(20, 62.14, 'debit_card', 'completed', '2025-09-26', '2025-09-22'),

-- Order 21: subtotal 1299.98 → (1299.98 + 5) * 1.13 = 1474.63
(21, 1474.63, 'bank_transfer', 'completed', '2025-09-15', '2025-09-11'),

-- Order 22: subtotal 179.97 → (179.97 + 5) * 1.13 = 209.02
(22, 209.02, 'credit_card', 'completed', '2025-09-07', '2025-09-03'),

-- Order 23: subtotal 1129.98 → (1129.98 + 5) * 1.13 = 1282.53
(23, 1282.53, 'credit_card', 'completed', '2025-10-15', '2025-10-11'),

-- Order 24: subtotal 1462.97 → (1462.97 + 5) * 1.13 = 1658.81
(24, 1658.81, 'paypal', 'completed', '2025-10-07', '2025-10-03'),

-- Order 25: subtotal 1689.98 → (1689.98 + 5) * 1.13 = 1915.33
(25, 1915.33, 'credit_card', 'completed', '2025-10-15', '2025-10-11'),

-- Order 26: SHIPPED - subtotal 549.98 → (549.98 + 5) * 1.13 = 627.13
(26, 627.13, 'debit_card', 'completed', '2026-01-13', '2026-01-10'),

-- Order 27: PROCESSING - subtotal 349.99 → (349.99 + 5) * 1.13 = 401.14
(27, 401.14, 'credit_card', 'pending', NULL, '2026-01-21');
