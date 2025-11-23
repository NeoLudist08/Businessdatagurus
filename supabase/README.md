# Business Data Gurus - Supabase Database Schema

This directory contains the complete database schema for the Business Data Gurus platform, including development services management and Clean Sweep product licensing.

## 📋 Table of Contents

- [Overview](#overview)
- [Database Tables](#database-tables)
- [Setup Instructions](#setup-instructions)
- [Migrations](#migrations)
- [Security & RLS](#security--rls)
- [API Examples](#api-examples)
- [Functions & Triggers](#functions--triggers)

## 🎯 Overview

The database schema supports:

1. **Development Services**: AI Rescue, Complete Build, Business Empire packages
2. **Clean Sweep Product**: Multiple subscription tiers and licensing
3. **Customer Management**: Lead tracking, conversion, and lifetime value
4. **Order & Subscription Management**: One-time purchases and recurring billing
5. **Analytics**: Event tracking and conversion monitoring
6. **Crypto Payments**: Bitcoin/Ethereum payment tracking

## 📊 Database Tables

### Core Tables

#### `customers`
Stores all customer and lead information.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | VARCHAR(255) | Unique email address |
| name | VARCHAR(255) | Customer name |
| company | VARCHAR(255) | Company/organization |
| role | VARCHAR(100) | Job role/title |
| phone | VARCHAR(50) | Phone number |
| status | VARCHAR(50) | `lead`, `prospect`, `customer`, `inactive` |
| source | VARCHAR(100) | How they found you |
| metadata | JSONB | Flexible additional data |

#### `service_packages`
Available service offerings and pricing tiers.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(255) | Package name |
| slug | VARCHAR(255) | URL-friendly identifier |
| price_min | DECIMAL(10,2) | Minimum price |
| price_max | DECIMAL(10,2) | Maximum price |
| price_type | VARCHAR(50) | `one-time`, `hourly`, `monthly`, `custom` |
| category | VARCHAR(100) | `development`, `clean_sweep`, `consulting` |
| features | JSONB | Array of features |

#### `orders`
One-time purchases and project orders.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| customer_id | UUID | Foreign key to customers |
| package_id | UUID | Foreign key to service_packages |
| order_number | VARCHAR(50) | Auto-generated (ORD-YYYYMMDD-XXXX) |
| status | VARCHAR(50) | `pending`, `paid`, `in_progress`, `completed`, `cancelled` |
| amount | DECIMAL(10,2) | Order amount |
| payment_status | VARCHAR(50) | `unpaid`, `paid`, `refunded` |
| timeline | VARCHAR(100) | Expected timeline |

#### `subscriptions`
Recurring subscription management (mainly for Clean Sweep).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| customer_id | UUID | Foreign key to customers |
| subscription_number | VARCHAR(50) | Auto-generated (SUB-YYYYMMDD-XXXX) |
| status | VARCHAR(50) | `active`, `paused`, `cancelled`, `expired` |
| plan_type | VARCHAR(100) | `essential`, `pro`, `enterprise` |
| billing_cycle | VARCHAR(50) | `monthly`, `yearly` |
| amount | DECIMAL(10,2) | Subscription amount |
| next_billing_date | DATE | Next billing date |
| site_count | INTEGER | Number of sites covered |

#### `clean_sweep_licenses`
License key management for Clean Sweep product.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| license_key | VARCHAR(255) | Auto-generated unique key (CS-XXXX-XXXX-XXXX-XXXX) |
| customer_id | UUID | Foreign key to customers |
| license_type | VARCHAR(50) | `individual`, `business`, `enterprise` |
| seats | INTEGER | Total available seats |
| seats_used | INTEGER | Currently used seats |
| status | VARCHAR(50) | `active`, `suspended`, `expired`, `revoked` |
| expires_at | TIMESTAMPTZ | Expiration date (if applicable) |

#### `leads`
Lead capture from contact forms and lead magnets.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| customer_id | UUID | Foreign key (set when converted) |
| email | VARCHAR(255) | Lead email |
| interested_in | VARCHAR(255) | Package/service of interest |
| source | VARCHAR(100) | `lead_magnet`, `contact_form`, `floating_cta` |
| status | VARCHAR(50) | `new`, `contacted`, `qualified`, `converted`, `lost` |
| converted_to_customer | BOOLEAN | Whether lead was converted |

#### `testimonials`
Client testimonials and reviews.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| author_name | VARCHAR(255) | Testimonial author |
| author_title | VARCHAR(255) | Job title |
| author_company | VARCHAR(255) | Company name |
| content | TEXT | Testimonial content |
| rating | INTEGER | 1-5 star rating |
| is_approved | BOOLEAN | Whether approved for display |
| is_featured | BOOLEAN | Whether featured prominently |

#### `analytics_events`
Tracks user interactions and conversions.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| event_name | VARCHAR(255) | Event name (e.g., `button_click`) |
| event_category | VARCHAR(100) | Category (e.g., `engagement`) |
| event_label | VARCHAR(255) | Label (e.g., package name) |
| session_id | VARCHAR(255) | Session identifier |
| metadata | JSONB | Additional event data |

#### `crypto_payments`
Cryptocurrency payment tracking.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| order_id | UUID | Foreign key to orders |
| wallet_address | VARCHAR(255) | Payment wallet address |
| crypto_currency | VARCHAR(50) | `BTC`, `ETH`, etc. |
| transaction_hash | VARCHAR(255) | Blockchain transaction hash |
| status | VARCHAR(50) | `pending`, `confirmed`, `failed` |
| confirmations | INTEGER | Number of confirmations |

## 🚀 Setup Instructions

### 1. Install Supabase CLI

```bash
npm install -g supabase
```

### 2. Initialize Supabase Project

```bash
# Login to Supabase
supabase login

# Link to your project (or create new one)
supabase link --project-ref your-project-ref
```

### 3. Run Migrations

```bash
# Run all migrations
supabase db push

# Or run individually
supabase db push --file supabase/migrations/20250101000001_initial_schema.sql
supabase db push --file supabase/migrations/20250101000002_rls_policies.sql
supabase db push --file supabase/migrations/20250101000003_seed_data.sql
supabase db push --file supabase/migrations/20250101000004_functions.sql
```

## 📁 Migrations

All migrations are located in `supabase/migrations/`:

1. **20250101000001_initial_schema.sql** - Core database tables and indexes
2. **20250101000002_rls_policies.sql** - Row Level Security policies
3. **20250101000003_seed_data.sql** - Initial service packages and testimonials
4. **20250101000004_functions.sql** - Database functions and triggers

## 🔒 Security & RLS

Row Level Security (RLS) is enabled on all tables with the following policies:

### Public Access
- ✅ View active service packages
- ✅ View approved testimonials
- ✅ Submit leads (contact forms)
- ✅ Submit analytics events

### Authenticated Users
- ✅ View own orders, subscriptions, licenses
- ✅ View own customer record

### Admin Only
- ✅ Manage all customers, orders, subscriptions
- ✅ Manage service packages
- ✅ View and manage all leads
- ✅ View analytics data
- ✅ Approve testimonials

## 📝 API Examples

### JavaScript/TypeScript (using Supabase client)

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

// Get active service packages
const { data: packages } = await supabase
  .from('service_packages')
  .select('*')
  .eq('is_active', true)
  .order('display_order')

// Submit a lead from contact form
const { data, error } = await supabase
  .from('leads')
  .insert({
    email: 'customer@example.com',
    name: 'John Doe',
    company: 'Acme Corp',
    interested_in: 'clean-sweep-pro',
    source: 'contact_form',
    message: 'Interested in Clean Sweep Pro for our organization'
  })

// Get approved testimonials
const { data: testimonials } = await supabase
  .from('testimonials')
  .select('*')
  .eq('is_approved', true)
  .order('display_order')

// Track analytics event
await supabase
  .from('analytics_events')
  .insert({
    event_name: 'button_click',
    event_category: 'engagement',
    event_label: 'clean_sweep_essential',
    page_url: window.location.href
  })

// Create an order
const { data: order } = await supabase
  .from('orders')
  .insert({
    customer_id: customerId,
    package_id: packageId,
    amount: 2500.00,
    timeline: '1-month',
    project_details: 'Need AI project rescue for broken chatbot'
  })
  .select()
  .single()

// Create a subscription
const { data: subscription } = await supabase
  .from('subscriptions')
  .insert({
    customer_id: customerId,
    package_id: packageId,
    plan_type: 'pro',
    amount: 199.00,
    site_count: 3,
    next_billing_date: '2025-02-01'
  })
  .select()
  .single()
```

## 🔧 Functions & Triggers

### Auto-Generated Values

The following values are automatically generated:

- **Order Numbers**: `ORD-YYYYMMDD-XXXX`
- **Subscription Numbers**: `SUB-YYYYMMDD-XXXX`
- **License Keys**: `CS-XXXX-XXXX-XXXX-XXXX`

### Utility Functions

```sql
-- Convert lead to customer
SELECT convert_lead_to_customer('lead-uuid-here');

-- Get customer lifetime value
SELECT get_customer_lifetime_value('customer-uuid-here');

-- Check license seat availability
SELECT check_license_availability('license-uuid-here');

-- Increment license usage
SELECT increment_license_usage('license-uuid-here');

-- Get monthly recurring revenue
SELECT get_monthly_recurring_revenue();

-- Get subscriptions by plan type
SELECT * FROM get_active_subscriptions_by_plan();

-- View dashboard metrics
SELECT * FROM dashboard_metrics;
```

### Available Triggers

1. **updated_at** - Automatically updates `updated_at` timestamp on all tables
2. **order_number** - Auto-generates order numbers on insert
3. **subscription_number** - Auto-generates subscription numbers on insert
4. **license_key** - Auto-generates unique license keys on insert

## 📊 Dashboard Metrics View

The `dashboard_metrics` view provides quick access to key business metrics:

```sql
SELECT * FROM dashboard_metrics;
```

Returns:
- Total customers
- New leads count
- Active orders count
- Active subscriptions count
- Monthly recurring revenue (MRR)
- Current month revenue
- Active licenses count

## 🔄 Common Workflows

### 1. Lead Capture → Customer Conversion

```javascript
// 1. Capture lead from contact form
const { data: lead } = await supabase
  .from('leads')
  .insert({ email, name, company, source: 'contact_form' })
  .select()
  .single()

// 2. Convert lead to customer (when qualified)
const { data: customerId } = await supabase
  .rpc('convert_lead_to_customer', { lead_id: lead.id })

// 3. Create order or subscription
const { data: order } = await supabase
  .from('orders')
  .insert({ customer_id: customerId, package_id, amount })
```

### 2. Clean Sweep License Creation

```javascript
// 1. Create subscription
const { data: subscription } = await supabase
  .from('subscriptions')
  .insert({
    customer_id,
    package_id,
    plan_type: 'pro',
    amount: 199.00
  })
  .select()
  .single()

// 2. Create license (license_key auto-generated)
const { data: license } = await supabase
  .from('clean_sweep_licenses')
  .insert({
    customer_id,
    subscription_id: subscription.id,
    license_type: 'business',
    seats: 10
  })
  .select()
  .single()

// 3. License key is automatically generated (e.g., CS-A1B2-C3D4-E5F6-G7H8)
console.log(license.license_key)
```

## 🔐 Environment Variables

Add these to your `.env` file:

```bash
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## 📈 Next Steps

1. **Connect to Frontend**: Integrate Supabase client in your website
2. **Email Integration**: Set up email notifications for new leads
3. **Payment Processing**: Integrate crypto payment verification
4. **Analytics Dashboard**: Build admin dashboard using `dashboard_metrics` view
5. **Automated Billing**: Set up cron jobs for subscription billing

## 🛠️ Development

### Reset Database (Caution!)

```bash
supabase db reset
```

### Generate TypeScript Types

```bash
supabase gen types typescript --local > types/database.types.ts
```

## 📞 Support

For questions or issues with the database schema, contact:
- Email: businessdatagurus@gmail.com
- Website: https://businessdatagurus.com

---

Built with ❤️ by Business Data Gurus
