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
