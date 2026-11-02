// js/cart.js - Cart functions with Supabase sync & localStorage resilience

// Local storage helper for session cart resilience
function getLocalCart(userId) {
  var key = 'pharmacare_cart_' + (userId || 'guest');
  try {
    return JSON.parse(localStorage.getItem(key)) || [];
  } catch (e) {
    return [];
  }
}

function saveLocalCart(userId, items) {
  var key = 'pharmacare_cart_' + (userId || 'guest');
  localStorage.setItem(key, JSON.stringify(items));
}

// Add item to cart (or increment quantity if already there)
async function addToCart(productId, quantity) {
  quantity = quantity || 1;
  var user = await getCurrentUser();
  if (!user) {
    // save the product and redirect to login
    localStorage.setItem('pending_product_id', productId);
    localStorage.setItem('redirect_after_login', window.location.href);
    window.location.href = '/login.html';
    return;
  }

  // 1. Calculate new quantity from existing cart
  var currentItems = await getCartItems();
  var existingItem = currentItems.find(function(it) {
    return it.product_id === productId;
  });

  var newQty = quantity;
  if (existingItem) {
    newQty = Math.min(10, existingItem.quantity + quantity);
  }

  var savedInDb = false;

  // 2. Attempt Supabase cart_items upsert
  try {
    var res = await db.from('cart_items').upsert(
      { user_id: user.id, product_id: productId, quantity: newQty },
      { onConflict: 'user_id,product_id' }
    );
    if (!res.error) {
      savedInDb = true;
    } else {
      console.log('Notice: Database cart sync skipped (local cart will be used):', res.error.message);
    }
  } catch (err) {
    console.log('Supabase cart error, falling back to local storage:', err);
  }

  // 3. Always maintain cart in localStorage so user never loses items or gets blocked
  var localItems = getLocalCart(user.id);
  var found = false;
  for (var i = 0; i < localItems.length; i++) {
    if (localItems[i].product_id === productId) {
      localItems[i].quantity = newQty;
      found = true;
      break;
    }
  }

  if (!found) {
    var prodObj = typeof getFallbackProduct === 'function' ? getFallbackProduct(productId) : null;
    localItems.push({
      id: 'local-' + Date.now(),
      user_id: user.id,
      product_id: productId,
      quantity: newQty,
      products: prodObj
    });
  }
  saveLocalCart(user.id, localItems);

  showToast('Added to cart', 'success');
  await updateCartCount();
}

// Get all cart items for current user with full product details
async function getCartItems() {
  var user = await getCurrentUser();
  if (!user) return [];

  var dbItems = [];
  try {
    var res = await db.from('cart_items')
      .select('id, quantity, product_id, products(id, name, pack_info, price, mrp, image_url, stock, requires_prescription)')
      .eq('user_id', user.id);
    if (res && res.data && res.data.length > 0) {
      dbItems = res.data;
    }
  } catch (e) {
    console.log('Error reading cart from db:', e);
  }

  var localItems = getLocalCart(user.id);

  // Merge dbItems and localItems cleanly
  var merged = [];
  var seenProductIds = {};

  dbItems.forEach(function(item) {
    if (!item.products && typeof getFallbackProduct === 'function') {
      item.products = getFallbackProduct(item.product_id);
    }
    if (item.products && typeof enrichProduct === 'function') {
      item.products = enrichProduct(item.products);
    }
    merged.push(item);
    seenProductIds[item.product_id] = true;
  });

  localItems.forEach(function(item) {
    if (!seenProductIds[item.product_id]) {
      if (!item.products && typeof getFallbackProduct === 'function') {
        item.products = getFallbackProduct(item.product_id);
      }
      if (item.products && typeof enrichProduct === 'function') {
        item.products = enrichProduct(item.products);
      }
      merged.push(item);
      seenProductIds[item.product_id] = true;
    }
  });

  return merged;
}

// Update quantity for a cart item
async function updateCartQty(cartItemId, newQty) {
  var user = await getCurrentUser();
  if (!user) return false;

  // Handle local item
  var localItems = getLocalCart(user.id);
  for (var i = 0; i < localItems.length; i++) {
    if (localItems[i].id === cartItemId || localItems[i].product_id === cartItemId) {
      localItems[i].quantity = newQty;
      saveLocalCart(user.id, localItems);
      break;
    }
  }

  // Handle db item
  if (!String(cartItemId).startsWith('local-')) {
    try {
      await db.from('cart_items')
        .update({ quantity: newQty })
        .eq('id', cartItemId);
    } catch (e) {
      console.log('Error updating db cart item:', e);
    }
  }

  return true;
}

// Remove an item from cart
async function removeFromCart(cartItemId) {
  var user = await getCurrentUser();
  if (!user) return false;

  // Remove from local storage
  var localItems = getLocalCart(user.id);
  localItems = localItems.filter(function(it) {
    return it.id !== cartItemId && it.product_id !== cartItemId;
  });
  saveLocalCart(user.id, localItems);

  // Remove from Supabase db if not local
  if (!String(cartItemId).startsWith('local-')) {
    try {
      await db.from('cart_items')
        .delete()
        .eq('id', cartItemId);
    } catch (e) {
      console.log('Error deleting db cart item:', e);
    }
  }

  return true;
}

// Total count of items in cart (sum of quantities)
async function getCartCount() {
  var user = await getCurrentUser();
  if (!user) return 0;
  var items = await getCartItems();
  var total = 0;
  items.forEach(function(item) { total += (item.quantity || 1); });
  return total;
}

// Update the cart badge in the navbar
async function updateCartCount() {
  var count = await getCartCount();
  var badge = document.getElementById('cart-count');
  if (badge) {
    badge.textContent = count;
    badge.style.display = count > 0 ? 'flex' : 'none';
  }
}
