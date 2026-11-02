// Authentication helpers

// get the current logged-in user (returns null if not logged in)
async function getCurrentUser() {
  var res = await db.auth.getUser();
  return res.data.user || null;
}

// get the profile row from the profiles table
async function getProfile(userId) {
  var res = await db.from('profiles').select('*').eq('id', userId).single();
  return res.data || null;
}

// redirect to login if not logged in
async function requireLogin() {
  var user = await getCurrentUser();
  if (!user) {
    // save current page so we can come back after login
    localStorage.setItem('redirect_after_login', window.location.href);
    window.location.href = '/login.html';
  }
  return user;
}

// redirect if user does not have required role
// roles is an array like ['seller'] or ['admin']
async function requireRole(roles) {
  var user = await requireLogin();
  if (!user) return null;
  var profile = await getProfile(user.id);
  if (!profile || !roles.includes(profile.role)) {
    alert('You do not have permission to view this page.');
    window.location.href = '/index.html';
    return null;
  }
  return profile;
}

// sign out the user
async function logout() {
  await db.auth.signOut();
  window.location.href = '/index.html';
}
