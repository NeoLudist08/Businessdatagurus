-- Business Data Gurus - Database Functions
-- Useful functions for common operations

-- =====================================================
-- FUNCTION: Generate Order Number
-- Generates unique order numbers in format: ORD-YYYYMMDD-XXXX
-- =====================================================
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    new_number VARCHAR(50);
    counter INTEGER;
BEGIN
    -- Get count of orders created today
    SELECT COUNT(*) + 1 INTO counter
    FROM orders
    WHERE DATE(created_at) = CURRENT_DATE;

    -- Format: ORD-20250101-0001
    new_number := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(counter::TEXT, 4, '0');

    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Generate Subscription Number
-- Generates unique subscription numbers in format: SUB-YYYYMMDD-XXXX
-- =====================================================
CREATE OR REPLACE FUNCTION generate_subscription_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    new_number VARCHAR(50);
    counter INTEGER;
BEGIN
    -- Get count of subscriptions created today
    SELECT COUNT(*) + 1 INTO counter
    FROM subscriptions
    WHERE DATE(created_at) = CURRENT_DATE;

    -- Format: SUB-20250101-0001
    new_number := 'SUB-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(counter::TEXT, 4, '0');

    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Generate License Key
-- Generates unique license keys for Clean Sweep
-- Format: CS-XXXX-XXXX-XXXX-XXXX
-- =====================================================
CREATE OR REPLACE FUNCTION generate_license_key()
RETURNS VARCHAR(255) AS $$
DECLARE
    new_key VARCHAR(255);
    key_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate random license key
        new_key := 'CS-' ||
                   UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4)) || '-' ||
                   UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4)) || '-' ||
                   UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4)) || '-' ||
                   UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4));

        -- Check if key already exists
        SELECT EXISTS(SELECT 1 FROM clean_sweep_licenses WHERE license_key = new_key) INTO key_exists;

        -- Exit loop if key is unique
        EXIT WHEN NOT key_exists;
    END LOOP;

    RETURN new_key;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Auto-generate order number on insert
-- =====================================================
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := generate_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_order_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION set_order_number();

-- =====================================================
-- FUNCTION: Auto-generate subscription number on insert
-- =====================================================
CREATE OR REPLACE FUNCTION set_subscription_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_number IS NULL THEN
        NEW.subscription_number := generate_subscription_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_subscription_number
    BEFORE INSERT ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION set_subscription_number();

-- =====================================================
-- FUNCTION: Auto-generate license key on insert
-- =====================================================
CREATE OR REPLACE FUNCTION set_license_key()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.license_key IS NULL THEN
        NEW.license_key := generate_license_key();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_license_key
    BEFORE INSERT ON clean_sweep_licenses
    FOR EACH ROW
    EXECUTE FUNCTION set_license_key();

-- =====================================================
-- FUNCTION: Convert Lead to Customer
-- Converts a lead into a customer record
-- =====================================================
CREATE OR REPLACE FUNCTION convert_lead_to_customer(lead_id UUID)
RETURNS UUID AS $$
DECLARE
    customer_id UUID;
    lead_record RECORD;
BEGIN
    -- Get lead details
    SELECT * INTO lead_record FROM leads WHERE id = lead_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lead not found';
    END IF;

    -- Check if customer already exists with this email
    SELECT id INTO customer_id FROM customers WHERE email = lead_record.email;

    IF customer_id IS NULL THEN
        -- Create new customer
        INSERT INTO customers (email, name, company, role, phone, source, status)
        VALUES (lead_record.email, lead_record.name, lead_record.company, lead_record.role, lead_record.phone, 'converted_lead', 'customer')
        RETURNING id INTO customer_id;
    END IF;

    -- Update lead to mark as converted
    UPDATE leads
    SET
        status = 'converted',
        converted_to_customer = TRUE,
        customer_id = customer_id
    WHERE id = lead_id;

    RETURN customer_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Get Customer Lifetime Value
-- Calculates total revenue from a customer
-- =====================================================
CREATE OR REPLACE FUNCTION get_customer_lifetime_value(cust_id UUID)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total_value DECIMAL(10,2);
BEGIN
    SELECT
        COALESCE(SUM(o.amount), 0) +
        COALESCE((SELECT SUM(s.amount) FROM subscriptions s WHERE s.customer_id = cust_id AND s.status = 'active'), 0)
    INTO total_value
    FROM orders o
    WHERE o.customer_id = cust_id AND o.payment_status = 'paid';

    RETURN total_value;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Check License Availability
-- Checks if a license has available seats
-- =====================================================
CREATE OR REPLACE FUNCTION check_license_availability(lic_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    license_record RECORD;
BEGIN
    SELECT seats, seats_used INTO license_record
    FROM clean_sweep_licenses
    WHERE id = lic_id AND status = 'active';

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    RETURN license_record.seats_used < license_record.seats;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Increment License Seat Usage
-- Increments the seats_used counter for a license
-- =====================================================
CREATE OR REPLACE FUNCTION increment_license_usage(lic_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    available BOOLEAN;
BEGIN
    -- Check if seats are available
    SELECT check_license_availability(lic_id) INTO available;

    IF NOT available THEN
        RAISE EXCEPTION 'No available seats for this license';
    END IF;

    -- Increment usage
    UPDATE clean_sweep_licenses
    SET seats_used = seats_used + 1
    WHERE id = lic_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Get Monthly Recurring Revenue (MRR)
-- Calculates current MRR from active subscriptions
-- =====================================================
CREATE OR REPLACE FUNCTION get_monthly_recurring_revenue()
RETURNS DECIMAL(10,2) AS $$
DECLARE
    mrr DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO mrr
    FROM subscriptions
    WHERE status = 'active' AND billing_cycle = 'monthly';

    RETURN mrr;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTION: Get Active Subscriptions Count
-- Returns count of active subscriptions by plan type
-- =====================================================
CREATE OR REPLACE FUNCTION get_active_subscriptions_by_plan()
RETURNS TABLE(plan_type VARCHAR, count BIGINT, total_revenue DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.plan_type,
        COUNT(*)::BIGINT,
        SUM(s.amount)::DECIMAL(10,2)
    FROM subscriptions s
    WHERE s.status = 'active'
    GROUP BY s.plan_type
    ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEW: Dashboard Metrics
-- Provides key metrics for business dashboard
-- =====================================================
CREATE OR REPLACE VIEW dashboard_metrics AS
SELECT
    (SELECT COUNT(*) FROM customers WHERE status = 'customer') as total_customers,
    (SELECT COUNT(*) FROM leads WHERE status = 'new') as new_leads,
    (SELECT COUNT(*) FROM orders WHERE status = 'in_progress') as active_orders,
    (SELECT COUNT(*) FROM subscriptions WHERE status = 'active') as active_subscriptions,
    (SELECT get_monthly_recurring_revenue()) as monthly_recurring_revenue,
    (SELECT SUM(amount) FROM orders WHERE payment_status = 'paid' AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)) as current_month_revenue,
    (SELECT COUNT(*) FROM clean_sweep_licenses WHERE status = 'active') as active_licenses;
