-- =====================================================
-- DATABASE CREATION SCRIPT
-- Filename: 01_create_database.sql
-- Purpose:  Initializes the retail_analytics database with
--           default character set and collation.
--           Run this script before any table or schema creation.
-- =====================================================

CREATE DATABASE IF NOT EXISTS retail_analytics;

USE retail_analytics;

-- set the appropriate character set for this database
ALTER DATABASE retail_analytics
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
