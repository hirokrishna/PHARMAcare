-- ============================================================
-- PHARMAcare - One-Click Database Seeder for Products
-- Run this in Supabase SQL Editor to populate all medicines!
-- ============================================================

DO $$
DECLARE
  v_seller uuid;
  c_med int; c_health int; c_pers int; c_well int;
  c_fit int; c_baby int; c_ayur int; c_dev int;
BEGIN
  -- 1. Find any registered user to act as the seller/owner
  SELECT id INTO v_seller FROM profiles ORDER BY created_at ASC LIMIT 1;

  IF v_seller IS NULL THEN
    RAISE EXCEPTION 'No user found in profiles. Please register or sign in on the website first.';
  END IF;

  -- 2. Ensure seller profile exists and is approved
  INSERT INTO seller_profiles (id, shop_name, licence_number, status)
  VALUES (v_seller, 'PHARMAcare Central Pharmacy', 'DL-2026-998877', 'approved')
  ON CONFLICT (id) DO UPDATE SET status = 'approved';

  -- 3. Ensure categories exist
  INSERT INTO categories (name, icon) VALUES
    ('All Medicines', 'fa-pills'),
    ('Health Care', 'fa-heart-pulse'),
    ('Personal Care', 'fa-hand-sparkles'),
    ('Wellness', 'fa-spa'),
    ('Fitness', 'fa-dumbbell'),
    ('Baby Care', 'fa-baby'),
    ('Ayurveda', 'fa-leaf'),
    ('Health Devices', 'fa-stethoscope')
  ON CONFLICT (name) DO NOTHING;

  SELECT id INTO c_med FROM categories WHERE name = 'All Medicines';
  SELECT id INTO c_health FROM categories WHERE name = 'Health Care';
  SELECT id INTO c_pers FROM categories WHERE name = 'Personal Care';
  SELECT id INTO c_well FROM categories WHERE name = 'Wellness';
  SELECT id INTO c_fit FROM categories WHERE name = 'Fitness';
  SELECT id INTO c_baby FROM categories WHERE name = 'Baby Care';
  SELECT id INTO c_ayur FROM categories WHERE name = 'Ayurveda';
  SELECT id INTO c_dev FROM categories WHERE name = 'Health Devices';

  -- 4. Insert all 23 medicines and health products with matching UUIDs
  INSERT INTO products (id, seller_id, category_id, name, pack_info, manufacturer, description, composition, uses, side_effects, mrp, price, stock, expiry_date, requires_prescription, image_url, is_active)
  VALUES
    -- All Medicines
    ('11111111-1111-1111-1111-111111110001'::uuid, v_seller, c_med, 'Paracetamol 500 mg', 'Tablet (10''s)', 'Cipla Ltd', 'Effective fever reducer and mild to moderate pain reliever.', 'Paracetamol IP 500mg', 'Fever reduction, headache, toothache, back pain', 'Generally safe; rare skin sensitivity', 25.00, 20.00, 120, '2028-12-31', false, 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110002'::uuid, v_seller, c_med, 'Dolo 650 mg', 'Tablet (15''s)', 'Micro Labs Ltd', 'High-strength paracetamol for intense body aches and persistent fever.', 'Paracetamol IP 650mg', 'High fever, viral fever, severe headache', 'Do not exceed daily recommended dose', 35.00, 29.00, 200, '2028-10-31', false, 'https://images.apollo247.in/pub/media/catalog/product/D/O/DOL0026_1_1.jpg', true),
    ('11111111-1111-1111-1111-111111110003'::uuid, v_seller, c_med, 'Cetirizine 10 mg', 'Tablet (10''s)', 'Dr. Reddy''s', 'Antihistamine used for allergy relief, sneezing, and runny nose.', 'Cetirizine Dihydrochloride 10mg', 'Seasonal allergies, allergic rhinitis, hives', 'Mild drowsiness in some individuals', 40.00, 32.00, 85, '2028-06-30', false, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRdhtUW33FRmto90WOiJs-5lQvCEFchC1clFkEm_rr97rl8N_JXu6NifWv&s=10', true),
    ('11111111-1111-1111-1111-111111110004'::uuid, v_seller, c_med, 'Omeprazole 20 mg', 'Capsule (10''s)', 'Sun Pharma', 'Proton pump inhibitor that reduces excess stomach acid production.', 'Omeprazole IP 20mg', 'Gastroesophageal reflux, acidity, heartburn', 'Abdominal pain, mild headache', 72.00, 58.00, 60, '2027-11-30', true, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAs3D8Gy7NtLkgWeoQpfb2dUnh8grmPMrxVNcTbJ6u4g&s=10', true),
    ('11111111-1111-1111-1111-111111110005'::uuid, v_seller, c_med, 'Amoxicillin 500 mg', 'Capsule (10''s)', 'Abbott Healthcare', 'Broad-spectrum antibiotic used to treat bacterial infections.', 'Amoxicillin Trihydrate IP 500mg', 'Bacterial respiratory and ear infections', 'Nausea, skin rash', 120.00, 96.00, 45, '2027-09-30', true, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7gDhuJ6jhdh5e-H1EdLYxmeDtec_lDRcHE6M1f0CunA&s=10', true),
    ('11111111-1111-1111-1111-111111110006'::uuid, v_seller, c_med, 'Azithromycin 500 mg', 'Tablet (3''s)', 'Cipla Ltd', 'Antibiotic medicine used to treat bacterial throat and chest infections.', 'Azithromycin Dihydrate IP 500mg', 'Throat infection, bronchitis, sinusitis', 'Diarrhea, mild stomach discomfort', 115.00, 89.00, 50, '2027-08-31', true, 'https://onemg.gumlet.io/l_watermark_346,w_480,h_480/a_ignore,w_480,h_480,c_fit,q_auto,f_auto/58ef49b897694a8e97be55842fadbe5b.jpg', true),

    -- Health Care
    ('11111111-1111-1111-1111-111111110007'::uuid, v_seller, c_health, 'Digene Acidity Relief Gel', 'Bottle (200 ml)', 'Abbott India', 'Antacid suspension providing fast soothing relief from acidity and gas.', 'Magnesium Hydroxide, Aluminium Hydroxide', 'Acidity, indigestion, heartburn', 'Mild laxative effect in excess dosage', 165.00, 145.00, 75, '2028-05-31', false, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROyIDFUNB7rwvmhIWDwbSnjPSAnZ6NVrvXpdMwxEJA_g&s=10', true),
    ('11111111-1111-1111-1111-111111110008'::uuid, v_seller, c_health, 'Volini Pain Relief Gel', 'Tube (50 g)', 'Sun Pharma', 'Quick-absorbing topical gel that eases joint and muscle stiffness.', 'Diclofenac Diethylamine, Menthol, Linseed Oil', 'Sprains, back pain, joint stiffness', 'Temporary skin warmth or redness', 150.00, 125.00, 90, '2028-04-30', false, 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110009'::uuid, v_seller, c_health, 'Dettol Antiseptic Disinfectant Liquid', 'Bottle (250 ml)', 'Reckitt Benckiser', 'Trusted antiseptic liquid for first aid, cuts, grazes and hygiene.', 'Chloroxylenol 4.8% w/v', 'Wound cleansing, general skin disinfection', 'Do not ingest, for external topical use', 180.00, 155.00, 110, '2029-01-31', false, 'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=500&auto=format&fit=crop&q=60', true),

    -- Personal Care
    ('11111111-1111-1111-1111-111111110010'::uuid, v_seller, c_pers, 'Nivea Soft Light Moisturizing Cream', 'Jar (100 ml)', 'Beiersdorf India', 'Light revitalizing cream enriched with Jojoba oil and Vitamin E.', 'Aqua, Glycerin, Jojoba Seed Oil, Vitamin E', 'Daily face and body hydration', 'Suitable for all skin types', 199.00, 159.00, 65, '2028-07-31', false, 'https://www.quickpantry.in/cdn/shop/files/Nivea_Soft_Light_Moisturising_Cream_Quick_Pantry.png?v=1741294236', true),
    ('11111111-1111-1111-1111-111111110011'::uuid, v_seller, c_pers, 'Sebamed Gentle Cleansing Bar', 'Bar (100 g)', 'Sebapharma', 'Soap-free cleansing bar with pH 5.5 to maintain healthy skin barrier.', 'Disodium Lauryl Sulfosuccinate, Triticum Vulgare Starch', 'Sensitive and delicate skin cleansing', 'Hypoallergenic and gentle', 240.00, 205.00, 40, '2028-03-31', false, 'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcQ-3WFQ6Wuq71yewMPnS9TLrInYYmjXb2ChuDpQ--_oHNZC4jUdaiF6OVfrkdYZ91DkzT7vXR0D3-vex-i41rEOJ7smu0ov', true),

    -- Wellness
    ('11111111-1111-1111-1111-111111110012'::uuid, v_seller, c_well, 'Vitamin C 500 mg with Zinc', 'Tablet (30''s)', 'Torrent Pharma', 'Daily immunity boosting tablets for antioxidant protection.', 'Ascorbic Acid 500mg, Elemental Zinc 10mg', 'Immunity support, tissue repair, fatigue relief', 'Take after meals with water', 140.00, 110.00, 180, '2028-09-30', false, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUOH8URB1QrO4GVI980BBA1cNWVonEeaoDn5dVUHnulQ&s=10', true),
    ('11111111-1111-1111-1111-111111110013'::uuid, v_seller, c_well, 'Becosules Daily Multivitamin', 'Capsule (20''s)', 'Pfizer Ltd', 'Vitamin B-Complex with Vitamin C for cellular energy and vitality.', 'Vitamin B1, B2, B6, B12, Niacinamide, Calcium Pantothenate', 'Energy metabolism, mouth ulcers, nerve health', 'Harmless temporary bright yellow urine', 55.00, 46.00, 140, '2028-02-28', false, 'https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?w=500&auto=format&fit=crop&q=60', true),
    ('11111111-1111-1111-1111-111111110014'::uuid, v_seller, c_well, 'Pure Omega-3 Fish Oil 1000 mg', 'Softgel (60''s)', 'HealthKart', 'Pure molecularly distilled fish oil rich in EPA and DHA fatty acids.', 'Fish Oil 1000mg providing EPA 180mg and DHA 120mg', 'Cardiovascular health, joint flexibility, brain function', 'Fishy aftertaste if taken on empty stomach', 599.00, 449.00, 70, '2027-10-31', false, 'https://onemg.gumlet.io/l_watermark_346,w_480,h_480/a_ignore,w_480,h_480,c_fit,q_auto,f_auto/8eadca6d3e64422695358026d813275c.jpg', true),

    -- Fitness
    ('11111111-1111-1111-1111-111111110015'::uuid, v_seller, c_fit, 'Optimum Nutrition Gold Whey Protein', 'Tub (1 kg)', 'Glanbia', '100% Whey Protein isolate and concentrate for lean muscle recovery.', 'Whey Protein Isolates, Glutamine & BCAAs', 'Post-workout muscle protein synthesis', 'Contains dairy allergen ingredients', 3200.00, 2650.00, 25, '2028-01-31', false, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTy7wLRkcwR3b2vvkixgWI9OJWsseuzRmrZ8I7w078rOQ&s=10', true),
    ('11111111-1111-1111-1111-111111110016'::uuid, v_seller, c_fit, 'Fast&Up Instant Electrolyte Drink', 'Tube (20 tabs)', 'Aeronutrix', 'Effervescent rehydration drink tabs with essential electrolytes and vitamin C.', 'Sodium, Potassium, Magnesium, Chloride, Vitamin C', 'Instant rehydration during sports and heavy training', 'Dissolve 1 tablet in 500ml clean water', 290.00, 235.00, 95, '2027-12-31', false, 'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcS6j6ozMnjOtZXsiJ-vEREq8zNDiBZwtGjfZULYBuFSxK_tmpAUOXk4MgjIsHdXcpDAhBwGWY8sqeAGPzx5VceZeqxOSNR1cZ7xO_-tEIknYlcJ21cctSdzfWcJ5OXY-AWX8xyhjA&usqp=CAc', true),

    -- Baby Care
    ('11111111-1111-1111-1111-111111110017'::uuid, v_seller, c_baby, 'Pampers All Round Protection Diaper Pants', 'Pack (28 pants)', 'Procter & Gamble', 'Breathable baby diaper pants with anti-rash lotion and aloe vera.', 'Cotton-like softness with absorbent gel core', 'Up to 12 hours dryness for active babies', 'Dispose thoughtfully in household waste', 499.00, 399.00, 50, '2029-05-31', false, 'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTBRdFPMmmOGQtn3QAQbRalBWrzYAcHY8EBDLh_XZRaNoiqRSkHZdVsATuqQlLr1KsUr3XoJWSv7TYQ8jrAPwbzassIXeFTaM6eenMTgXVBFd6yK4JXPDs5kRN4iaErQ74R6pn_cPG2ewE&usqp=CAc', true),
    ('11111111-1111-1111-1111-111111110018'::uuid, v_seller, c_baby, 'Himalaya Gentle Baby Massage Oil', 'Bottle (200 ml)', 'Himalaya Wellness', 'Pure nourishing baby oil enriched with Olive oil and Winter Cherry.', 'Olive Oil, Winter Cherry extract', 'Daily gentle baby body massage and bone strength', 'Clinically tested for delicate infant skin', 185.00, 155.00, 80, '2028-07-31', false, 'https://m.media-amazon.com/images/I/31No7EIqEmL._SY300_SX300_QL70_FMwebp_.jpg', true),

    -- Ayurveda
    ('11111111-1111-1111-1111-111111110019'::uuid, v_seller, c_ayur, 'Dabur Chyawanprash Awaleha', 'Jar (500 g)', 'Dabur India Ltd', 'Time-tested Ayurvedic formulation with 40+ herbs for all-season immunity.', 'Amla, Ashwagandha, Pippali, Shatavari, Pure Ghee', 'Enhances strength, stamina, and respiratory resistance', 'Take 1-2 teaspoons daily with warm milk', 245.00, 210.00, 115, '2028-11-30', false, 'https://cdn.netmeds.tech/v2/plain-cake-860195/netmed/wrkr/products/pictures/item/free/resize-w:400/PVRRVFUTyl-dabur_chyawanprash_1_kg_0.jpg', true),
    ('11111111-1111-1111-1111-111111110020'::uuid, v_seller, c_ayur, 'Baidyanath Pure Triphala Churna', 'Bottle (100 g)', 'Shree Baidyanath', 'Traditional herbal blend of Haritaki, Bibhitaki, and Amalaki.', 'Equal parts Amla, Harad, Baheda', 'Digestive regulation and internal detox', 'Take with warm water before bedtime', 110.00, 92.00, 60, '2028-08-31', false, 'https://m.media-amazon.com/images/I/41cpFc7oE1L._SY300_SX300_QL70_FMwebp_.jpg', true),

    -- Health Devices
    ('11111111-1111-1111-1111-111111110021'::uuid, v_seller, c_dev, 'Omron Blood Pressure Monitor HEM-7120', 'Device', 'Omron Healthcare', 'Accurate digital upper arm BP monitor with Intellisense technology.', 'Oscillometric digital sensor with cuff', 'Home blood pressure and pulse monitoring', 'Store in dry protective pouch', 2450.00, 1999.00, 30, null, false, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtbtdFFJa1A0qOinWTVTZjYr1wFF33FzjDjxEZ_kHyQQ&s=10', true),
    ('11111111-1111-1111-1111-111111110022'::uuid, v_seller, c_dev, 'Accu-Chek Blood Glucose Monitor Kit', 'Kit', 'Roche Diabetes Care', 'Fast 5-second blood sugar testing meter with 10 test strips.', 'Electrochemical biosensor meter, lancet pen', 'Self-monitoring of blood glucose levels', 'Single-use lancets and strips', 1499.00, 1199.00, 45, null, false, 'https://rukminim1.flixcart.com/image/1600/2140/xif0q/glucometer/k/t/o/active-kit-active-kit-with-10-s-accu-chek-original-imah2ecdmfdstakx.jpeg?q=60', true),
    ('11111111-1111-1111-1111-111111110023'::uuid, v_seller, c_dev, 'Dr. Morepen Digital Clinical Thermometer', 'Piece', 'Dr. Morepen', 'Fast and precise digital clinical thermometer with beeper alert and LCD.', 'Digital thermistor with beeper and LCD readout', 'Accurate fever detection', 'Clean sensor tip with alcohol swab before use', 199.00, 149.00, 150, null, false, 'https://onemg.gumlet.io/l_watermark_346/a_ignore,c_fit,q_auto,f_auto/bcddbae8ee5d4f20925151bdca6cc854.jpg', true)
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    mrp = EXCLUDED.mrp,
    image_url = EXCLUDED.image_url;

  RAISE NOTICE 'Successfully seeded all 23 products into the database!';
END $$;

-- 5. Ensure non-recursive order policies exist for customer checkout & order view
CREATE OR REPLACE FUNCTION user_owns_order(p_order_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM orders WHERE id = p_order_id AND user_id = auth.uid());
$$;

CREATE OR REPLACE FUNCTION seller_has_order_item(p_order_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM order_items WHERE order_id = p_order_id AND seller_id = auth.uid());
$$;

DO $$
BEGIN
  -- Safe drop & recreate orders policies
  DROP POLICY IF EXISTS "orders insert own" ON orders;
  CREATE POLICY "orders insert own" ON orders FOR INSERT WITH CHECK (user_id = auth.uid());

  DROP POLICY IF EXISTS "orders read" ON orders;
  CREATE POLICY "orders read" ON orders FOR SELECT USING (user_id = auth.uid() OR is_admin() OR seller_has_order_item(id));

  DROP POLICY IF EXISTS "items insert own" ON order_items;
  CREATE POLICY "items insert own" ON order_items FOR INSERT WITH CHECK (true);

  DROP POLICY IF EXISTS "items read" ON order_items;
  CREATE POLICY "items read" ON order_items FOR SELECT USING (seller_id = auth.uid() OR is_admin() OR user_owns_order(order_id));
END $$;

-- 6. Ensure Storage Buckets exist for prescriptions and product images
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('prescriptions', 'prescriptions', false),
  ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;
