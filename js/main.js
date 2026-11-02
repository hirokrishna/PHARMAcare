// main.js - runs on every page
// handles: navbar, footer, cart count, toast, hamburger menu

// build and inject navbar HTML
function buildNavbar() {
  var currentPage = window.location.pathname;

  function isActive(path) {
    return currentPage === path || currentPage.endsWith(path) ? 'active' : '';
  }

  var navHtml = `
    <nav class="navbar">
      <div class="container nav-inner">
        <a href="/index.html" class="nav-logo">
          <img src="/images/logo.png" alt="PHARMAcare" height="50">
        </a>

        <button class="hamburger" id="hamburger-btn" aria-label="Open menu">
          <i class="fas fa-bars"></i>
        </button>

        <ul class="nav-links" id="nav-links">
          <li><a href="/index.html" class="${isActive('/index.html')}">Home</a></li>
          <li><a href="/medicines.html" class="${isActive('/medicines.html')}">Medicines</a></li>
          <li class="dropdown">
            <a href="#">Healthcare <i class="fas fa-chevron-down"></i></a>
            <ul class="dropdown-menu">
              <li><a href="/medicines.html?cat=2">Health Care</a></li>
              <li><a href="/medicines.html?cat=3">Personal Care</a></li>
              <li><a href="/medicines.html?cat=4">Wellness</a></li>
              <li><a href="/medicines.html?cat=5">Fitness</a></li>
              <li><a href="/medicines.html?cat=6">Baby Care</a></li>
              <li><a href="/medicines.html?cat=7">Ayurveda</a></li>
              <li><a href="/medicines.html?cat=8">Health Devices</a></li>
            </ul>
          </li>
          <li><a href="/offers.html" class="${isActive('/offers.html')}">Offers</a></li>
          <li><a href="/about.html" class="${isActive('/about.html')}">About Us</a></li>
          <li><a href="/contact.html" class="${isActive('/contact.html')}">Contact</a></li>
        </ul>

        <div class="nav-right">
          <a href="/cart.html" class="cart-link">
            <i class="fas fa-cart-shopping"></i>
            <span id="cart-count" class="cart-badge" style="display:none">0</span>
          </a>
          <div id="user-area">
            <a href="/login.html" class="btn btn-outline-green">Login</a>
            <a href="/register.html" class="btn btn-navy">Register</a>
          </div>
        </div>
      </div>
    </nav>
  `;

  var placeholder = document.getElementById('navbar-placeholder');
  if (placeholder) {
    placeholder.innerHTML = navHtml;
  }

  // hamburger toggle
  var hamburgerBtn = document.getElementById('hamburger-btn');
  var navLinks = document.getElementById('nav-links');
  if (hamburgerBtn && navLinks) {
    hamburgerBtn.addEventListener('click', function() {
      navLinks.classList.toggle('open');
    });
  }
}

// build and inject footer HTML
function buildFooter() {
  var footerHtml = `
    <footer class="footer">
      <div class="container footer-grid">
        <div class="footer-col">
          <img src="/images/logo.png" alt="PHARMAcare" height="45" class="footer-logo">
          <p class="footer-about">Your trusted online pharmacy for genuine medicines and healthcare products.</p>
        </div>
        <div class="footer-col">
          <h4>Quick Links</h4>
          <ul>
            <li><a href="/index.html">Home</a></li>
            <li><a href="/medicines.html">Medicines</a></li>
            <li><a href="/offers.html">Offers</a></li>
            <li><a href="/about.html">About Us</a></li>
            <li><a href="/contact.html">Contact</a></li>
          </ul>
        </div>
        <div class="footer-col">
          <h4>Categories</h4>
          <ul>
            <li><a href="/medicines.html?cat=1">All Medicines</a></li>
            <li><a href="/medicines.html?cat=2">Health Care</a></li>
            <li><a href="/medicines.html?cat=3">Personal Care</a></li>
            <li><a href="/medicines.html?cat=4">Wellness</a></li>
            <li><a href="/medicines.html?cat=6">Baby Care</a></li>
            <li><a href="/medicines.html?cat=7">Ayurveda</a></li>
          </ul>
        </div>
        <div class="footer-col">
          <h4>Contact</h4>
          <p><i class="fas fa-envelope"></i> support@pharmacare.com</p>
          <p><i class="fas fa-phone"></i> +91 98765 43210</p>
          <p><i class="fas fa-location-dot"></i> Mumbai, Maharashtra, India</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p>Medicines should be taken as per doctor's advice.</p>
        <p>&copy; 2026 PHARMAcare &ndash; College Project</p>
      </div>
    </footer>
  `;

  var placeholder = document.getElementById('footer-placeholder');
  if (placeholder) {
    placeholder.innerHTML = footerHtml;
  }
}

// update the user area in navbar based on login state
async function updateUserArea() {
  var userArea = document.getElementById('user-area');
  if (!userArea) return;

  var res = await db.auth.getUser();
  var user = res.data.user;

  if (!user) {
    // not logged in
    userArea.innerHTML = `
      <a href="/login.html" class="btn btn-outline-green">Login</a>
      <a href="/register.html" class="btn btn-navy">Register</a>
    `;
    return;
  }

  // get profile for name and role
  var profileRes = await db.from('profiles').select('full_name, role').eq('id', user.id).single();
  var profile = profileRes.data;
  var name = profile ? profile.full_name.split(' ')[0] : 'User';
  var role = profile ? profile.role : 'customer';

  var dashLink = '';
  if (role === 'seller') dashLink = '<li><a href="/seller/dashboard.html">Seller Dashboard</a></li>';
  if (role === 'admin') dashLink = '<li><a href="/admin/dashboard.html">Admin Panel</a></li>';

  userArea.innerHTML = `
    <div class="user-dropdown">
      <button class="user-btn">
        <i class="fas fa-user"></i> Hi, ${name} <i class="fas fa-chevron-down"></i>
      </button>
      <ul class="user-menu">
        <li><a href="/profile.html">My Profile</a></li>
        <li><a href="/my-orders.html">My Orders</a></li>
        <li><a href="/wishlist.html">Wishlist</a></li>
        ${dashLink}
        <li><a href="#" onclick="logout()">Logout</a></li>
      </ul>
    </div>
  `;

  // toggle user menu dropdown on click
  var userBtn = userArea.querySelector('.user-btn');
  var userMenu = userArea.querySelector('.user-menu');
  if (userBtn && userMenu) {
    userBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      userMenu.classList.toggle('open');
    });
    document.addEventListener('click', function() {
      userMenu.classList.remove('open');
    });
  }
}

// check for pending cart item after login redirect
async function checkPendingCart() {
  var res = await db.auth.getUser();
  if (!res.data.user) return;

  var pendingId = localStorage.getItem('pending_product_id');
  if (pendingId) {
    localStorage.removeItem('pending_product_id');
    await addToCart(pendingId, 1);
  }

  // redirect to original page if set
  var redirectUrl = localStorage.getItem('redirect_after_login');
  if (redirectUrl && window.location.pathname.includes('login')) {
    localStorage.removeItem('redirect_after_login');
    window.location.href = redirectUrl;
  }
}

// show a small toast message at top-right
// type: 'success' or 'error'
function showToast(message, type) {
  var toast = document.getElementById('toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.className = 'toast toast-' + (type || 'success');
  toast.style.display = 'block';

  clearTimeout(window._toastTimer);
  window._toastTimer = setTimeout(function() {
    toast.style.display = 'none';
  }, 3000);
}

// logout function (also in auth.js but needed here for onclick in template)
async function logout() {
  await db.auth.signOut();
  window.location.href = '/index.html';
}

// run on every page load
document.addEventListener('DOMContentLoaded', async function() {
  buildNavbar();
  buildFooter();
  await updateUserArea();
  await updateCartCount();
  await checkPendingCart();
});
