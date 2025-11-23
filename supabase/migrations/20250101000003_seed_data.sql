-- Business Data Gurus - Seed Data
-- This migration populates initial service packages and testimonials

-- =====================================================
-- SERVICE PACKAGES - Development Services
-- =====================================================

INSERT INTO service_packages (name, slug, description, tagline, price_min, price_max, price_type, category, features, display_order) VALUES
(
    'AI Rescue',
    'ai-rescue',
    'Backend Integration, Production Deployment, Bug Fixing & Optimization',
    'They Built It With AI, Now Make It Work!',
    2500.00,
    5000.00,
    'one-time',
    'development',
    '[
        "Backend Integration (APIs, databases, authentication)",
        "Production Deployment (AWS, hosting, security)",
        "Bug Fixing & Optimization",
        "Data Connections to real business systems",
        "30-day support period included"
    ]'::jsonb,
    1
),
(
    'Complete Build',
    'complete-build',
    'Full-Stack Application Development with Business Intelligence',
    'From Concept to Cash Flow',
    10000.00,
    35000.00,
    'one-time',
    'development',
    '[
        "Full-Stack Application Development",
        "Business Intelligence Dashboard",
        "E-commerce Integration (payment, inventory, CRM)",
        "Mobile-Responsive Design",
        "Staff Training Program",
        "90-day training & support"
    ]'::jsonb,
    2
),
(
    'Business Empire',
    'business-empire',
    'Complete Digital Business Model + Operations',
    'Complete Digital Business Model + Operations',
    40000.00,
    100000.00,
    'one-time',
    'development',
    '[
        "Enterprise-Level Application Suite",
        "AI-Powered Business Intelligence",
        "Multi-Platform Presence",
        "Marketing Automation Integration",
        "Scalable Cloud Infrastructure",
        "Business Model Optimization",
        "6-month strategic partnership"
    ]'::jsonb,
    3
),
(
    'Hourly Consulting',
    'hourly-consulting',
    'Perfect for smaller projects or ongoing support',
    'Perfect for smaller projects or ongoing support',
    75.00,
    125.00,
    'hourly',
    'consulting',
    '[
        "Code Reviews & Debugging",
        "Technical Consulting",
        "Business Strategy Sessions",
        "Training & Workshops",
        "Emergency Support"
    ]'::jsonb,
    4
);

-- =====================================================
-- SERVICE PACKAGES - Clean Sweep Plans
-- =====================================================

INSERT INTO service_packages (name, slug, description, tagline, price_min, price_max, price_type, category, features, display_order, metadata) VALUES
(
    'Clean Sweep Essential',
    'clean-sweep-essential',
    'Perfect for small businesses',
    'Portal booster + desktop cleaner for small teams',
    99.00,
    99.00,
    'monthly',
    'clean_sweep',
    '[
        "Portal booster + desktop cleaner",
        "Basic system optimization",
        "Browser config fixes",
        "Email support",
        "Works on Windows/macOS/Chromebook"
    ]'::jsonb,
    5,
    '{"setup_fee": 149, "billing_cycle": "monthly"}'::jsonb
),
(
    'Clean Sweep Pro',
    'clean-sweep-pro',
    'For growing organizations',
    'Everything in Essential plus automated reporting and security',
    199.00,
    199.00,
    'monthly',
    'clean_sweep',
    '[
        "Everything in Essential",
        "Automated log reporting",
        "Email alerts for issues",
        "Pre-login security scans",
        "Performance analytics",
        "Priority support"
    ]'::jsonb,
    6,
    '{"billing_cycle": "monthly", "roi_savings": 3200, "special_offer": "Next 5 customers get 3 months at Essential pricing"}'::jsonb
),
(
    'Clean Sweep Enterprise',
    'clean-sweep-enterprise',
    'For large organizations',
    'Custom enterprise solution with SLA and white-label options',
    NULL,
    NULL,
    'custom',
    'clean_sweep',
    '[
        "Everything in Pro",
        "SLA guarantees",
        "Remote deployment tools",
        "White-label branding",
        "Custom data sync",
        "24/7 enterprise support",
        "Bulk pricing for districts"
    ]'::jsonb,
    7,
    '{"billing_cycle": "custom", "requires_demo": true}'::jsonb
),
(
    'Clean Sweep Individual',
    'clean-sweep-individual',
    'Basic cleanup + optimization for individual use',
    'One-time license for personal device optimization',
    60.00,
    60.00,
    'one-time',
    'clean_sweep',
    '[
        "Basic cleanup + optimization",
        "Email license delivery",
        "Driver & update checks"
    ]'::jsonb,
    8,
    '{"license_type": "individual", "seats": 1}'::jsonb
),
(
    'Clean Sweep Small Business Pack',
    'clean-sweep-business-pack',
    '10-user license pack for small businesses',
    'One-time pack for small business teams',
    1000.00,
    1000.00,
    'one-time',
    'clean_sweep',
    '[
        "10-user license pack",
        "Remote deployment",
        "Basic reporting"
    ]'::jsonb,
    9,
    '{"license_type": "business", "seats": 10}'::jsonb
);

-- =====================================================
-- SAMPLE TESTIMONIALS
-- =====================================================

INSERT INTO testimonials (author_name, author_title, author_company, content, rating, is_featured, is_approved, display_order) VALUES
(
    'Sarah Chen',
    'IT Director',
    'Metro Utilities',
    'Clean Sweep reduced our help desk tickets by 45% in the first month. Our field technicians can now focus on real problems instead of basic system issues.',
    5,
    TRUE,
    TRUE,
    1
),
(
    'Mike Rodriguez',
    'Technology Coordinator',
    'Valley School District',
    'The portal booster alone saved us thousands in lost productivity. Parents can actually access the school dashboard now without calling IT.',
    5,
    TRUE,
    TRUE,
    2
),
(
    'Jennifer Walsh',
    'Operations Manager',
    'Regional Retail Chain',
    'Business Data Gurus delivered our inventory system 2 weeks early and under budget. Finally, developers who understand retail operations.',
    5,
    TRUE,
    TRUE,
    3
);

-- =====================================================
-- SAMPLE ANALYTICS EVENTS (for demonstration)
-- =====================================================

-- You can insert sample events or leave this empty
-- INSERT INTO analytics_events (event_name, event_category, event_label, page_url) VALUES
-- ('page_view', 'navigation', 'home', '/'),
-- ('button_click', 'engagement', 'explore_services', '/');
