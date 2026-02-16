-- =====================================================
-- TABLE CREATION SCRIPT
-- Filename: 02_create_tables.sql
-- Purpose:  Defines all tables in the retail_analytics database,
--           including relationships, constraints, and datatypes.
-- =====================================================

-- =====================================================
-- Drop existing tables (in reverse dependency order)
-- =====================================================

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS product_variants;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS users;



-- =====================================================
-- Create tables
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
	user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    user_password VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    customer_type ENUM('customer', 'vendor', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
 );

CREATE TABLE IF NOT EXISTS vendors (
	vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL DEFAULT 10.00,
    approved_at TIMESTAMP,
    v_status ENUM('active', 'inactive', 'pending', 'suspended'),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT
 );

CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_category_id INT,
    category_name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(1000) DEFAULT 'No description available.',
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id)
        REFERENCES categories (category_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_category_per_parent (category_name , parent_category_id)
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
	category_id INT NOT NULL,
    p_name VARCHAR(255) NOT NULL,
    description VARCHAR(1000) DEFAULT 'No description available.',
    p_status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE IF NOT EXISTS product_variants (
    variant_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    attributes JSON,
    price DECIMAL(10 , 2 ) NOT NULL CHECK (price >= 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    pv_status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
 );

CREATE TABLE IF NOT EXISTS addresses (
	address_id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	type ENUM('shipping', 'billing') NOT NULL,
	street_address VARCHAR(255) NOT NULL,
	city VARCHAR(100) NOT NULL,
	state VARCHAR(100) NOT NULL,
	postal_code VARCHAR(20) NOT NULL,
	country VARCHAR(100) NOT NULL,
	is_default BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
 );


CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
	address_id INT NOT NULL,
	o_status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_perc DECIMAL(5,2) NOT NULL DEFAULT 13.00,
    shipping_cost DECIMAL(8,2) NOT NULL DEFAULT 5.00,
    total_amount DECIMAL(12,2) AS ((subtotal + shipping_cost)*(1 + tax_perc/100.00)) STORED,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES addresses(address_id)
);


CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) AS (unit_price * quantity) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') NOT NULL,
    pay_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    transaction_id VARCHAR(36) UNIQUE DEFAULT (UUID()),
    failure_reason VARCHAR(255),
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
