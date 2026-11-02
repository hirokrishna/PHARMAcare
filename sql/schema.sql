-- PHARMAcare Database Schema
-- Run this first in Supabase SQL Editor

-- PROFILES
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  role text not null default 'customer' check (role in ('customer','seller','admin')),
  is_blocked boolean not null default false,
  created_at timestamptz default now()
);

-- SELLER PROFILES
create table seller_profiles (
  id uuid primary key references profiles(id) on delete cascade,
  shop_name text not null,
  licence_number text not null,
  gst_number text,
  shop_address text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz default now()
);

-- CATEGORIES
create table categories (
  id serial primary key,
  name text not null unique,
  icon text,
  created_at timestamptz default now()
);

-- PRODUCTS
create table products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references profiles(id) on delete cascade,
  category_id int references categories(id),
  name text not null,
  pack_info text,
  description text,
  composition text,
  uses text,
  side_effects text,
  manufacturer text,
  mrp numeric(10,2) not null check (mrp >= 0),
  price numeric(10,2) not null check (price >= 0),
  stock int not null default 0 check (stock >= 0),
  expiry_date date,
  requires_prescription boolean not null default false,
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz default now(),
  check (price <= mrp)
);
create index idx_products_category on products(category_id);
create index idx_products_name on products(name);
create index idx_products_seller on products(seller_id);

-- CART
create table cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  quantity int not null default 1 check (quantity between 1 and 10),
  created_at timestamptz default now(),
  unique (user_id, product_id)
);
create index idx_cart_user on cart_items(user_id);

-- WISHLIST
create table wishlist (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  unique (user_id, product_id)
);

-- ADDRESSES
create table addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  full_name text not null,
  phone text not null,
  address_line text not null,
  city text not null,
  state text not null,
  pincode text not null,
  is_default boolean default false,
  created_at timestamptz default now()
);

-- PRESCRIPTIONS
create table prescriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  file_path text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  remark text,
  created_at timestamptz default now()
);

-- ORDERS
create table orders (
  id uuid primary key default gen_random_uuid(),
  order_no serial,
  user_id uuid not null references profiles(id),
  address_snapshot jsonb not null,
  prescription_id uuid references prescriptions(id),
  payment_method text not null check (payment_method in ('cod','online_demo')),
  payment_status text not null default 'pending' check (payment_status in ('pending','paid')),
  subtotal numeric(10,2) not null,
  discount numeric(10,2) not null default 0,
  delivery_fee numeric(10,2) not null default 0,
  total numeric(10,2) not null,
  status text not null default 'placed'
    check (status in ('placed','confirmed','packed','shipped','delivered','cancelled')),
  created_at timestamptz default now()
);
create index idx_orders_user on orders(user_id);

-- ORDER ITEMS
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid not null references products(id),
  seller_id uuid not null references profiles(id),
  product_name text not null,
  price numeric(10,2) not null,
  mrp numeric(10,2) not null,
  quantity int not null check (quantity > 0),
  item_status text not null default 'placed'
    check (item_status in ('placed','confirmed','packed','shipped','delivered','cancelled'))
);
create index idx_items_order on order_items(order_id);
create index idx_items_seller on order_items(seller_id);

-- REVIEWS
create table reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz default now(),
  unique (product_id, user_id)
);

-- BANNERS
create table banners (
  id serial primary key,
  title text not null,
  subtitle text,
  image_url text,
  link text,
  is_active boolean default true
);

-- CONTACT MESSAGES
create table contact_messages (
  id serial primary key,
  name text not null,
  email text not null,
  message text not null,
  is_read boolean default false,
  created_at timestamptz default now()
);
