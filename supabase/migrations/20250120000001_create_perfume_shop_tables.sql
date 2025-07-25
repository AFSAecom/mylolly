-- Create users table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  nom TEXT NOT NULL,
  prenom TEXT NOT NULL,
  telephone TEXT,
  whatsapp TEXT,
  date_naissance DATE,
  adresse TEXT,
  role TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'conseillere', 'admin')),
  code_client TEXT UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create products table
CREATE TABLE IF NOT EXISTS public.products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code_produit TEXT UNIQUE NOT NULL,
  nom_lolly TEXT NOT NULL,
  nom_parfum_inspire TEXT NOT NULL,
  marque_inspire TEXT NOT NULL,
  genre TEXT NOT NULL CHECK (genre IN ('homme', 'femme', 'mixte')),
  saison TEXT NOT NULL CHECK (saison IN ('été', 'hiver', 'toutes saisons')),
  famille_olfactive TEXT NOT NULL,
  note_tete TEXT[],
  note_coeur TEXT[],
  note_fond TEXT[],
  description TEXT,
  image_url TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create product variants table (for different sizes and prices)
CREATE TABLE IF NOT EXISTS public.product_variants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  ref_complete TEXT UNIQUE NOT NULL,
  contenance INTEGER NOT NULL,
  unite TEXT NOT NULL DEFAULT 'ml',
  prix DECIMAL(10,3) NOT NULL,
  stock_actuel INTEGER DEFAULT 0,
  actif BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create favorites table
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  code_client TEXT NOT NULL,
  total_amount DECIMAL(10,3) NOT NULL,
  status TEXT NOT NULL DEFAULT 'en_attente' CHECK (status IN ('en_attente', 'confirmee', 'expediee', 'livree', 'annulee')),
  conseillere_id UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create order items table
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  product_variant_id UUID REFERENCES public.product_variants(id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,3) NOT NULL,
  total_price DECIMAL(10,3) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create promotions table
CREATE TABLE IF NOT EXISTS public.promotions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nom TEXT NOT NULL,
  description TEXT,
  pourcentage_reduction DECIMAL(5,2) NOT NULL,
  date_debut DATE NOT NULL,
  date_fin DATE NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create stock movements table for tracking inventory changes
CREATE TABLE IF NOT EXISTS public.stock_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_variant_id UUID REFERENCES public.product_variants(id),
  type TEXT NOT NULL CHECK (type IN ('entree', 'sortie', 'ajustement')),
  quantity INTEGER NOT NULL,
  reason TEXT,
  reference_document TEXT,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample data
INSERT INTO public.products (code_produit, nom_lolly, nom_parfum_inspire, marque_inspire, genre, saison, famille_olfactive, note_tete, note_coeur, note_fond, description, image_url) VALUES
('L001', 'Élégance Nocturne', 'Black Opium', 'Yves Saint Laurent', 'femme', 'toutes saisons', 'Oriental Vanillé', ARRAY['Café', 'Poire', 'Mandarine'], ARRAY['Jasmin', 'Fleur d''oranger', 'Vanille'], ARRAY['Patchouli', 'Cèdre', 'Musc'], 'Une fragrance envoûtante qui mêle l''intensité du café à la douceur de la vanille, créant une signature olfactive addictive et mystérieuse.', 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=500&q=80'),
('L002', 'Aura Marine', 'Acqua di Gio', 'Giorgio Armani', 'homme', 'été', 'Aromatique Aquatique', ARRAY['Bergamote', 'Néroli'], ARRAY['Romarin', 'Persil', 'Jasmin'], ARRAY['Bois de cèdre', 'Musc', 'Ambre'], 'Une fragrance fraîche et marine inspirée par la mer Méditerranée.', 'https://images.unsplash.com/photo-1547887538-e3a2f32cb1cc?w=400&q=80'),
('L003', 'Séduction Florale', 'J''adore', 'Dior', 'femme', 'toutes saisons', 'Floral Fruité', ARRAY['Bergamote', 'Poire', 'Melon'], ARRAY['Rose de Mai', 'Jasmin', 'Magnolia'], ARRAY['Musc', 'Bois de cèdre'], 'Un bouquet floral sophistiqué et élégant aux notes délicates.', 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400&q=80');

-- Insert product variants
INSERT INTO public.product_variants (product_id, ref_complete, contenance, unite, prix, stock_actuel) 
SELECT 
  p.id,
  p.code_produit || '-' || v.size,
  v.size::integer,
  'ml',
  v.price,
  v.stock
FROM public.products p
CROSS JOIN (
  VALUES 
    (15, 19.900, 25),
    (30, 29.900, 18),
    (50, 39.900, 10)
) AS v(size, price, stock)
WHERE p.code_produit IN ('L001', 'L002', 'L003');

-- Insert sample promotions
INSERT INTO public.promotions (nom, description, pourcentage_reduction, date_debut, date_fin) VALUES
('Soldes d''Hiver', 'Promotion de fin d''année sur tous les parfums', 20.00, '2025-01-01', '2025-01-31'),
('Nouvelle Année', 'Remise spéciale Nouvelle Année', 10.00, '2025-01-01', '2025-02-28');

-- Enable realtime for all tables
alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.products;
alter publication supabase_realtime add table public.product_variants;
alter publication supabase_realtime add table public.favorites;
alter publication supabase_realtime add table public.orders;
alter publication supabase_realtime add table public.order_items;
alter publication supabase_realtime add table public.promotions;
alter publication supabase_realtime add table public.stock_movements;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_products_code_produit ON public.products(code_produit);
CREATE INDEX IF NOT EXISTS idx_products_active ON public.products(active);
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON public.product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_product_variants_ref_complete ON public.product_variants(ref_complete);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product_variant_id ON public.stock_movements(product_variant_id);

-- Create functions for automatic timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamps
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_product_variants_updated_at BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_promotions_updated_at BEFORE UPDATE ON public.promotions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();