-- ============================================
-- Admin Dashboard Database Setup
-- Run this script in your InsForge backend
-- ============================================

-- ==================== BANNERS TABLE ====================

CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  link TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- Admin policies
CREATE POLICY "Admins can do everything on banners"
  ON banners FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- User policies
CREATE POLICY "Users can view active banners"
  ON banners FOR SELECT
  USING (is_active = true);

-- ==================== POPUPS TABLE ====================

CREATE TABLE IF NOT EXISTS popups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('discount', 'announcement', 'welcome')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  image_url TEXT,
  button_text TEXT DEFAULT 'Got it',
  link TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE popups ENABLE ROW LEVEL SECURITY;

-- Admin policies
CREATE POLICY "Admins can do everything on popups"
  ON popups FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- User policies
CREATE POLICY "Users can view active popups"
  ON popups FOR SELECT
  USING (is_active = true);

-- ==================== DISCOUNTS TABLE ====================

CREATE TABLE IF NOT EXISTS discounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value NUMERIC NOT NULL CHECK (discount_value > 0),
  min_order_amount NUMERIC DEFAULT 0 CHECK (min_order_amount >= 0),
  max_discount NUMERIC CHECK (max_discount > 0),
  usage_limit INTEGER CHECK (usage_limit > 0),
  usage_count INTEGER DEFAULT 0,
  valid_from TIMESTAMP,
  valid_to TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT valid_dates CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to > valid_from)
);

-- Enable RLS
ALTER TABLE discounts ENABLE ROW LEVEL SECURITY;

-- Admin policies
CREATE POLICY "Admins can do everything on discounts"
  ON discounts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- User policies
CREATE POLICY "Users can view active discounts"
  ON discounts FOR SELECT
  USING (
    is_active = true
    AND (valid_from IS NULL OR valid_from <= NOW())
    AND (valid_to IS NULL OR valid_to >= NOW())
    AND (usage_limit IS NULL OR usage_count < usage_limit)
  );

-- ==================== INDEXES ====================

-- Banners indexes
CREATE INDEX IF NOT EXISTS idx_banners_active ON banners(is_active);
CREATE INDEX IF NOT EXISTS idx_banners_created_at ON banners(created_at DESC);

-- Popups indexes
CREATE INDEX IF NOT EXISTS idx_popups_active ON popups(is_active);
CREATE INDEX IF NOT EXISTS idx_popups_type ON popups(type);
CREATE INDEX IF NOT EXISTS idx_popups_created_at ON popups(created_at DESC);

-- Discounts indexes
CREATE INDEX IF NOT EXISTS idx_discounts_code ON discounts(code);
CREATE INDEX IF NOT EXISTS idx_discounts_active ON discounts(is_active);
CREATE INDEX IF NOT EXISTS idx_discounts_valid_dates ON discounts(valid_from, valid_to);
CREATE INDEX IF NOT EXISTS idx_discounts_created_at ON discounts(created_at DESC);

-- ==================== FUNCTIONS ====================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_banners_updated_at
  BEFORE UPDATE ON banners
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_popups_updated_at
  BEFORE UPDATE ON popups
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_discounts_updated_at
  BEFORE UPDATE ON discounts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to increment discount usage
CREATE OR REPLACE FUNCTION increment_discount_usage(discount_code TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE discounts
  SET usage_count = usage_count + 1
  WHERE code = discount_code;
END;
$$ LANGUAGE plpgsql;

-- ==================== SAMPLE DATA ====================

-- Sample banner
INSERT INTO banners (title, description, image_url, link, is_active)
VALUES (
  'Welcome to LoveNest',
  'Book your romantic getaway today!',
  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200&h=400&fit=crop',
  '/search',
  true
) ON CONFLICT DO NOTHING;

-- Sample popup
INSERT INTO popups (type, title, message, button_text, link, is_active)
VALUES (
  'welcome',
  'Welcome to LoveNest! 🎉',
  'Get 20% off on your first booking with code WELCOME20',
  'Browse Hotels',
  '/search',
  false
) ON CONFLICT DO NOTHING;

-- Sample discount
INSERT INTO discounts (
  code,
  description,
  discount_type,
  discount_value,
  min_order_amount,
  max_discount,
  usage_limit,
  valid_from,
  valid_to,
  is_active
)
VALUES (
  'WELCOME20',
  'Get 20% off on your first booking',
  'percentage',
  20,
  1000,
  500,
  100,
  NOW(),
  NOW() + INTERVAL '30 days',
  true
) ON CONFLICT (code) DO NOTHING;

-- ==================== VERIFICATION ====================

-- Check if tables were created
SELECT 
  'banners' as table_name,
  COUNT(*) as row_count
FROM banners
UNION ALL
SELECT 
  'popups' as table_name,
  COUNT(*) as row_count
FROM popups
UNION ALL
SELECT 
  'discounts' as table_name,
  COUNT(*) as row_count
FROM discounts;

-- ==================== CLEANUP (Optional) ====================

-- Uncomment to drop tables if you need to start fresh
-- DROP TABLE IF EXISTS banners CASCADE;
-- DROP TABLE IF EXISTS popups CASCADE;
-- DROP TABLE IF EXISTS discounts CASCADE;
-- DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
-- DROP FUNCTION IF EXISTS increment_discount_usage(TEXT) CASCADE;

-- ============================================
-- Setup Complete! ✅
-- ============================================
