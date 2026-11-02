# PHARMAcare – Online Pharmacy Web Application

A college project web application that simulates an online pharmacy platform with customer, seller, and admin roles.

## Description

PHARMAcare is a multi-role e-commerce platform for medicines and healthcare products. Customers can browse products, add to cart, upload prescriptions, and place orders. Sellers (pharmacists) can list products and manage their inventory. Admins manage the entire platform.

## Tech Stack

| Layer        | Technology                          |
|--------------|-------------------------------------|
| Frontend     | HTML5, CSS3, Vanilla JavaScript      |
| Database     | Supabase (PostgreSQL)               |
| Auth         | Supabase Auth                       |
| File Storage | Supabase Storage                    |
| Icons        | Font Awesome 6 (CDN)                |
| Fonts        | Poppins (Google Fonts)              |

> No React, no build tools, no TypeScript – just plain HTML/CSS/JS with Supabase CDN.

---

## Setup Instructions

Follow these steps in order:

### Step 1 – Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click **New Project** and fill in the details
3. Wait for the project to be ready (about 1 minute)

### Step 2 – Run the SQL Setup in Supabase

Open your **Supabase Dashboard → SQL Editor**, click **New query**, and you can either:

**Option A (Fastest – 1-Click Run):**
Copy and paste everything from:
- **`sql/all_in_one_setup.sql`**
and click **Run**. This will create all 13 tables, trigger functions, RLS security policies, and initial categories in one go!

**Option B (Separate files):**
Run the files in this exact order:
1. **`sql/schema.sql`** – Creates all tables and indexes
2. **`sql/functions.sql`** – Creates triggers, stored procedures, and order functions
3. **`sql/policies.sql`** – Enables Row Level Security and access control
4. **`sql/seed.sql`** – Inserts initial categories and catalog seed function

### Step 3 – Set Your Supabase Keys

1. Go to **Supabase Dashboard → Project Settings → API**
2. Copy your **Project URL** and **anon public key**
3. Open `js/supabase.js` and replace the placeholders:

```js
var SUPABASE_URL = 'YOUR_SUPABASE_URL';      // ← paste here
var SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';     // ← paste here
```

### Step 4 – Create Storage Buckets

In **Supabase Dashboard → Storage**:

1. Create bucket named **`product-images`** (set to Public)
2. Create bucket named **`prescriptions`** (set to Private)

### Step 5 – Open with Live Server

- Open the project folder in **VS Code**
- Install the **Live Server** extension if you haven't
- Right-click `index.html` → **Open with Live Server**
- The site opens at `http://localhost:5500`

### Step 6 – Populate 23 Demo Medicines (For Demo / Viva)

Once you register your first account (Customer, Seller, or Admin), you can immediately populate the entire store with authentic medicines by running one command in the Supabase **SQL Editor**:

```sql
SELECT seed_sample_products();
```

This instantly creates 23 authentic products across all 8 categories (with compositions, manufacturers like Cipla and Abbott, realistic prices, and pack info) so your website is ready for viva presentation immediately!

---

## How to Create the First Admin User

1. Register a normal account on the site (as Customer)
2. Confirm your email
3. In **Supabase Dashboard → SQL Editor**, run:

```sql
update profiles set role = 'admin' where id = '<your-user-uuid>';
```

To find your UUID: go to **Supabase Dashboard → Authentication → Users** and copy your user's ID.

---

## Folder Structure

```
PHARMAcare/
├── index.html              Homepage
├── medicines.html          Product listing / search
├── product.html            Single product detail
├── offers.html             Deals and offers
├── about.html              About the platform
├── contact.html            Contact form
├── login.html              Login page
├── register.html           Registration page
├── forgot-password.html    Password reset
├── cart.html               Shopping cart
├── checkout.html           Order checkout
├── order-success.html      Order confirmation
├── my-orders.html          Customer order history
├── order-detail.html       Single order view
├── profile.html            User profile management
├── wishlist.html           Saved products
│
├── seller/                 Seller dashboard area
│   ├── dashboard.html
│   ├── products.html
│   ├── add-product.html
│   └── orders.html
│
├── admin/                  Admin panel area
│   ├── dashboard.html
│   ├── sellers.html
│   ├── users.html
│   ├── products.html
│   ├── orders.html
│   ├── categories.html
│   ├── banners.html
│   └── messages.html
│
├── css/
│   ├── style.css           Global styles, navbar, footer, buttons, cards
│   ├── home.css            Homepage-specific styles
│   ├── forms.css           Login/Register form styles
│   └── dashboard.css       Seller/Admin dashboard styles
│
├── js/
│   ├── supabase.js         Supabase client (put your keys here)
│   ├── auth.js             Login, logout, role checks
│   ├── products.js         Product fetch functions
│   ├── cart.js             Cart CRUD functions
│   ├── orders.js           Order placement and history
│   ├── seller.js           Seller dashboard functions
│   ├── admin.js            Admin management functions
│   └── main.js             Navbar/footer injection, toast, cart count
│
├── images/                 Logo and static images
│
├── sql/
│   ├── schema.sql          Database table definitions
│   ├── functions.sql       Triggers and stored procedures
│   ├── policies.sql        Row Level Security policies
│   └── seed.sql            Initial data (categories, banner)
│
└── README.md               This file
```

---

## Color Palette

| Variable       | Value     | Usage                              |
|----------------|-----------|------------------------------------|
| `--navy`       | `#0B2A4A` | Headings, logo text, primary button |
| `--green`      | `#1B8A1B` | Highlights, outline buttons        |
| `--green-dark` | `#146B14` | Hover on green elements            |
| `--mint`       | `#E6F4EA` | Active nav, features strip, badges |
| `--grey-bg`    | `#F5F7F6` | Page section backgrounds           |
| `--border`     | `#E2E6E4` | Card and input borders             |
| `--text`       | `#1F2933` | Body text                          |
| `--muted`      | `#6B7280` | Small/secondary text               |
| `--red`        | `#D32F2F` | Error messages                     |
| `--orange`     | `#F59E0B` | Warnings, low stock                |

---

## Team Members

| # | Name | Role |
|---|------|------|
| 1 | __________________ | __________________ |
| 2 | __________________ | __________________ |
| 3 | __________________ | __________________ |
| 4 | __________________ | __________________ |
| 5 | __________________ | __________________ |

---

## License

MIT License – This project is made for educational purposes as a college assignment.
