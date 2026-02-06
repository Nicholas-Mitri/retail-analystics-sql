/*
Tables to implement:
- users (customers, vendors, admins)
- vendors
- categories
- products
- product_variants
- orders
- order_items
- payments
- reviews
- addresses

*/

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
    v_status ENUM('active', 'deactivated', 'pending', 'suspended'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
 );
 
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_category_id INT,
    category_name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT DEFAULT 'No description available.',
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id)
        REFERENCES categories (category_id),
    UNIQUE KEY unique_category_per_parent (category_name , parent_category_id)
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
	category_id INT NOT NULL,  
    p_name VARCHAR(255) NOT NULL,
    description TEXT,
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
    price DECIMAL(10 , 2 ) NOT NULL,
    stock_quantity INT DEFAULT 0,
    v_status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',  
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
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
 );
 
 /*
CREATE TABLE IF NOT EXISTS orders (
	user_id INT AUTO_INCREMENT PRIMARY KEY,

 );
 
CREATE TABLE IF NOT EXISTS order_items (
	user_id INT AUTO_INCREMENT PRIMARY KEY,

 );
 
CREATE TABLE IF NOT EXISTS payments (
	user_id INT AUTO_INCREMENT PRIMARY KEY,

 );
 
CREATE TABLE IF NOT EXISTS reviews (
	user_id INT AUTO_INCREMENT PRIMARY KEY,

 );
 */