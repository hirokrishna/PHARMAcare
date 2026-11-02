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
-- PHARMAcare Database Functions
-- Run after schema.sql

-- Trigger: create profile row when a new user signs up
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare r text;
begin
  r := coalesce(new.raw_user_meta_data->>'role','customer');
  if r not in ('customer','seller') then r := 'customer'; end if;
  insert into profiles (id, full_name, phone, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name','User'),
          new.raw_user_meta_data->>'phone', r);
  if r = 'seller' then
    insert into seller_profiles (id, shop_name, licence_number, gst_number, shop_address)
    values (new.id,
            coalesce(new.raw_user_meta_data->>'shop_name','My Shop'),
            coalesce(new.raw_user_meta_data->>'licence_number','NA'),
            new.raw_user_meta_data->>'gst_number',
            new.raw_user_meta_data->>'shop_address');
  end if;
  return new;
end; $$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function handle_new_user();

-- Helper: check if current user is admin
create or replace function is_admin()
returns boolean language sql security definer stable as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

-- Place order (atomic transaction)
create or replace function place_order(
  p_address_id uuid,
  p_payment_method text,
  p_prescription_id uuid default null
) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_user uuid := auth.uid();
  v_order uuid;
  v_addr jsonb;
  v_subtotal numeric := 0;
  v_mrp_total numeric := 0;
  v_fee numeric := 0;
  r record;
begin
  if v_user is null then raise exception 'Please login first'; end if;
  if exists (select 1 from profiles where id = v_user and is_blocked) then
    raise exception 'Your account is blocked';
  end if;

  select to_jsonb(a) into v_addr from addresses a where a.id = p_address_id and a.user_id = v_user;
  if v_addr is null then raise exception 'Select a valid address'; end if;

  if not exists (select 1 from cart_items where user_id = v_user) then
    raise exception 'Cart is empty';
  end if;

  -- check stock and prescription rule
  for r in
    select c.quantity, p.* from cart_items c join products p on p.id = c.product_id
    where c.user_id = v_user
  loop
    if not r.is_active then raise exception '% is not available', r.name; end if;
    if r.stock < r.quantity then raise exception 'Only % left for %', r.stock, r.name; end if;
    if r.requires_prescription and p_prescription_id is null then
      raise exception 'Prescription required for %', r.name;
    end if;
    v_subtotal := v_subtotal + r.price * r.quantity;
    v_mrp_total := v_mrp_total + r.mrp * r.quantity;
  end loop;

  if v_subtotal < 499 then v_fee := 40; end if;

  insert into orders (user_id, address_snapshot, prescription_id, payment_method, payment_status,
                      subtotal, discount, delivery_fee, total)
  values (v_user, v_addr, p_prescription_id, p_payment_method,
          case when p_payment_method = 'online_demo' then 'paid' else 'pending' end,
          v_subtotal, v_mrp_total - v_subtotal, v_fee, v_subtotal + v_fee)
  returning id into v_order;

  insert into order_items (order_id, product_id, seller_id, product_name, price, mrp, quantity)
  select v_order, p.id, p.seller_id, p.name, p.price, p.mrp, c.quantity
  from cart_items c join products p on p.id = c.product_id where c.user_id = v_user;

  update products p set stock = p.stock - c.quantity
  from cart_items c where c.product_id = p.id and c.user_id = v_user;

  delete from cart_items where user_id = v_user;
  return v_order;
end; $$;

-- Cancel order and return stock
create or replace function cancel_order(p_order_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_status text; v_owner uuid;
begin
  select status, user_id into v_status, v_owner from orders where id = p_order_id;
  if v_owner is null then raise exception 'Order not found'; end if;
  if v_owner <> auth.uid() and not is_admin() then raise exception 'Not allowed'; end if;
  if v_status in ('shipped','delivered','cancelled') then
    raise exception 'This order cannot be cancelled now';
  end if;
  update products p set stock = p.stock + oi.quantity
  from order_items oi where oi.order_id = p_order_id and oi.product_id = p.id
    and oi.item_status <> 'cancelled';
  update order_items set item_status = 'cancelled' where order_id = p_order_id;
  update orders set status = 'cancelled' where id = p_order_id;
end; $$;
-- PHARMAcare RLS Policies
-- Run after functions.sql

alter table profiles enable row level security;
alter table seller_profiles enable row level security;
alter table categories enable row level security;
alter table products enable row level security;
alter table cart_items enable row level security;
alter table wishlist enable row level security;
alter table addresses enable row level security;
alter table prescriptions enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table reviews enable row level security;
alter table banners enable row level security;
alter table contact_messages enable row level security;

-- PROFILES
create policy "own profile read" on profiles for select using (id = auth.uid() or is_admin());
create policy "own profile update" on profiles for update using (id = auth.uid())
  with check (id = auth.uid() and role = (select role from profiles where id = auth.uid()));
create policy "admin update profiles" on profiles for update using (is_admin());

-- SELLER PROFILES
create policy "seller own read" on seller_profiles for select using (id = auth.uid() or is_admin());
create policy "seller own update" on seller_profiles for update using (id = auth.uid())
  with check (id = auth.uid() and status = (select status from seller_profiles where id = auth.uid()));
create policy "admin update sellers" on seller_profiles for update using (is_admin());

-- CATEGORIES (public read, admin write)
create policy "categories read" on categories for select using (true);
create policy "categories admin write" on categories for all using (is_admin()) with check (is_admin());

-- PRODUCTS
create policy "products public read" on products for select
  using (is_active = true or seller_id = auth.uid() or is_admin());
create policy "seller insert product" on products for insert
  with check (seller_id = auth.uid() and exists
    (select 1 from seller_profiles where id = auth.uid() and status = 'approved'));
create policy "seller update own product" on products for update
  using (seller_id = auth.uid() or is_admin());
create policy "seller delete own product" on products for delete
  using (seller_id = auth.uid() or is_admin());

-- CART / WISHLIST / ADDRESSES
create policy "cart own" on cart_items for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "wishlist own" on wishlist for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "address own" on addresses for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- PRESCRIPTIONS
create policy "rx own insert" on prescriptions for insert with check (user_id = auth.uid());
create policy "rx read" on prescriptions for select using (user_id = auth.uid() or is_admin());
create policy "rx admin update" on prescriptions for update using (is_admin());

-- ORDERS
create policy "orders read" on orders for select using (
  user_id = auth.uid() or is_admin()
  or exists (select 1 from order_items oi where oi.order_id = orders.id and oi.seller_id = auth.uid()));
create policy "orders cancel own" on orders for update using (user_id = auth.uid() or is_admin());

-- ORDER ITEMS
create policy "items read" on order_items for select using (
  seller_id = auth.uid() or is_admin()
  or exists (select 1 from orders o where o.id = order_items.order_id and o.user_id = auth.uid()));
create policy "items seller update" on order_items for update using (seller_id = auth.uid() or is_admin());

-- REVIEWS
create policy "reviews read" on reviews for select using (true);
create policy "reviews own write" on reviews for insert with check (user_id = auth.uid());
create policy "reviews own delete" on reviews for delete using (user_id = auth.uid() or is_admin());

-- BANNERS
create policy "banners read" on banners for select using (true);
create policy "banners admin" on banners for all using (is_admin()) with check (is_admin());

-- CONTACT MESSAGES
create policy "contact insert any" on contact_messages for insert with check (true);
create policy "contact admin read" on contact_messages for select using (is_admin());
create policy "contact admin update" on contact_messages for update using (is_admin());

-- STORAGE POLICIES (run after creating buckets in Supabase dashboard)
create policy "product images upload" on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "product images read" on storage.objects for select using (bucket_id = 'product-images');

create policy "rx upload own" on storage.objects for insert to authenticated
  with check (bucket_id = 'prescriptions' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "rx read own or admin" on storage.objects for select to authenticated
  using (bucket_id = 'prescriptions' and ((storage.foldername(name))[1] = auth.uid()::text or is_admin()));
-- PHARMAcare Seed Data & Sample Catalog
-- Run this in Supabase SQL Editor

-- 1. Base Categories
insert into categories (name, icon) values
  ('All Medicines', 'fa-pills'),
  ('Health Care', 'fa-heart-pulse'),
  ('Personal Care', 'fa-hand-sparkles'),
  ('Wellness', 'fa-spa'),
  ('Fitness', 'fa-dumbbell'),
  ('Baby Care', 'fa-baby'),
  ('Ayurveda', 'fa-leaf'),
  ('Health Devices', 'fa-stethoscope')
on conflict (name) do nothing;

-- 2. Homepage Banner
insert into banners (title, subtitle, link, is_active) values
  ('Your Trusted Online Pharmacy', 'Genuine Medicines, Great Offers & Care for Your Health', '/medicines.html', true)
on conflict do nothing;

-- 3. Stored Procedure to populate 23 authentic products with real images
create or replace function seed_sample_products(p_seller_id uuid default null)
returns text language plpgsql security definer as $$
declare
  v_seller uuid := p_seller_id;
  c_med int; c_health int; c_pers int; c_well int;
  c_fit int; c_baby int; c_ayur int; c_dev int;
begin
  if v_seller is null then
    select id into v_seller from profiles limit 1;
  end if;

  if v_seller is null then
    return 'Please register at least one user account on the website first.';
  end if;

  select id into c_med from categories where name = 'All Medicines';
  select id into c_health from categories where name = 'Health Care';
  select id into c_pers from categories where name = 'Personal Care';
  select id into c_well from categories where name = 'Wellness';
  select id into c_fit from categories where name = 'Fitness';
  select id into c_baby from categories where name = 'Baby Care';
  select id into c_ayur from categories where name = 'Ayurveda';
  select id into c_dev from categories where name = 'Health Devices';

  insert into products (id, seller_id, category_id, name, pack_info, manufacturer, description, composition, uses, side_effects, mrp, price, stock, expiry_date, requires_prescription, image_url, is_active)
  values
    -- All Medicines
    ('11111111-1111-1111-1111-111111110001'::uuid, v_seller, c_med, 'Paracetamol 500 mg', 'Tablet (10''s)', 'Cipla Ltd', 'Effective fever reducer and mild to moderate pain reliever.', 'Paracetamol IP 500mg', 'Fever reduction, headache, toothache, back pain', 'Generally safe; rare skin sensitivity', 25.00, 20.00, 120, '2028-12-31', false, 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110002'::uuid, v_seller, c_med, 'Dolo 650 mg', 'Tablet (15''s)', 'Micro Labs Ltd', 'High-strength paracetamol for intense body aches and persistent fever.', 'Paracetamol IP 650mg', 'High fever, viral fever, severe headache', 'Do not exceed daily recommended dose', 35.00, 29.00, 200, '2028-10-31', false, 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110003'::uuid, v_seller, c_med, 'Cetirizine 10 mg', 'Tablet (10''s)', 'Dr. Reddy''s', 'Antihistamine used for allergy relief, sneezing, and runny nose.', 'Cetirizine Dihydrochloride 10mg', 'Seasonal allergies, allergic rhinitis, hives', 'Mild drowsiness in some individuals', 40.00, 32.00, 85, '2028-06-30', false, 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110004'::uuid, v_seller, c_med, 'Omeprazole 20 mg', 'Capsule (10''s)', 'Sun Pharma', 'Proton pump inhibitor that reduces excess stomach acid production.', 'Omeprazole IP 20mg', 'Gastroesophageal reflux, acidity, heartburn', 'Abdominal pain, mild headache', 72.00, 58.00, 60, '2027-11-30', true, 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110005'::uuid, v_seller, c_med, 'Amoxicillin 500 mg', 'Capsule (10''s)', 'Abbott Healthcare', 'Broad-spectrum antibiotic used to treat bacterial infections.', 'Amoxicillin Trihydrate IP 500mg', 'Bacterial respiratory and ear infections', 'Nausea, skin rash', 120.00, 96.00, 45, '2027-09-30', true, 'https://images.unsplash.com/photo-1577401239170-897942555fb3?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110006'::uuid, v_seller, c_med, 'Azithromycin 500 mg', 'Tablet (3''s)', 'Cipla Ltd', 'Antibiotic medicine used to treat bacterial throat and chest infections.', 'Azithromycin Dihydrate IP 500mg', 'Throat infection, bronchitis, sinusitis', 'Diarrhea, mild stomach discomfort', 115.00, 89.00, 50, '2027-08-31', true, 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=500&auto=format&fit=crop&q=60', true),

    -- Health Care
    ('11111111-1111-1111-1111-111111110007'::uuid, v_seller, c_health, 'Digene Acidity Relief Gel', 'Bottle (200 ml)', 'Abbott India', 'Antacid suspension providing fast soothing relief from acidity and gas.', 'Magnesium Hydroxide, Aluminium Hydroxide', 'Acidity, indigestion, heartburn', 'Mild laxative effect in excess dosage', 165.00, 145.00, 75, '2028-05-31', false, 'https://images.unsplash.com/photo-1527613426441-4da17471b66d?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110008'::uuid, v_seller, c_health, 'Volini Pain Relief Gel', 'Tube (50 g)', 'Sun Pharma', 'Quick-absorbing topical gel that eases joint and muscle stiffness.', 'Diclofenac Diethylamine, Menthol, Linseed Oil', 'Sprains, back pain, joint stiffness', 'Temporary skin warmth or redness', 150.00, 125.00, 90, '2028-04-30', false, 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110009'::uuid, v_seller, c_health, 'Dettol Antiseptic Disinfectant Liquid', 'Bottle (250 ml)', 'Reckitt Benckiser', 'Trusted antiseptic liquid for first aid, cuts, grazes and hygiene.', 'Chloroxylenol 4.8% w/v', 'Wound cleansing, general skin disinfection', 'Do not ingest, for external topical use', 180.00, 155.00, 110, '2029-01-31', false, 'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=500&auto=format&fit=crop&q=60', true),

    -- Personal Care
    ('11111111-1111-1111-1111-111111110010'::uuid, v_seller, c_pers, 'Nivea Soft Light Moisturizing Cream', 'Jar (100 ml)', 'Beiersdorf India', 'Light revitalizing cream enriched with Jojoba oil and Vitamin E.', 'Aqua, Glycerin, Jojoba Seed Oil, Vitamin E', 'Daily face and body hydration', 'Suitable for all skin types', 199.00, 159.00, 65, '2028-07-31', false, 'https://images.unsplash.com/photo-1556228722-d0b5d840dd67?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110011'::uuid, v_seller, c_pers, 'Sebamed Gentle Cleansing Bar', 'Bar (100 g)', 'Sebapharma', 'Soap-free cleansing bar with pH 5.5 to maintain healthy skin barrier.', 'Disodium Lauryl Sulfosuccinate, Triticum Vulgare Starch', 'Sensitive and delicate skin cleansing', 'Hypoallergenic and gentle', 240.00, 205.00, 40, '2028-03-31', false, 'https://images.unsplash.com/photo-1608248597359-598e9162fa9c?w=500&auto=format&fit=crop&q=60', true),

    -- Wellness
    ('11111111-1111-1111-1111-111111110012'::uuid, v_seller, c_well, 'Vitamin C 500 mg with Zinc', 'Tablet (30''s)', 'Torrent Pharma', 'Daily immunity boosting tablets for antioxidant protection.', 'Ascorbic Acid 500mg, Elemental Zinc 10mg', 'Immunity support, tissue repair, fatigue relief', 'Take after meals with water', 140.00, 110.00, 180, '2028-09-30', false, 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110013'::uuid, v_seller, c_well, 'Becosules Daily Multivitamin', 'Capsule (20''s)', 'Pfizer Ltd', 'Vitamin B-Complex with Vitamin C for cellular energy and vitality.', 'Vitamin B1, B2, B6, B12, Niacinamide, Calcium Pantothenate', 'Energy metabolism, mouth ulcers, nerve health', 'Harmless temporary bright yellow urine', 55.00, 46.00, 140, '2028-02-28', false, 'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110014'::uuid, v_seller, c_well, 'Pure Omega-3 Fish Oil 1000 mg', 'Softgel (60''s)', 'HealthKart', 'Pure molecularly distilled fish oil rich in EPA and DHA fatty acids.', 'Fish Oil 1000mg providing EPA 180mg and DHA 120mg', 'Cardiovascular health, joint flexibility, brain function', 'Fishy aftertaste if taken on empty stomach', 599.00, 449.00, 70, '2027-10-31', false, 'https://images.unsplash.com/photo-1577401239170-897942555fb3?w=500&auto=format&fit=crop&q=60', true),

    -- Fitness
    ('11111111-1111-1111-1111-111111110015'::uuid, v_seller, c_fit, 'Optimum Nutrition Gold Whey Protein', 'Tub (1 kg)', 'Glanbia', '100% Whey Protein isolate and concentrate for lean muscle recovery.', 'Whey Protein Isolates, Glutamine & BCAAs', 'Post-workout muscle protein synthesis', 'Contains dairy allergen ingredients', 3200.00, 2650.00, 25, '2028-01-31', false, 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110016'::uuid, v_seller, c_fit, 'Fast&Up Instant Electrolyte Drink', 'Tube (20 tabs)', 'Aeronutrix', 'Effervescent rehydration drink tabs with essential electrolytes and vitamin C.', 'Sodium, Potassium, Magnesium, Chloride, Vitamin C', 'Instant rehydration during sports and heavy training', 'Dissolve 1 tablet in 500ml clean water', 290.00, 235.00, 95, '2027-12-31', false, 'https://images.unsplash.com/photo-1514733670139-4d87a1941d55?w=500&auto=format&fit=crop&q=60', true),

    -- Baby Care
    ('11111111-1111-1111-1111-111111110017'::uuid, v_seller, c_baby, 'Pampers All Round Protection Diaper Pants', 'Pack (28 pants)', 'Procter & Gamble', 'Breathable baby diaper pants with anti-rash lotion and aloe vera.', 'Cotton-like softness with absorbent gel core', 'Up to 12 hours dryness for active babies', 'Dispose thoughtfully in household waste', 499.00, 399.00, 50, '2029-05-31', false, 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110018'::uuid, v_seller, c_baby, 'Himalaya Gentle Baby Massage Oil', 'Bottle (200 ml)', 'Himalaya Wellness', 'Pure nourishing baby oil enriched with Olive oil and Winter Cherry.', 'Olive Oil, Winter Cherry extract', 'Daily gentle baby body massage and bone strength', 'Clinically tested for delicate infant skin', 185.00, 155.00, 80, '2028-07-31', false, 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&auto=format&fit=crop&q=60', true),

    -- Ayurveda
    ('11111111-1111-1111-1111-111111110019'::uuid, v_seller, c_ayur, 'Dabur Chyawanprash Awaleha', 'Jar (500 g)', 'Dabur India Ltd', 'Time-tested Ayurvedic formulation with 40+ herbs for all-season immunity.', 'Amla, Ashwagandha, Pippali, Shatavari, Pure Ghee', 'Enhances strength, stamina, and respiratory resistance', 'Take 1-2 teaspoons daily with warm milk', 245.00, 210.00, 115, '2028-11-30', false, 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110020'::uuid, v_seller, c_ayur, 'Baidyanath Pure Triphala Churna', 'Bottle (100 g)', 'Shree Baidyanath', 'Traditional herbal blend of Haritaki, Bibhitaki, and Amalaki.', 'Equal parts Amla, Harad, Baheda', 'Digestive regulation and internal detox', 'Take with warm water before bedtime', 110.00, 92.00, 60, '2028-08-31', false, 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=500&auto=format&fit=crop&q=60', true),

    -- Health Devices
    ('11111111-1111-1111-1111-111111110021'::uuid, v_seller, c_dev, 'Omron Blood Pressure Monitor HEM-7120', 'Device', 'Omron Healthcare', 'Accurate digital upper arm BP monitor with Intellisense technology.', 'Oscillometric digital sensor with cuff', 'Home blood pressure and pulse monitoring', 'Store in dry protective pouch', 2450.00, 1999.00, 30, null, false, 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110022'::uuid, v_seller, c_dev, 'Accu-Chek Blood Glucose Monitor Kit', 'Kit', 'Roche Diabetes Care', 'Fast 5-second blood sugar testing meter with 10 test strips.', 'Electrochemical biosensor meter, lancet pen', 'Self-monitoring of blood glucose levels', 'Single-use lancets and strips', 1499.00, 1199.00, 45, null, false, 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110023'::uuid, v_seller, c_dev, 'Dr. Morepen Digital Clinical Thermometer', 'Piece', 'Dr. Morepen', 'Fast and precise digital clinical thermometer with beeper alert and LCD.', 'Digital thermistor with beeper and LCD readout', 'Accurate fever detection', 'Clean sensor tip with alcohol swab before use', 199.00, 149.00, 150, null, false, 'https://images.unsplash.com/photo-1584362917165-526a968579e8?w=500&auto=format&fit=crop&q=60', true)
  on conflict (id) do update set
    name = excluded.name,
    price = excluded.price,
    mrp = excluded.mrp,
    image_url = excluded.image_url;

  return 'Successfully seeded 23 realistic healthcare products with photos!';
end; $$;
