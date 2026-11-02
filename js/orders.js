// js/orders.js - Order-related functions with resilient local cache & Supabase sync

// Local orders storage helpers for instant display resilience
function getLocalOrders(userId) {
  var key = 'pharmacare_orders_' + (userId || 'guest');
  try {
    return JSON.parse(localStorage.getItem(key)) || [];
  } catch (e) {
    return [];
  }
}

function saveLocalOrder(userId, order) {
  if (!order || !order.id) return;
  var orders = getLocalOrders(userId);
  orders = orders.filter(function (o) { return o.id !== order.id; });
  orders.unshift(order);
  var key = 'pharmacare_orders_' + (userId || 'guest');
  try {
    localStorage.setItem(key, JSON.stringify(orders));
  } catch (e) {
    console.warn('LocalStorage error saving order:', e);
  }
}

// Place order using the postgres atomic function
async function placeOrder(addressId, paymentMethod, prescriptionId) {
  var params = {
    p_address_id: addressId,
    p_payment_method: paymentMethod
  };
  if (prescriptionId) {
    params.p_prescription_id = prescriptionId;
  }
  var res = await db.rpc('place_order', params);
  return res;
}

// Cancel an order
async function cancelOrder(orderId) {
  var user = await getCurrentUser();
  if (user) {
    var local = getLocalOrders(user.id);
    local.forEach(function (o) {
      if (o.id === orderId) o.status = 'cancelled';
    });
    try {
      localStorage.setItem('pharmacare_orders_' + user.id, JSON.stringify(local));
    } catch (e) {}
  }
  var res = await db.rpc('cancel_order', { p_order_id: orderId });
  return res;
}

// Get orders for the current user (combines DB + local cache so orders never vanish)
async function getMyOrders() {
  var user = await getCurrentUser();
  if (!user) return [];

  var dbOrders = [];

  // 1. Try Supabase query with order items join
  try {
    var res = await db.from('orders')
      .select('*, order_items(id, product_name, quantity, price, item_status)')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (res && res.data && res.data.length > 0) {
      dbOrders = res.data;
    } else if (res && res.error) {
      console.warn('Notice from orders join query:', res.error.message);
      // Fallback query if policy recursion occurred on join
      var simpleRes = await db.from('orders')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });
      if (simpleRes && simpleRes.data && simpleRes.data.length > 0) {
        dbOrders = simpleRes.data;
      }
    }
  } catch (err) {
    console.warn('Database orders query notice:', err);
  }

  // 2. Read local order cache
  var localOrders = getLocalOrders(user.id);

  // 3. Merge cleanly (prefer DB order if available, but keep order_items from local snapshot if DB didn't return them)
  var merged = [];
  var seenIds = {};

  dbOrders.forEach(function (o) {
    var localMatch = localOrders.find(function (lo) { return lo.id === o.id; });
    if ((!o.order_items || o.order_items.length === 0) && localMatch && localMatch.order_items) {
      o.order_items = localMatch.order_items;
    }
    if (!o.order_no && localMatch && localMatch.order_no) {
      o.order_no = localMatch.order_no;
    }
    merged.push(o);
    seenIds[o.id] = true;
  });

  localOrders.forEach(function (lo) {
    if (!seenIds[lo.id]) {
      merged.push(lo);
      seenIds[lo.id] = true;
    }
  });

  return merged;
}
