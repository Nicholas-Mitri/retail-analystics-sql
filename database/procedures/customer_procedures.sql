-- =========================================================
-- Production Customer Procedures
-- =========================================================

-- Drops
DROP PROCEDURE IF EXISTS sp_register_customer;
DROP PROCEDURE IF EXISTS sp_get_customer_profile;
DROP PROCEDURE IF EXISTS sp_update_customer_preferences;

DELIMITER //

-- =========================================================
-- sp_register_customer
-- Registers a new customer in the users table and associates their address.
-- Inputs:
--   p_email, p_password, p_first_name, p_last_name, p_phone
--   p_address_line, p_type, p_city, p_state, p_postal_code, p_country, is_default
-- Output:
--   None. Inserts new user and address.
-- =========================================================
CREATE PROCEDURE sp_register_customer(
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_phone VARCHAR(20),
    IN p_address_line VARCHAR(255),
    IN p_type ENUM('shipping', 'billing'),
    IN p_city VARCHAR(100),
    IN p_state VARCHAR(100),
    IN p_postal_code VARCHAR(20),
    IN p_country VARCHAR(100),
    IN is_default BOOL
)
BEGIN
    DECLARE v_user_id INT;

    -- Insert new customer into users table
    INSERT INTO users (
        email, user_password, first_name, last_name, phone, customer_type, created_at
    ) VALUES (
        p_email,
        p_password,
        p_first_name,
        p_last_name,
        p_phone,
        'customer',
        NOW()
    );

    SET v_user_id = LAST_INSERT_ID();

    -- Insert associated address for the customer (production: field name street_address)
    INSERT INTO addresses (
        user_id, street_address, type, city, state, postal_code, country, is_default
    ) VALUES (
        v_user_id,
        p_address_line,
        p_type,
        p_city,
        p_state,
        p_postal_code,
        p_country,
        is_default
    );

END //

-- =========================================================
-- sp_get_customer_profile
-- Retrieves the customer profile, including user info and associated addresses.
-- Input:
--   p_user_id - customer's user_id
-- Output:
--   Full customer profile (user and address info)
-- =========================================================
CREATE PROCEDURE sp_get_customer_profile(
    IN p_user_id INT
)
BEGIN
    SELECT
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        u.phone,
        u.customer_type,
        u.created_at,
        ca.address_id,
        ca.type,
        ca.street_address,
        ca.city,
        ca.state,
        ca.postal_code,
        ca.country,
        ca.is_default
    FROM users u
    LEFT JOIN addresses ca ON u.user_id = ca.user_id
    WHERE u.user_id = p_user_id
      AND u.customer_type = 'customer';
END //

-- =========================================================
-- sp_update_customer_preferences
-- Updates profile info for an existing customer.
-- Inputs are optional (NULL will keep column unchanged).
-- Input:
--   p_user_id, p_email, p_password, p_first_name, p_last_name, p_phone
-- Output:
--   None (update in-place)
-- =========================================================
CREATE PROCEDURE sp_update_customer_preferences(
    IN p_user_id INT,
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_phone VARCHAR(20)
)
BEGIN
    -- Only update fields provided (non-NULL)
    UPDATE users
    SET
        email = COALESCE(p_email, email),
        user_password = COALESCE(p_password, user_password),
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        phone = COALESCE(p_phone, phone)
    WHERE user_id = p_user_id;
END //

DELIMITER ;
