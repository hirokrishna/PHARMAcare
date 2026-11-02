// Admin panel functions

// check admin access - redirect if not admin
async function checkAdminAccess() {
  var user = await getCurrentUser();
  if (!user) {
    window.location.href = '/login.html';
    return null;
  }
  var profile = await getProfile(user.id);
  if (!profile || profile.role !== 'admin') {
    alert('Admin access only.');
    window.location.href = '/index.html';
    return null;
  }
  return { user, profile };
}

// get all pending seller requests
async function getPendingSellers() {
  var res = await db.from('seller_profiles')
    .select('*, profiles(full_name, phone, created_at)')
    .eq('status', 'pending');
  return res.data || [];
}

// approve or reject a seller
async function updateSellerStatus(sellerId, newStatus) {
  var res = await db.from('seller_profiles')
    .update({ status: newStatus })
    .eq('id', sellerId);
  return !res.error;
}

// get all users
async function getAllUsers() {
  var res = await db.from('profiles').select('*').order('created_at', { ascending: false });
  return res.data || [];
}

// block or unblock a user
async function toggleUserBlock(userId, block) {
  var res = await db.from('profiles')
    .update({ is_blocked: block })
    .eq('id', userId);
  return !res.error;
}
