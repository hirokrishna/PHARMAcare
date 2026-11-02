// Seller dashboard functions

// check if current user is an approved seller
async function checkSellerAccess() {
  var user = await getCurrentUser();
  if (!user) {
    window.location.href = '/login.html';
    return null;
  }
  var profile = await getProfile(user.id);
  if (!profile || profile.role !== 'seller') {
    alert('This area is for sellers only.');
    window.location.href = '/index.html';
    return null;
  }

  // check seller approval status
  var res = await db.from('seller_profiles').select('status').eq('id', user.id).single();
  var sellerInfo = res.data;
  return { user, profile, sellerInfo };
}

// get products belonging to the current seller
async function getSellerProducts() {
  var user = await getCurrentUser();
  if (!user) return [];
  var res = await db.from('products')
    .select('*, categories(name)')
    .eq('seller_id', user.id)
    .order('created_at', { ascending: false });
  return res.data || [];
}

// get order items for the current seller
async function getSellerOrders() {
  var user = await getCurrentUser();
  if (!user) return [];
  var res = await db.from('order_items')
    .select('*, orders(order_no, status, created_at, address_snapshot)')
    .eq('seller_id', user.id)
    .order('orders(created_at)', { ascending: false });
  return res.data || [];
}
