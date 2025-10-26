import { useState } from 'react';
import { Store, ShoppingCart as CartIcon } from 'lucide-react';
import { ProductCatalog } from './components/ProductCatalog';
import { ShoppingCart } from './components/ShoppingCart';
import { LiveChat } from './components/LiveChat';
import { Product } from './types';
import { supabase, getSessionId } from './lib/supabase';

function App() {
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [cartCount, setCartCount] = useState(0);
  const [cartUpdateTrigger, setCartUpdateTrigger] = useState(0);

  async function handleAddToCart(product: Product) {
    try {
      const sessionId = getSessionId();

      const { data: existing } = await supabase
        .from('cart_items')
        .select('*')
        .eq('session_id', sessionId)
        .eq('product_id', product.id)
        .maybeSingle();

      if (existing) {
        await supabase
          .from('cart_items')
          .update({
            quantity: existing.quantity + 1,
            updated_at: new Date().toISOString()
          })
          .eq('id', existing.id);
      } else {
        await supabase.from('cart_items').insert({
          session_id: sessionId,
          product_id: product.id,
          quantity: 1
        });
      }

      setCartUpdateTrigger(prev => prev + 1);
      updateCartCount();
    } catch (error) {
      console.error('Error adding to cart:', error);
    }
  }

  async function updateCartCount() {
    try {
      const sessionId = getSessionId();
      const { data } = await supabase
        .from('cart_items')
        .select('quantity')
        .eq('session_id', sessionId);

      const count = data?.reduce((sum, item) => sum + item.quantity, 0) || 0;
      setCartCount(count);
    } catch (error) {
      console.error('Error updating cart count:', error);
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <header className="bg-white shadow-md sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <Store className="w-8 h-8 text-blue-600" />
              <h1 className="text-2xl font-bold text-gray-900">ShopHub</h1>
            </div>

            <button
              onClick={() => setIsCartOpen(true)}
              className="relative flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
            >
              <CartIcon className="w-5 h-5" />
              <span className="font-medium">Cart</span>
              {cartCount > 0 && (
                <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center">
                  {cartCount}
                </span>
              )}
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Discover Amazing Products
          </h2>
          <p className="text-gray-600">
            Browse our curated collection of premium items
          </p>
        </div>

        <ProductCatalog onAddToCart={handleAddToCart} />
      </main>

      <ShoppingCart
        isOpen={isCartOpen}
        onClose={() => setIsCartOpen(false)}
        cartUpdateTrigger={cartUpdateTrigger}
      />

      <LiveChat />
    </div>
  );
}

export default App;
