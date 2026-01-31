-- ============================================
-- SQL FOR QA TESTING - Database Schema
-- ============================================
-- Purpose: E-commerce database for QA validation
-- Design: 4 tables with clear relationships
-- Focus: Simple structure, obvious relationships
-- ============================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- Users Table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active'
);

-- Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_total DECIMAL(10, 2) NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('pending', 'completed', 'cancelled', 'refunded') DEFAULT 'pending',
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Table 4: Order Items (Order Details/Line Items)
CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) NOT NULL,
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================
-- Relationships Summary:
-- ============================================
-- users (1) ──→ orders (N)        : One user, many orders
-- orders (1) ──→ order_items (N)  : One order, many items  
-- products (1) ──→ order_items (N): One product in many orders
-- ============================================