// products.js - Handles product data fetching with Supabase & built-in authentic catalog fallback

// 24 Authentic Healthcare and Pharmacy Products with valid UUID identifiers
var DEFAULT_PRODUCTS = [
  // --- All Medicines (Category 1) ---
  {
    id: "11111111-1111-1111-1111-111111110001",
    name: "Paracetamol 500 mg",
    category_id: 1,
    pack_info: "Tablet (10's)",
    manufacturer: "Cipla Ltd",
    description: "Paracetamol 500 mg tablet is a widely used antipyretic and analgesic medicine for mild to moderate pain and fever relief.",
    composition: "Paracetamol IP 500mg",
    uses: "Fever reduction, headache, toothache, back pain, muscular aches",
    side_effects: "Generally safe when taken as directed. Rare: skin rash, nausea in sensitive individuals",
    mrp: 25.00,
    price: 20.00,
    stock: 120,
    expiry_date: "2028-12-31",
    requires_prescription: false,
    image_url: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60",
    is_active: true,
    categories: { id: 1, name: "All Medicines" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110002",
    name: "Dolo 650 mg",
    category_id: 1,
    pack_info: "Tablet (15's)",
    manufacturer: "Micro Labs Ltd",
    description: "Dolo 650 is a trusted paracetamol formulation designed to relieve persistent fever and moderate bodily discomfort.",
    composition: "Paracetamol IP 650mg",
    uses: "High fever, viral fever, severe headache, body fatigue",
    side_effects: "Do not exceed recommended dose to avoid liver strain",
    mrp: 35.00,
    price: 29.00,
    stock: 200,
    expiry_date: "2028-10-31",
    requires_prescription: false,
    image_url: "https://images.apollo247.in/pub/media/catalog/product/D/O/DOL0026_1_1.jpg",
    is_active: true,
    categories: { id: 1, name: "All Medicines" },
    profiles: { full_name: "MedPlus Pharmacy" }
  },
  {
    id: "11111111-1111-1111-1111-111111110003",
    name: "Cetirizine 10 mg",
    category_id: 1,
    pack_info: "Tablet (10's)",
    manufacturer: "Dr. Reddy's Laboratories",
    description: "Cetirizine is a non-drowsy second-generation antihistamine used for seasonal allergies, running nose, and sneezing.",
    composition: "Cetirizine Dihydrochloride 10mg",
    uses: "Allergic rhinitis, hay fever, watery eyes, hives, skin itching",
    side_effects: "Mild sleepiness, dry mouth in some individuals",
    mrp: 40.00,
    price: 32.00,
    stock: 85,
    expiry_date: "2028-06-30",
    requires_prescription: false,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRdhtUW33FRmto90WOiJs-5lQvCEFchC1clFkEm_rr97rl8N_JXu6NifWv&s=10",
    is_active: true,
    categories: { id: 1, name: "All Medicines" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110004",
    name: "Omeprazole 20 mg",
    category_id: 1,
    pack_info: "Capsule (10's)",
    manufacturer: "Sun Pharma",
    description: "Omeprazole is a proton pump inhibitor (PPI) that decreases gastric acid production in the stomach lining.",
    composition: "Omeprazole IP 20mg",
    uses: "Acid reflux, gastroesophageal reflux disease (GERD), stomach ulcers",
    side_effects: "Headache, mild stomach cramp, flatulence",
    mrp: 72.00,
    price: 58.00,
    stock: 60,
    expiry_date: "2027-11-30",
    requires_prescription: true,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAs3D8Gy7NtLkgWeoQpfb2dUnh8grmPMrxVNcTbJ6u4g&s=10",
    is_active: true,
    categories: { id: 1, name: "All Medicines" },
    profiles: { full_name: "Wellness Forever Meds" }
  },
  {
    id: "11111111-1111-1111-1111-111111110005",
    name: "Amoxicillin 500 mg",
    category_id: 1,
    pack_info: "Capsule (10's)",
    manufacturer: "Abbott Healthcare",
    description: "Broad-spectrum penicillin antibiotic used to treat bacterial infections of the respiratory tract, ear, and throat.",
    composition: "Amoxicillin Trihydrate IP 500mg",
    uses: "Bacterial chest infection, ear infections, urinary infections",
    side_effects: "Nausea, diarrhea, mild rash. Complete full course as advised",
    mrp: 120.00,
    price: 96.00,
    stock: 45,
    expiry_date: "2027-09-30",
    requires_prescription: true,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7gDhuJ6jhdh5e-H1EdLYxmeDtec_lDRcHE6M1f0CunA&s=10",
    is_active: true,
    categories: { id: 1, name: "All Medicines" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110006",
    name: "Azithromycin 500 mg",
    category_id: 1,
    pack_info: "Tablet (3's)",
    manufacturer: "Cipla Ltd",
    description: "Macrolide antibiotic that stops the growth of bacteria causing respiratory, ear, and skin infections.",
    composition: "Azithromycin Dihydrate IP 500mg",
    uses: "Tonsillitis, sinusitis, bronchitis, skin infections",
    side_effects: "Mild abdominal discomfort, transient diarrhea",
    mrp: 115.00,
    price: 89.00,
    stock: 50,
    expiry_date: "2027-08-31",
    requires_prescription: true,
    image_url: "https://onemg.gumlet.io/l_watermark_346,w_480,h_480/a_ignore,w_480,h_480,c_fit,q_auto,f_auto/58ef49b897694a8e97be55842fadbe5b.jpg",
    is_active: true,
    categories: { id: 1, name: "All Medicines" },
    profiles: { full_name: "MedPlus Pharmacy" }
  },

  // --- Health Care (Category 2) ---
  {
    id: "11111111-1111-1111-1111-111111110007",
    name: "Digene Acidity Relief Gel",
    category_id: 2,
    pack_info: "Bottle (200 ml)",
    manufacturer: "Abbott India",
    description: "Scientifically developed antacid gel with fast action against hyperacidity, gas, and stomach heaviness.",
    composition: "Aluminium Hydroxide, Magnesium Hydroxide, Simethicone",
    uses: "Instant acidity relief, heartburn, bloated stomach",
    side_effects: "Safe when consumed in standard measured doses",
    mrp: 165.00,
    price: 145.00,
    stock: 75,
    expiry_date: "2028-05-31",
    requires_prescription: false,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROyIDFUNB7rwvmhIWDwbSnjPSAnZ6NVrvXpdMwxEJA_g&s=10",
    is_active: true,
    categories: { id: 2, name: "Health Care" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110008",
    name: "Volini Pain Relief Gel",
    category_id: 2,
    pack_info: "Tube (50 g)",
    manufacturer: "Sun Pharma",
    description: "Fast-acting pain relief topical gel designed for deep joint penetration and muscular sprain recovery.",
    composition: "Diclofenac Diethylamine 1.16% w/w, Linseed Oil, Menthol",
    uses: "Joint pain, neck stiffness, lower backache, sports sprains",
    side_effects: "Temporary warmth or slight redness on application area",
    mrp: 150.00,
    price: 125.00,
    stock: 90,
    expiry_date: "2028-04-30",
    requires_prescription: false,
    image_url: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&auto=format&fit=crop&q=60",
    is_active: true,
    categories: { id: 2, name: "Health Care" },
    profiles: { full_name: "Wellness Forever Meds" }
  },
  {
    id: "11111111-1111-1111-1111-111111110009",
    name: "Dettol Antiseptic Disinfectant Liquid",
    category_id: 2,
    pack_info: "Bottle (250 ml)",
    manufacturer: "Reckitt Benckiser",
    description: "Iconic antibacterial formula trusted for first-aid wound cleansing, personal hygiene, and surface disinfection.",
    composition: "Chloroxylenol (C8H9ClO) 4.8% w/v",
    uses: "Minor cuts, grazes, bites, surgical first-aid antiseptic wash",
    side_effects: "Dilute with clean water before direct skin application",
    mrp: 180.00,
    price: 155.00,
    stock: 110,
    expiry_date: "2029-01-31",
    requires_prescription: false,
    image_url: "https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=500&auto=format&fit=crop&q=60",
    is_active: true,
    categories: { id: 2, name: "Health Care" },
    profiles: { full_name: "MedPlus Pharmacy" }
  },

  // --- Personal Care (Category 3) ---
  {
    id: "11111111-1111-1111-1111-111111110010",
    name: "Nivea Soft Light Moisturizing Cream",
    category_id: 3,
    pack_info: "Jar (100 ml)",
    manufacturer: "Beiersdorf India",
    description: "Light and non-greasy refreshing moisturizing formula enriched with Jojoba Oil and antioxidant Vitamin E.",
    composition: "Aqua, Glycerin, Simmondsia Chinensis Seed Oil, Vitamin E",
    uses: "Daily face, hand, and body nourishing hydration",
    side_effects: "Dermatologically tested for normal and dry skin",
    mrp: 199.00,
    price: 159.00,
    stock: 65,
    expiry_date: "2028-07-31",
    requires_prescription: false,
    image_url: "https://www.quickpantry.in/cdn/shop/files/Nivea_Soft_Light_Moisturising_Cream_Quick_Pantry.png?v=1741294236",
    is_active: true,
    categories: { id: 3, name: "Personal Care" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110011",
    name: "Sebamed Gentle Cleansing Bar",
    category_id: 3,
    pack_info: "Bar (100 g)",
    manufacturer: "Sebapharma GmbH",
    description: "100% soap and alkali-free cleansing bar formulated at pH 5.5 to preserve the skin's natural acidic mantle.",
    composition: "Triticum Vulgare Starch, Disodium Lauryl Sulfosuccinate, Amino acids",
    uses: "Sensitive, acne-prone, and delicate skin daily cleansing",
    side_effects: "Gentle and non-comedogenic formulation",
    mrp: 240.00,
    price: 205.00,
    stock: 40,
    expiry_date: "2028-03-31",
    requires_prescription: false,
    image_url: "https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcQ-3WFQ6Wuq71yewMPnS9TLrInYYmjXb2ChuDpQ--_oHNZC4jUdaiF6OVfrkdYZ91DkzT7vXR0D3-vex-i41rEOJ7smu0ov",
    is_active: true,
    categories: { id: 3, name: "Personal Care" },
    profiles: { full_name: "Wellness Forever Meds" }
  },

  // --- Wellness (Category 4) ---
  {
    id: "11111111-1111-1111-1111-111111110012",
    name: "Vitamin C 500 mg with Zinc",
    category_id: 4,
    pack_info: "Tablet (30's)",
    manufacturer: "Torrent Pharmaceuticals",
    description: "Dual-action daily immunity booster tablets that provide antioxidant defense and collagen synthesis support.",
    composition: "Ascorbic Acid IP 500mg, Elemental Zinc 10mg",
    uses: "Immune defense, tissue repair, glowing skin, antioxidant health",
    side_effects: "Take after meals with water",
    mrp: 140.00,
    price: 110.00,
    stock: 180,
    expiry_date: "2028-09-30",
    requires_prescription: false,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUOH8URB1QrO4GVI980BBA1cNWVonEeaoDn5dVUHnulQ&s=10",
    is_active: true,
    categories: { id: 4, name: "Wellness" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110013",
    name: "Becosules Daily Multivitamin",
    category_id: 4,
    pack_info: "Capsule (20's)",
    manufacturer: "Pfizer Ltd",
    description: "Therapeutic vitamin B-complex with vitamin C capsules to restore cellular energy and combat fatigue.",
    composition: "Vitamin B1, B2, B6, B12, Niacinamide, Folic Acid, Vitamin C",
    uses: "Mouth ulcers, recovery from illness, energy boost, nerve health",
    side_effects: "Harmless bright yellow coloration of urine",
    mrp: 55.00,
    price: 46.00,
    stock: 140,
    expiry_date: "2028-02-28",
    requires_prescription: false,
    image_url: "https://images.unsplash.com/photo-1512069772995-ec65ed45afd6?w=500&auto=format&fit=crop&q=60",
    is_active: true,
    categories: { id: 4, name: "Wellness" },
    profiles: { full_name: "MedPlus Pharmacy" }
  },
  {
    id: "11111111-1111-1111-1111-111111110014",
    name: "Pure Omega-3 Fish Oil 1000 mg",
    category_id: 4,
    pack_info: "Softgel (60's)",
    manufacturer: "HealthKart Wellness",
    description: "Premium molecularly distilled deep-sea fish oil providing concentrated EPA and DHA fatty acids.",
    composition: "Fish Oil 1000mg providing EPA 180mg, DHA 120mg",
    uses: "Heart health, joint mobility, eyesight, cognitive function",
    side_effects: "Take with food to minimize mild fishy burps",
    mrp: 599.00,
    price: 449.00,
    stock: 70,
    expiry_date: "2027-10-31",
    requires_prescription: false,
    image_url: "https://onemg.gumlet.io/l_watermark_346,w_480,h_480/a_ignore,w_480,h_480,c_fit,q_auto,f_auto/8eadca6d3e64422695358026d813275c.jpg",
    is_active: true,
    categories: { id: 4, name: "Wellness" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },

  // --- Fitness (Category 5) ---
  {
    id: "11111111-1111-1111-1111-111111110015",
    name: "Optimum Nutrition Gold Whey Protein",
    category_id: 5,
    pack_info: "Tub (1 kg)",
    manufacturer: "Glanbia Performance",
    description: "World-renowned 100% whey protein isolate and concentrate blend with 24g protein per scoop for muscle recovery.",
    composition: "Whey Protein Isolate, Whey Concentrate, 5.5g BCAAs, Glutamine",
    uses: "Post-workout lean muscle protein synthesis and athletic endurance",
    side_effects: "Contains milk and soy ingredients",
    mrp: 3200.00,
    price: 2650.00,
    stock: 25,
    expiry_date: "2028-01-31",
    requires_prescription: false,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTy7wLRkcwR3b2vvkixgWI9OJWsseuzRmrZ8I7w078rOQ&s=10",
    is_active: true,
    categories: { id: 5, name: "Fitness" },
    profiles: { full_name: "Wellness Forever Meds" }
  },
  {
    id: "11111111-1111-1111-1111-111111110016",
    name: "Fast&Up Instant Electrolyte Drink",
    category_id: 5,
    pack_info: "Tube (20 tabs)",
    manufacturer: "Aeronutrix Sports",
    description: "Effervescent sports hydration tablets with essential electrolytes, B-vitamins, and Vitamin C for instant energy.",
    composition: "Sodium, Potassium, Magnesium, Calcium, Chloride, Vitamin C",
    uses: "Dehydration prevention, athletic cramp relief, instant stamina",
    side_effects: "Drop 1 tablet in 500ml water and wait until dissolved",
    mrp: 290.00,
    price: 235.00,
    stock: 95,
    expiry_date: "2027-12-31",
    requires_prescription: false,
    image_url: "https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcS6j6ozMnjOtZXsiJ-vEREq8zNDiBZwtGjfZULYBuFSxK_tmpAUOXk4MgjIsHdXcpDAhBwGWY8sqeAGPzx5VceZeqxOSNR1cZ7xO_-tEIknYlcJ21cctSdzfWcJ5OXY-AWX8xyhjA&usqp=CAc",
    is_active: true,
    categories: { id: 5, name: "Fitness" },
    profiles: { full_name: "MedPlus Pharmacy" }
  },

  // --- Baby Care (Category 6) ---
  {
    id: "11111111-1111-1111-1111-111111110017",
    name: "Pampers All Round Protection Diaper Pants",
    category_id: 6,
    pack_info: "Pack (28 pants)",
    manufacturer: "Procter & Gamble",
    description: "Soft breathable baby diaper pants with anti-rash lotion and magic gel core offering up to 12 hours dryness.",
    composition: "Air-circulation channels, Aloe Vera extract, Absorbent polymer",
    uses: "Overnight dryness, anti-rash baby protection, comfortable fit",
    side_effects: "Dermatologically tested and hypoallergenic",
    mrp: 499.00,
    price: 399.00,
    stock: 50,
    expiry_date: "2029-05-31",
    requires_prescription: false,
    image_url: "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTBRdFPMmmOGQtn3QAQbRalBWrzYAcHY8EBDLh_XZRaNoiqRSkHZdVsATuqQlLr1KsUr3XoJWSv7TYQ8jrAPwbzassIXeFTaM6eenMTgXVBFd6yK4JXPDs5kRN4iaErQ74R6pn_cPG2ewE&usqp=CAc",
    is_active: true,
    categories: { id: 6, name: "Baby Care" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110018",
    name: "Himalaya Gentle Baby Massage Oil",
    category_id: 6,
    pack_info: "Bottle (200 ml)",
    manufacturer: "Himalaya Wellness",
    description: "Nourishing pure herbal baby oil formulated with Olive Oil and Winter Cherry to support bone and muscle strength.",
    composition: "Olea Europaea (Olive Oil), Withania Somnifera (Winter Cherry)",
    uses: "Infant body massage, skin nourishment, improved blood circulation",
    side_effects: "Mineral-oil and paraben free",
    mrp: 185.00,
    price: 155.00,
    stock: 80,
    expiry_date: "2028-07-31",
    requires_prescription: false,
    image_url: "https://m.media-amazon.com/images/I/31No7EIqEmL._SY300_SX300_QL70_FMwebp_.jpg",
    is_active: true,
    categories: { id: 6, name: "Baby Care" },
    profiles: { full_name: "Wellness Forever Meds" }
  },

  // --- Ayurveda (Category 7) ---
  {
    id: "11111111-1111-1111-1111-111111110019",
    name: "Dabur Chyawanprash Awaleha",
    category_id: 7,
    pack_info: "Jar (500 g)",
    manufacturer: "Dabur India Ltd",
    description: "Authentic Ayurvedic rasayana fortified with 40+ vital herbs and natural vitamin C from fresh Amla.",
    composition: "Amla, Ashwagandha, Pippali, Shatavari, Giloy, Karkatshringi",
    uses: "Double immunity, cough & cold prevention, vitality and stamina",
    side_effects: "Recommended 1 teaspoon twice daily with warm milk",
    mrp: 245.00,
    price: 210.00,
    stock: 115,
    expiry_date: "2028-11-30",
    requires_prescription: false,
    image_url: "https://cdn.netmeds.tech/v2/plain-cake-860195/netmed/wrkr/products/pictures/item/free/resize-w:400/PVRRVFUTyl-dabur_chyawanprash_1_kg_0.jpg",
    is_active: true,
    categories: { id: 7, name: "Ayurveda" },
    profiles: { full_name: "MedPlus Pharmacy" }
  },
  {
    id: "11111111-1111-1111-1111-111111110020",
    name: "Baidyanath Pure Triphala Churna",
    category_id: 7,
    pack_info: "Bottle (100 g)",
    manufacturer: "Shree Baidyanath Ayurveda",
    description: "Classic Ayurvedic botanical blend of Haritaki, Bibhitaki, and Amalaki for digestive cleanse and gut health.",
    composition: "Harad (Terminalia chebula), Baheda, Amla in equal proportions",
    uses: "Digestive detox, bowel regularity, colon cleanse",
    side_effects: "Take 1-2 teaspoons before bed with warm water",
    mrp: 110.00,
    price: 92.00,
    stock: 60,
    expiry_date: "2028-08-31",
    requires_prescription: false,
    image_url: "https://m.media-amazon.com/images/I/41cpFc7oE1L._SY300_SX300_QL70_FMwebp_.jpg",
    is_active: true,
    categories: { id: 7, name: "Ayurveda" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },

  // --- Health Devices (Category 8) ---
  {
    id: "11111111-1111-1111-1111-111111110021",
    name: "Omron Blood Pressure Monitor HEM-7120",
    category_id: 8,
    pack_info: "Device with Cuff",
    manufacturer: "Omron Healthcare",
    description: "Clinically validated upper arm automatic digital blood pressure monitor with Intellisense precision technology.",
    composition: "Oscillometric sensor, digital LCD display, standard arm cuff",
    uses: "Accurate home blood pressure and pulse rate monitoring",
    side_effects: "Non-invasive electronic monitoring device",
    mrp: 2450.00,
    price: 1999.00,
    stock: 30,
    expiry_date: null,
    requires_prescription: false,
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtbtdFFJa1A0qOinWTVTZjYr1wFF33FzjDjxEZ_kHyQQ&s=10",
    is_active: true,
    categories: { id: 8, name: "Health Devices" },
    profiles: { full_name: "Apollo Pharmacy Store" }
  },
  {
    id: "11111111-1111-1111-1111-111111110022",
    name: "Accu-Chek Blood Glucose Monitor Kit",
    category_id: 8,
    pack_info: "Kit with 10 Strips",
    manufacturer: "Roche Diabetes Care",
    description: "Fast and easy-to-use blood glucose meter providing accurate blood sugar readings within 5 seconds.",
    composition: "Electrochemical biosensor meter, lancet pen, 10 sterile test strips",
    uses: "Self-monitoring of blood glucose levels for diabetes management",
    side_effects: "Single use lancets; dispose safely after testing",
    mrp: 1499.00,
    price: 1199.00,
    stock: 45,
    expiry_date: null,
    requires_prescription: false,
    image_url: "https://rukminim1.flixcart.com/image/1600/2140/xif0q/glucometer/k/t/o/active-kit-active-kit-with-10-s-accu-chek-original-imah2ecdmfdstakx.jpeg?q=60",
    is_active: true,
    categories: { id: 8, name: "Health Devices" },
    profiles: { full_name: "Wellness Forever Meds" }
  },
  {
    id: "11111111-1111-1111-1111-111111110023",
    name: "Dr. Morepen Digital Clinical Thermometer",
    category_id: 8,
    pack_info: "Piece in Case",
    manufacturer: "Dr. Morepen Laboratories",
    description: "High-precision digital clinical thermometer with beeper alert and memory recall for oral and axillary readings.",
    composition: "Stainless steel tip, digital sensor, LCD screen",
    uses: "Accurate fever detection for kids and adults",
    side_effects: "Clean probe tip with alcohol wipe before and after each use",
    mrp: 199.00,
    price: 149.00,
    stock: 150,
    expiry_date: null,
    requires_prescription: false,
    image_url: "https://onemg.gumlet.io/l_watermark_346/a_ignore,c_fit,q_auto,f_auto/bcddbae8ee5d4f20925151bdca6cc854.jpg",
    is_active: true,
    categories: { id: 8, name: "Health Devices" },
    profiles: { full_name: "MedPlus Pharmacy" }
  }
];

// 8 Base Categories
var DEFAULT_CATEGORIES = [
  { id: 1, name: "All Medicines", icon: "fa-pills" },
  { id: 2, name: "Health Care", icon: "fa-heart-pulse" },
  { id: 3, name: "Personal Care", icon: "fa-hand-sparkles" },
  { id: 4, name: "Wellness", icon: "fa-spa" },
  { id: 5, name: "Fitness", icon: "fa-dumbbell" },
  { id: 6, name: "Baby Care", icon: "fa-baby" },
  { id: 7, name: "Ayurveda", icon: "fa-leaf" },
  { id: 8, name: "Health Devices", icon: "fa-stethoscope" }
];

// Helper to look up fallback product by ID or Name
function getFallbackProduct(id, name) {
  for (var i = 0; i < DEFAULT_PRODUCTS.length; i++) {
    if (id && DEFAULT_PRODUCTS[i].id === id) {
      return DEFAULT_PRODUCTS[i];
    }
    if (name && DEFAULT_PRODUCTS[i].name && DEFAULT_PRODUCTS[i].name.toLowerCase() === name.toLowerCase()) {
      return DEFAULT_PRODUCTS[i];
    }
  }
  return null;
}

// Universal helper to ensure any product object gets the latest custom image and attributes
function enrichProduct(product) {
  if (!product) return product;
  var fallback = getFallbackProduct(product.id, product.name);
  if (fallback && fallback.image_url) {
    product.image_url = fallback.image_url;
  }
  return product;
}

// Fetch active products (with pagination, category filtering & text search)
async function getProducts(page, categoryId, searchText) {
  page = page || 0;
  var pageSize = 12;

  try {
    var query = db.from('products')
      .select('*, categories(name)')
      .eq('is_active', true);

    if (categoryId) {
      query = query.eq('category_id', categoryId);
    }
    if (searchText) {
      query = query.ilike('name', '%' + searchText + '%');
    }

    var from = page * pageSize;
    var to = from + pageSize - 1;
    var res = await query.order('created_at', { ascending: false }).range(from, to);

    if (res && res.data && res.data.length > 0) {
      // Allow any custom images updated in DEFAULT_PRODUCTS to take effect immediately
      return res.data.map(function (item) {
        return enrichProduct(item);
      });
    }
  } catch (err) {
    console.log('Fetching from Supabase failed, using built-in catalog:', err);
  }

  // Fallback to rich built-in catalog
  var filtered = DEFAULT_PRODUCTS.filter(function (p) {
    if (!p.is_active) return false;
    if (categoryId && p.category_id != categoryId) return false;
    if (searchText) {
      var term = searchText.toLowerCase();
      var matchName = (p.name || '').toLowerCase().includes(term);
      var matchComp = (p.composition || '').toLowerCase().includes(term);
      if (!matchName && !matchComp) return false;
    }
    return true;
  });

  var start = page * pageSize;
  return filtered.slice(start, start + pageSize);
}

// Fetch a single product by ID
async function getProduct(id) {
  if (!id) return null;

  try {
    var res = await db.from('products')
      .select('*, categories(name), profiles(full_name)')
      .eq('id', id)
      .maybeSingle();

    if (res && res.data) {
      return enrichProduct(res.data);
    }
  } catch (err) {
    console.log('Error fetching product from Supabase:', err);
  }

  // Fallback to built-in catalog
  return getFallbackProduct(id);
}

// Fetch all categories
async function getCategories() {
  try {
    var res = await db.from('categories').select('*').order('id');
    if (res && res.data && res.data.length > 0) {
      return res.data;
    }
  } catch (err) {
    console.log('Categories fetch failed, using default categories');
  }

  return DEFAULT_CATEGORIES;
}
