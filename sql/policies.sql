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

-- HELPER SECURITY DEFINER FUNCTIONS (Prevents infinite RLS recursion between orders and order_items)
create or replace function user_owns_order(p_order_id uuid)
returns boolean language sql security definer set search_path = public as $$
  select exists (select 1 from orders where id = p_order_id and user_id = auth.uid());
$$;

create or replace function seller_has_order_item(p_order_id uuid)
returns boolean language sql security definer set search_path = public as $$
  select exists (select 1 from order_items where order_id = p_order_id and seller_id = auth.uid());
$$;

-- ORDERS
create policy "orders insert own" on orders for insert with check (user_id = auth.uid());
create policy "orders read" on orders for select using (
  user_id = auth.uid() or is_admin() or seller_has_order_item(id));
create policy "orders cancel own" on orders for update using (user_id = auth.uid() or is_admin());

-- ORDER ITEMS
create policy "items insert own" on order_items for insert with check (true);
create policy "items read" on order_items for select using (
  seller_id = auth.uid() or is_admin() or user_owns_order(order_id));
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
