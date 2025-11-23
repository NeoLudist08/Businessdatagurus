# Business Data Gurus - Supabase Integration Guide

This guide will help you integrate the Supabase backend with your website.

## 🚀 Quick Start

### Step 1: Set Up Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to be provisioned (takes ~2 minutes)
3. Copy your project credentials:
   - Project URL
   - Anon/Public Key
   - Service Role Key (keep this secret!)

### Step 2: Configure Environment

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Fill in your Supabase credentials in `.env`:
   ```bash
   SUPABASE_URL=https://yourproject.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-key
   ```

### Step 3: Run Database Migrations

Install Supabase CLI if you haven't:
```bash
npm install -g supabase
```

Link to your project:
```bash
supabase login
supabase link --project-ref your-project-ref
```

Push all migrations:
```bash
supabase db push
```

Or use Supabase Dashboard:
1. Go to SQL Editor in your Supabase dashboard
2. Copy and paste each migration file content
3. Run them in order:
   - `20250101000001_initial_schema.sql`
   - `20250101000002_rls_policies.sql`
   - `20250101000003_seed_data.sql`
   - `20250101000004_functions.sql`

## 💻 Frontend Integration

### Option 1: Vanilla JavaScript (Current Website)

Add to your HTML `<head>`:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  // Initialize Supabase client
  const supabaseUrl = 'YOUR_SUPABASE_URL'
  const supabaseKey = 'YOUR_SUPABASE_ANON_KEY'
  const supabase = window.supabase.createClient(supabaseUrl, supabaseKey)
</script>
```

### Option 2: React/Next.js

Install the package:
```bash
npm install @supabase/supabase-js
```

Create a Supabase client (`lib/supabase.js`):
```javascript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

## 📝 Update Your Contact Forms

### Current Form (index.html lines 795-799)

Replace the Formspree form with Supabase integration:

```html
<!-- Lead Magnet Form -->
<form id="leadMagnetForm" style="display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;">
    <input type="email" id="leadEmail" name="email" placeholder="Your work email" required style="padding: 12px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2); background: rgba(255,255,255,0.05); color: white; flex: 1; min-width: 250px;" />
    <input type="text" id="leadCompany" name="company" placeholder="Company/Organization" required style="padding: 12px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2); background: rgba(255,255,255,0.05); color: white; flex: 1; min-width: 200px;" />
    <button type="submit" onclick="submitLeadMagnet(event)" style="padding: 12px 25px; background: linear-gradient(45deg, #4ecdc4, #00d2d3); color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; white-space: nowrap;">Get Free Assessment</button>
</form>

<script>
async function submitLeadMagnet(event) {
    event.preventDefault()

    const email = document.getElementById('leadEmail').value
    const company = document.getElementById('leadCompany').value

    // Track in analytics
    trackConversion('lead_magnet', 'free_assessment')

    // Submit to Supabase
    const { data, error } = await supabase
        .from('leads')
        .insert({
            email: email,
            company: company,
            source: 'lead_magnet',
            interested_in: 'free_assessment'
        })

    if (error) {
        alert('Error submitting form. Please try again.')
        console.error(error)
    } else {
        alert('Thanks! We\'ll send your free assessment soon.')
        document.getElementById('leadMagnetForm').reset()

        // Track successful submission
        await supabase.from('analytics_events').insert({
            event_name: 'lead_submitted',
            event_category: 'conversion',
            event_label: 'lead_magnet',
            metadata: { email, company }
        })
    }
}
</script>
```

### Contact Form (index.html lines 1101-1174)

Update the main contact form:

```html
<form id="contactForm" class="contact-form">
    <div class="form-group">
        <label for="name">Your Name</label>
        <input type="text" id="name" name="name" required />
    </div>

    <div class="form-group">
        <label for="email">Work Email Address</label>
        <input type="email" id="email" name="email" required />
    </div>

    <div class="form-group">
        <label for="company">Company/Organization</label>
        <input type="text" id="company" name="company" required />
    </div>

    <div class="form-group">
        <label for="role">Your Role</label>
        <select id="role" name="role">
            <option value="">Select your role...</option>
            <option value="it-director">IT Director/Manager</option>
            <option value="cto">CTO/Technical Lead</option>
            <option value="operations">Operations Manager</option>
            <option value="procurement">Procurement/Purchasing</option>
            <option value="superintendent">Superintendent/Administrator</option>
            <option value="other">Other</option>
        </select>
    </div>

    <div class="form-group">
        <label for="package">Interested In</label>
        <select id="package" name="package">
            <optgroup label="Development Services">
                <option value="ai-rescue">AI Rescue ($2,500-$5,000)</option>
                <option value="complete-build">Complete Build ($10,000-$35,000)</option>
                <option value="business-empire">Business Empire ($40,000-$100,000)</option>
                <option value="hourly">Hourly Consulting ($75-$125/hr)</option>
            </optgroup>
            <optgroup label="Clean Sweep Security">
                <option value="clean-sweep-essential">Clean Sweep Essential ($99/month)</option>
                <option value="clean-sweep-pro">Clean Sweep Pro ($199/month)</option>
                <option value="clean-sweep-enterprise">Clean Sweep Enterprise (Custom)</option>
                <option value="clean-sweep-individual">Clean Sweep Individual ($60)</option>
                <option value="clean-sweep-business">Clean Sweep Small Business ($1,000)</option>
            </optgroup>
        </select>
    </div>

    <div class="form-group">
        <label for="timeline">Timeline</label>
        <select id="timeline" name="timeline">
            <option value="">When do you need this?</option>
            <option value="asap">ASAP - Urgent</option>
            <option value="1-month">Within 1 month</option>
            <option value="3-months">Within 3 months</option>
            <option value="6-months">Within 6 months</option>
            <option value="exploring">Just exploring options</option>
        </select>
    </div>

    <div class="form-group">
        <label for="message">Project Details</label>
        <textarea id="message" name="message" placeholder="Tell us about your current challenges, number of devices/users, and what you're hoping to achieve..." required></textarea>
    </div>

    <button type="submit" class="submit-btn" onclick="submitContactForm(event)">Start Your Journey</button>

    <div style="text-align: center; margin-top: 20px; padding: 15px; background: rgba(78, 205, 196, 0.1); border-radius: 10px;">
        <p style="margin: 0; color: #4ecdc4; font-size: 0.9rem;">⚡ <strong>Fast Response:</strong> We typically respond within 2 hours during business hours</p>
    </div>
</form>

<script>
async function submitContactForm(event) {
    event.preventDefault()

    const formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        company: document.getElementById('company').value,
        role: document.getElementById('role').value,
        interested_in: document.getElementById('package').value,
        timeline: document.getElementById('timeline').value,
        message: document.getElementById('message').value,
        source: 'contact_form'
    }

    // Track in analytics
    trackConversion('contact_form', 'main_contact')

    // Submit to Supabase
    const { data, error } = await supabase
        .from('leads')
        .insert(formData)

    if (error) {
        alert('Error submitting form. Please try again.')
        console.error(error)
    } else {
        alert('Thank you! We\'ll be in touch within 2 hours during business hours.')
        document.getElementById('contactForm').reset()

        // Track successful submission
        await supabase.from('analytics_events').insert({
            event_name: 'contact_form_submitted',
            event_category: 'conversion',
            event_label: formData.interested_in,
            metadata: formData
        })
    }
}
</script>
```

## 📊 Load Service Packages Dynamically

Instead of hardcoding packages, load them from Supabase:

```javascript
// Load service packages on page load
async function loadServicePackages() {
    const { data: packages, error } = await supabase
        .from('service_packages')
        .select('*')
        .eq('is_active', true)
        .order('display_order')

    if (error) {
        console.error('Error loading packages:', error)
        return
    }

    // Now you can dynamically generate package cards from the database
    console.log('Loaded packages:', packages)
}

// Call on page load
document.addEventListener('DOMContentLoaded', loadServicePackages)
```

## 📈 Track Analytics Events

Replace Google Analytics tracking with Supabase:

```javascript
async function trackConversion(eventName, packageType) {
    // Keep existing Google Analytics
    gtag('event', 'conversion', {
        'event_category': 'engagement',
        'event_label': packageType,
        'value': eventName
    })

    // Also track in Supabase for better analysis
    await supabase.from('analytics_events').insert({
        event_name: eventName,
        event_category: 'engagement',
        event_label: packageType,
        page_url: window.location.href,
        user_agent: navigator.userAgent
    })
}
```

## 🎨 Load Testimonials Dynamically

```javascript
async function loadTestimonials() {
    const { data: testimonials, error } = await supabase
        .from('testimonials')
        .select('*')
        .eq('is_approved', true)
        .eq('is_featured', true)
        .order('display_order')
        .limit(3)

    if (error) {
        console.error('Error loading testimonials:', error)
        return
    }

    // Generate testimonial HTML
    const container = document.getElementById('testimonials-container')
    testimonials.forEach(t => {
        container.innerHTML += `
            <div class="testimonial">
                ${t.content}
                <div class="testimonial-author">
                    — ${t.author_name}, ${t.author_title}, ${t.author_company}
                </div>
            </div>
        `
    })
}
```

## 🔐 Admin Dashboard (Future)

You can build an admin dashboard to:
- View all leads
- Manage orders and subscriptions
- Generate and manage Clean Sweep licenses
- View analytics dashboard
- Approve testimonials

Example query for admin dashboard:

```javascript
// Get dashboard metrics
const { data: metrics } = await supabase
    .from('dashboard_metrics')
    .select('*')
    .single()

console.log('Dashboard:', metrics)
// {
//   total_customers: 150,
//   new_leads: 23,
//   active_orders: 8,
//   active_subscriptions: 45,
//   monthly_recurring_revenue: 8955.00,
//   current_month_revenue: 15250.00,
//   active_licenses: 52
// }
```

## 🔄 Next Steps

1. ✅ Set up Supabase project and run migrations
2. ✅ Update contact forms to use Supabase
3. ✅ Add analytics event tracking
4. ✅ Load service packages dynamically
5. ⏳ Build admin dashboard for managing leads
6. ⏳ Set up email notifications for new leads
7. ⏳ Implement crypto payment verification
8. ⏳ Create customer portal for license management

## 📞 Need Help?

Contact: businessdatagurus@gmail.com

---

Happy coding! 🚀
