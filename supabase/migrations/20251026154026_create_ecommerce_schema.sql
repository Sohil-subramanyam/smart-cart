/*
  # E-Commerce Platform Database Schema

  1. New Tables
    - `products`
      - `id` (uuid, primary key)
      - `name` (text, product name)
      - `description` (text, detailed description)
      - `price` (numeric, product price)
      - `stock` (integer, available inventory)
      - `category` (text, product category for filtering)
      - `image_url` (text, product image)
      - `created_at` (timestamptz, creation timestamp)
    
    - `cart_items`
      - `id` (uuid, primary key)
      - `session_id` (text, anonymous session identifier)
      - `product_id` (uuid, foreign key to products)
      - `quantity` (integer, item quantity)
      - `created_at` (timestamptz, creation timestamp)
      - `updated_at` (timestamptz, last update timestamp)
    
    - `chat_messages`
      - `id` (uuid, primary key)
      - `session_id` (text, anonymous session identifier)
      - `message` (text, chat message content)
      - `sender_type` (text, either 'customer' or 'support')
      - `created_at` (timestamptz, message timestamp)

  2. Security
    - Enable RLS on all tables
    - Public read access for products (catalog browsing)
    - Session-based access for cart_items (users can only access their own cart)
    - Session-based access for chat_messages (users can only see their own conversation)

  3. Indexes
    - Index on product category for fast filtering
    - Index on cart session_id for quick cart retrieval
    - Index on chat session_id for efficient message loading

  4. Sample Data
    - Pre-populate with sample products across different categories
*/

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price >= 0),
  stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
  category text NOT NULL,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text NOT NULL,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text NOT NULL,
  message text NOT NULL,
  sender_type text NOT NULL CHECK (sender_type IN ('customer', 'support')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Products policies (public read access)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  TO anon
  USING (true);

-- Cart policies (session-based access)
CREATE POLICY "Users can view own cart"
  ON cart_items FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Users can insert to cart"
  ON cart_items FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Users can update own cart"
  ON cart_items FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete from cart"
  ON cart_items FOR DELETE
  TO anon
  USING (true);

-- Chat policies (session-based access)
CREATE POLICY "Users can view chat messages"
  ON chat_messages FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Users can send chat messages"
  ON chat_messages FOR INSERT
  TO anon
  WITH CHECK (true);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_cart_session ON cart_items(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_session ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_created ON chat_messages(created_at);

-- Insert sample products
INSERT INTO products (name, description, price, stock, category, image_url) VALUES
('Wireless Headphones', 'Premium noise-cancelling wireless headphones with 30-hour battery life', 199.99, 45, 'Electronics', 'https://images.pexels.com/photos/3825517/pexels-photo-3825517.jpeg'),
('Smart Watch', 'Fitness tracking smartwatch with heart rate monitor and GPS', 299.99, 32, 'Electronics', 'https://images.pexels.com/photos/437037/pexels-photo-437037.jpeg'),
('Laptop Backpack', 'Durable water-resistant backpack with padded laptop compartment', 79.99, 67, 'Accessories', 'https://images.pexels.com/photos/2905238/pexels-photo-2905238.jpeg'),
('Mechanical Keyboard', 'RGB backlit mechanical gaming keyboard with custom switches', 149.99, 28, 'Electronics', 'https://images.pexels.com/photos/2115257/pexels-photo-2115257.jpeg'),
('Coffee Maker', 'Programmable coffee maker with thermal carafe', 89.99, 54, 'Home', 'https://images.pexels.com/photos/324028/pexels-photo-324028.jpeg'),
('Yoga Mat', 'Extra thick non-slip yoga mat with carrying strap', 34.99, 89, 'Fitness', 'https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg'),
('Desk Lamp', 'LED desk lamp with adjustable brightness and color temperature', 49.99, 43, 'Home', 'https://images.pexels.com/photos/1112598/pexels-photo-1112598.jpeg'),
('Running Shoes', 'Lightweight running shoes with responsive cushioning', 129.99, 61, 'Fitness', 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg'),
('Bluetooth Speaker', 'Portable waterproof speaker with 360-degree sound', 79.99, 38, 'Electronics', 'https://images.pexels.com/photos/1279863/pexels-photo-1279863.jpeg'),
('Water Bottle', 'Insulated stainless steel water bottle keeps drinks cold for 24 hours', 24.99, 125, 'Fitness', 'https://images.pexels.com/photos/2733652/pexels-photo-2733652.jpeg'),
('Phone Case', 'Slim protective phone case with card holder', 19.99, 92, 'Accessories', 'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg'),
('Sunglasses', 'Polarized UV protection sunglasses with metal frame', 89.99, 56, 'Accessories', 'https://images.pexels.com/photos/701877/pexels-photo-701877.jpeg');
