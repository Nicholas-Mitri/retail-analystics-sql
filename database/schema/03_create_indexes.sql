-- =====================================================
-- DROP TABLE INDEXES
-- =====================================================

DROP INDEX idx_users_customer_type ON users;
DROP INDEX idx_vendors_status ON vendors;
DROP INDEX idx_categories_parent ON categories;
DROP INDEX idx_products_vendor ON products;
DROP INDEX idx_products_category ON products;
DROP INDEX idx_products_status ON products;
DROP INDEX idx_products_vendor_category ON products;
DROP INDEX idx_variants_product ON product_variants;
DROP INDEX idx_variants_stock ON product_variants;
DROP INDEX idx_variants_product_status ON product_variants;
DROP INDEX idx_addresses_user ON addresses;
DROP INDEX idx_addresses_user_default ON addresses;
DROP INDEX idx_addresses_user_type ON addresses;
DROP INDEX idx_orders_user_date ON orders;
DROP INDEX idx_orders_status ON orders;
DROP INDEX idx_orders_date ON orders;
DROP INDEX idx_orders_status_date ON orders;
DROP INDEX idx_orders_address ON orders;
DROP INDEX idx_order_items_order ON order_items;
DROP INDEX idx_order_items_variant ON order_items;
DROP INDEX idx_order_items_variant_order ON order_items;
DROP INDEX idx_payments_status ON payments;
DROP INDEX idx_payments_status_processed ON payments;
DROP INDEX idx_payments_method ON payments;
DROP INDEX idx_rfm_chain ON orders;
DROP INDEX idx_product_sales ON order_items;
DROP INDEX idx_vendor_commission ON orders;

-- =====================================================
-- USERS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_users_customer_type ON users(customer_type);

-- =====================================================
-- VENDORS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_vendors_status ON vendors(v_status);

-- =====================================================
-- CATEGORIES TABLE INDEXES
-- =====================================================

CREATE INDEX idx_categories_parent ON categories(parent_category_id);

-- =====================================================
-- PRODUCTS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(p_status);
CREATE INDEX idx_products_vendor_category ON products(vendor_id, category_id, p_status);

-- =====================================================
-- PRODUCT_VARIANTS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_variants_product ON product_variants(product_id);
CREATE INDEX idx_variants_stock ON product_variants(stock_quantity);
CREATE INDEX idx_variants_product_status ON product_variants(product_id, pv_status);

-- =====================================================
-- ADDRESSES TABLE INDEXES
-- =====================================================

CREATE INDEX idx_addresses_user ON addresses(user_id);
CREATE INDEX idx_addresses_user_default ON addresses(user_id, is_default);
CREATE INDEX idx_addresses_user_type ON addresses(user_id, type);

-- =====================================================
-- ORDERS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
CREATE INDEX idx_orders_status ON orders(o_status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status_date ON orders(o_status, order_date);
CREATE INDEX idx_orders_address ON orders(address_id);

-- =====================================================
-- ORDER_ITEMS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_variant ON order_items(variant_id);
CREATE INDEX idx_order_items_variant_order ON order_items(variant_id, order_id);

-- =====================================================
-- PAYMENTS TABLE INDEXES
-- =====================================================

CREATE INDEX idx_payments_status ON payments(pay_status);
CREATE INDEX idx_payments_status_processed ON payments(pay_status, processed_at);
CREATE INDEX idx_payments_method ON payments(payment_method);

-- =====================================================
-- COMPOSITE INDEXES FOR COMPLEX QUERIES
-- =====================================================

CREATE INDEX idx_rfm_chain ON orders(user_id, order_date, o_status);
CREATE INDEX idx_product_sales ON order_items(variant_id, order_id);
CREATE INDEX idx_vendor_commission ON orders(order_date, o_status);
