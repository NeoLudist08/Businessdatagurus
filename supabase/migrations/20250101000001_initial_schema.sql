-- Business Data Gurus - Initial Database Schema
-- This migration creates the core tables for the business

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CUSTOMERS TABLE
-- Stores all customer/lead information
-- =====================================================
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    company VARCHAR(255),
    role VARCHAR(100),
    phone VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    source VARCHAR(100), -- 'lead_magnet', 'contact_form', 'direct', etc.
    status VARCHAR(50) DEFAULT 'lead', -- 'lead', 'prospect', 'customer', 'inactive'
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb -- For flexible additional data
);

-- =====================================================
-- SERVICE PACKAGES TABLE
-- Defines available service packages
-- =====================================================
CREATE TABLE service_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    tagline VARCHAR(500),
    price_min DECIMAL(10,2),
    price_max DECIMAL(10,2),
    price_type VARCHAR(50), -- 'one-time', 'hourly', 'monthly', 'custom'
    category VARCHAR(100), -- 'development', 'clean_sweep', 'consulting'
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- ORDERS TABLE
-- Tracks one-time purchases and service orders
-- =====================================================
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    package_id UUID REFERENCES service_packages(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'paid', 'in_progress', 'completed', 'cancelled'
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    payment_method VARCHAR(50), -- 'crypto', 'wire', 'paypal', etc.
    payment_status VARCHAR(50) DEFAULT 'unpaid', -- 'unpaid', 'paid', 'refunded'
    transaction_id VARCHAR(255),
    project_details TEXT,
    timeline VARCHAR(100), -- 'asap', '1-month', '3-months', etc.
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- SUBSCRIPTIONS TABLE
-- Tracks recurring subscriptions (mainly for Clean Sweep)
-- =====================================================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    package_id UUID REFERENCES service_packages(id),
    subscription_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'paused', 'cancelled', 'expired'
    plan_type VARCHAR(100), -- 'essential', 'pro', 'enterprise'
    billing_cycle VARCHAR(50) DEFAULT 'monthly', -- 'monthly', 'yearly'
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    site_count INTEGER DEFAULT 1, -- Number of sites covered
    payment_method VARCHAR(50),
    next_billing_date DATE,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- CLEAN SWEEP LICENSES TABLE
-- Tracks individual Clean Sweep licenses and deployments
-- =====================================================
CREATE TABLE clean_sweep_licenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    license_key VARCHAR(255) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    license_type VARCHAR(50), -- 'individual', 'business', 'enterprise'
    seats INTEGER DEFAULT 1, -- Number of seats/users
    seats_used INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'suspended', 'expired', 'revoked'
    expires_at TIMESTAMPTZ,
    activated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb -- Can store device IDs, activation info, etc.
);

-- =====================================================
-- LEADS TABLE
-- Captures lead magnet submissions and contact form entries
-- =====================================================
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    company VARCHAR(255),
    role VARCHAR(100),
    phone VARCHAR(50),
    interested_in VARCHAR(255), -- Package or service they're interested in
    timeline VARCHAR(100),
    message TEXT,
    source VARCHAR(100), -- 'lead_magnet', 'contact_form', 'floating_cta', etc.
    status VARCHAR(50) DEFAULT 'new', -- 'new', 'contacted', 'qualified', 'converted', 'lost'
    converted_to_customer BOOLEAN DEFAULT FALSE,
    followed_up_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- TESTIMONIALS TABLE
-- Stores client testimonials and reviews
-- =====================================================
CREATE TABLE testimonials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    author_name VARCHAR(255) NOT NULL,
    author_title VARCHAR(255),
    author_company VARCHAR(255),
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    is_featured BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- ANALYTICS EVENTS TABLE
-- Tracks user interactions and conversions
-- =====================================================
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_name VARCHAR(255) NOT NULL,
    event_category VARCHAR(100),
    event_label VARCHAR(255),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    session_id VARCHAR(255),
    page_url TEXT,
    user_agent TEXT,
    ip_address INET,
    referrer TEXT,
    event_value VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- CRYPTO PAYMENTS TABLE
-- Tracks cryptocurrency payments
-- =====================================================
CREATE TABLE crypto_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    wallet_address VARCHAR(255) NOT NULL,
    crypto_currency VARCHAR(50), -- 'BTC', 'ETH', etc.
    amount_crypto DECIMAL(20,8),
    amount_usd DECIMAL(10,2),
    transaction_hash VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'confirmed', 'failed'
    confirmations INTEGER DEFAULT 0,
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- INDEXES for performance
-- =====================================================

-- Customers indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_customers_created_at ON customers(created_at DESC);

-- Orders indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- Subscriptions indexes
CREATE INDEX idx_subscriptions_customer_id ON subscriptions(customer_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_next_billing ON subscriptions(next_billing_date);

-- Licenses indexes
CREATE INDEX idx_licenses_customer_id ON clean_sweep_licenses(customer_id);
CREATE INDEX idx_licenses_license_key ON clean_sweep_licenses(license_key);
CREATE INDEX idx_licenses_status ON clean_sweep_licenses(status);

-- Leads indexes
CREATE INDEX idx_leads_customer_id ON leads(customer_id);
CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);

-- Analytics indexes
CREATE INDEX idx_analytics_event_name ON analytics_events(event_name);
CREATE INDEX idx_analytics_customer_id ON analytics_events(customer_id);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at DESC);

-- =====================================================
-- UPDATED_AT TRIGGER FUNCTION
-- Automatically updates the updated_at timestamp
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all relevant tables
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_packages_updated_at BEFORE UPDATE ON service_packages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_licenses_updated_at BEFORE UPDATE ON clean_sweep_licenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_testimonials_updated_at BEFORE UPDATE ON testimonials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_crypto_payments_updated_at BEFORE UPDATE ON crypto_payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
