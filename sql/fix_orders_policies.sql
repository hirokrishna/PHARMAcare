-- ============================================================
-- PHARMAcare - Fix Orders & Order Items RLS Recursion
-- Run this in Supabase SQL Editor to make orders visible!
-- ============================================================

-- 1. Helper security definer functions to inspect ownership without triggering RLS recursion
CREATE OR REPLACE FUNCTION user_owns_order(p_order_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM orders WHERE id = p_order_id AND user_id = auth.uid());
$$;

CREATE OR REPLACE FUNCTION seller_has_order_item(p_order_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM order_items WHERE order_id = p_order_id AND seller_id = auth.uid());
$$;

-- 2. Drop existing mutual-recursive policies
DROP POLICY IF EXISTS "orders insert own" ON orders;
DROP POLICY IF EXISTS "orders read" ON orders;
DROP POLICY IF EXISTS "orders cancel own" ON orders;

DROP POLICY IF EXISTS "items insert own" ON order_items;
DROP POLICY IF EXISTS "items read" ON order_items;
DROP POLICY IF EXISTS "items seller update" ON order_items;

-- 3. Recreate clean non-recursive policies
CREATE POLICY "orders insert own" ON orders FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "orders read" ON orders FOR SELECT USING (user_id = auth.uid() OR is_admin() OR seller_has_order_item(id));
CREATE POLICY "orders cancel own" ON orders FOR UPDATE USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "items insert own" ON order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "items read" ON order_items FOR SELECT USING (seller_id = auth.uid() OR is_admin() OR user_owns_order(order_id));
CREATE POLICY "items seller update" ON order_items FOR UPDATE USING (seller_id = auth.uid() OR is_admin());

-- 4. Grant access to public/authenticated
GRANT SELECT, INSERT, UPDATE ON orders TO authenticated;
GRANT SELECT, INSERT, UPDATE ON order_items TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

