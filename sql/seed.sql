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
