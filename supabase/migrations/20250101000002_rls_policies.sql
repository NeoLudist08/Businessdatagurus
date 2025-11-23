-- Business Data Gurus - Row Level Security Policies
-- This migration sets up RLS policies for secure data access

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE clean_sweep_licenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE crypto_payments ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- SERVICE PACKAGES POLICIES
-- Public read access, admin only write
-- =====================================================

-- Anyone can view active service packages
CREATE POLICY "Service packages are viewable by everyone"
    ON service_packages FOR SELECT
    USING (is_active = TRUE);

-- Only authenticated admin users can insert/update/delete
CREATE POLICY "Service packages are manageable by admins"
    ON service_packages FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- TESTIMONIALS POLICIES
-- Public can view approved testimonials
-- =====================================================

-- Anyone can view approved testimonials
CREATE POLICY "Approved testimonials are viewable by everyone"
    ON testimonials FOR SELECT
    USING (is_approved = TRUE);

-- Admins can manage all testimonials
CREATE POLICY "Testimonials are manageable by admins"
    ON testimonials FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- CUSTOMERS POLICIES
-- Users can view their own data, admins can view all
-- =====================================================

-- Users can view their own customer record
CREATE POLICY "Customers can view own record"
    ON customers FOR SELECT
    USING (auth.uid()::text = (metadata->>'user_id') OR auth.jwt() ->> 'role' = 'admin');

-- Admins can manage all customers
CREATE POLICY "Admins can manage all customers"
    ON customers FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- ORDERS POLICIES
-- Users can view their own orders, admins can view all
-- =====================================================

-- Users can view their own orders
CREATE POLICY "Users can view own orders"
    ON orders FOR SELECT
    USING (
        customer_id IN (
            SELECT id FROM customers WHERE metadata->>'user_id' = auth.uid()::text
        ) OR auth.jwt() ->> 'role' = 'admin'
    );

-- Admins can manage all orders
CREATE POLICY "Admins can manage all orders"
    ON orders FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- SUBSCRIPTIONS POLICIES
-- Users can view their own subscriptions
-- =====================================================

-- Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions"
    ON subscriptions FOR SELECT
    USING (
        customer_id IN (
            SELECT id FROM customers WHERE metadata->>'user_id' = auth.uid()::text
        ) OR auth.jwt() ->> 'role' = 'admin'
    );

-- Admins can manage all subscriptions
CREATE POLICY "Admins can manage all subscriptions"
    ON subscriptions FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- CLEAN SWEEP LICENSES POLICIES
-- Users can view their own licenses
-- =====================================================

-- Users can view their own licenses
CREATE POLICY "Users can view own licenses"
    ON clean_sweep_licenses FOR SELECT
    USING (
        customer_id IN (
            SELECT id FROM customers WHERE metadata->>'user_id' = auth.uid()::text
        ) OR auth.jwt() ->> 'role' = 'admin'
    );

-- Admins can manage all licenses
CREATE POLICY "Admins can manage all licenses"
    ON clean_sweep_licenses FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- LEADS POLICIES
-- Only admins can access leads
-- =====================================================

CREATE POLICY "Admins can manage all leads"
    ON leads FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- ANALYTICS EVENTS POLICIES
-- Only admins can access analytics
-- =====================================================

CREATE POLICY "Admins can view all analytics"
    ON analytics_events FOR SELECT
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admins can manage analytics"
    ON analytics_events FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- CRYPTO PAYMENTS POLICIES
-- Users can view their own payments
-- =====================================================

-- Users can view their own crypto payments
CREATE POLICY "Users can view own crypto payments"
    ON crypto_payments FOR SELECT
    USING (
        customer_id IN (
            SELECT id FROM customers WHERE metadata->>'user_id' = auth.uid()::text
        ) OR auth.jwt() ->> 'role' = 'admin'
    );

-- Admins can manage all crypto payments
CREATE POLICY "Admins can manage all crypto payments"
    ON crypto_payments FOR ALL
    USING (auth.role() = 'authenticated' AND auth.jwt() ->> 'role' = 'admin');

-- =====================================================
-- PUBLIC ACCESS POLICIES
-- Allow anonymous users to submit leads and events
-- =====================================================

-- Allow anyone to insert leads (contact form submissions)
CREATE POLICY "Anyone can submit leads"
    ON leads FOR INSERT
    WITH CHECK (true);

-- Allow anyone to insert analytics events
CREATE POLICY "Anyone can submit analytics events"
    ON analytics_events FOR INSERT
    WITH CHECK (true);
