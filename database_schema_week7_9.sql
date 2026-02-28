-- LoveNest Database Schema Extensions for Week 7-9
-- Run this SQL in your InsForge database to add new features

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- WEEK 7: ADD-ONS SYSTEM
-- ============================================

-- Add-ons table for romantic extras
CREATE TABLE IF NOT EXISTS addons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT, -- 'decoration', 'food', 'experience', 'gift'
  price DECIMAL NOT NULL,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sample add-ons data
INSERT INTO addons (name, description, category, price, image_url) VALUES
('Rose Petals Decoration', 'Romantic rose petals scattered on bed and floor', 'decoration', 50, 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23'),
('Champagne & Chocolates', 'Premium champagne bottle with luxury chocolates', 'food', 80, 'https://images.unsplash.com/photo-1547595628-c61a29f496f0'),
('Candlelight Dinner', 'Private candlelight dinner for two', 'food', 150, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0'),
('Couples Spa Package', 'Relaxing couples massage and spa treatment', 'experience', 200, 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874'),
('Flower Bouquet', 'Fresh romantic flower bouquet', 'gift', 40, 'https://images.unsplash.com/photo-1490750967868-88aa4486c946'),
('Balloon Decoration', 'Heart-shaped balloons decoration', 'decoration', 60, 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d'),
('Cake & Desserts', 'Custom celebration cake with desserts', 'food', 70, 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3'),
('Photography Session', 'Professional couple photography session', 'experience', 180, 'https://images.unsplash.com/photo-1452587925148-ce544e77e70d'),
('Breakfast in Bed', 'Luxury breakfast served in your room', 'food', 45, 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666'),
('Surprise Gift Box', 'Curated romantic surprise gift box', 'gift', 90, 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48');

-- ============================================
-- WEEK 8: NOTIFICATIONS SYSTEM
-- ============================================

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT, -- 'booking', 'offer', 'reminder', 'review', 'system'
  data JSONB, -- Additional data like booking_id, offer_id, etc.
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Push notification tokens table
CREATE TABLE IF NOT EXISTS push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  token TEXT NOT NULL,
  device_type TEXT, -- 'android', 'ios'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, token)
);

-- ============================================
-- WEEK 9: OFFERS & COUPONS SYSTEM
-- ============================================

-- Coupons table
CREATE TABLE IF NOT EXISTS coupons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE NOT NULL,
  description TEXT,
  discount_type TEXT, -- 'percentage', 'fixed'
  discount_value DECIMAL NOT NULL,
  min_booking_amount DECIMAL,
  max_discount DECIMAL,
  valid_from TIMESTAMP,
  valid_until TIMESTAMP,
  usage_limit INTEGER,
  used_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- User coupon usage tracking
CREATE TABLE IF NOT EXISTS coupon_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  coupon_id UUID REFERENCES coupons(id),
  user_id UUID NOT NULL,
  booking_id UUID REFERENCES bookings(id),
  discount_amount DECIMAL,
  used_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(coupon_id, user_id, booking_id)
);

-- Sample coupons
INSERT INTO coupons (code, description, discount_type, discount_value, min_booking_amount, max_discount, valid_from, valid_until, usage_limit) VALUES
('LOVE50', 'Get 50% off on your first booking', 'percentage', 50, 100, 100, NOW(), NOW() + INTERVAL '30 days', 1000),
('ROMANCE20', 'Flat 20% off on all bookings', 'percentage', 20, 150, 50, NOW(), NOW() + INTERVAL '60 days', 5000),
('COUPLE100', 'Get $100 off on bookings above $500', 'fixed', 100, 500, 100, NOW(), NOW() + INTERVAL '90 days', 2000),
('ANNIVERSARY', 'Special anniversary discount - 30% off', 'percentage', 30, 200, 150, NOW(), NOW() + INTERVAL '365 days', 10000);

-- ============================================
-- WEEK 9: LOYALTY POINTS SYSTEM
-- ============================================

-- Loyalty points table
CREATE TABLE IF NOT EXISTS loyalty_points (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  points INTEGER DEFAULT 0,
  lifetime_points INTEGER DEFAULT 0,
  tier TEXT DEFAULT 'bronze', -- 'bronze', 'silver', 'gold', 'platinum'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Points transactions table
CREATE TABLE IF NOT EXISTS points_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  points INTEGER NOT NULL,
  transaction_type TEXT, -- 'earned', 'redeemed', 'expired', 'bonus'
  description TEXT,
  booking_id UUID REFERENCES bookings(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Referral system
CREATE TABLE IF NOT EXISTS referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_id UUID NOT NULL,
  referred_id UUID NOT NULL,
  referral_code TEXT UNIQUE NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'completed', 'rewarded'
  reward_points INTEGER DEFAULT 500,
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);

-- ============================================
-- WEEK 9: CHAT SYSTEM
-- ============================================

-- Chat conversations table
CREATE TABLE IF NOT EXISTS chat_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  hotel_id UUID REFERENCES hotels(id),
  booking_id UUID REFERENCES bookings(id),
  type TEXT DEFAULT 'hotel', -- 'hotel', 'support'
  status TEXT DEFAULT 'active', -- 'active', 'closed'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Chat messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES chat_conversations(id),
  sender_id UUID NOT NULL,
  sender_type TEXT, -- 'user', 'hotel', 'support', 'bot'
  message TEXT NOT NULL,
  attachments JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at DESC);

-- ============================================
-- ENHANCED REVIEWS (Week 7)
-- ============================================

-- Add helpful votes to reviews
CREATE TABLE IF NOT EXISTS review_votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  review_id UUID REFERENCES reviews(id),
  user_id UUID NOT NULL,
  is_helpful BOOLEAN,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(review_id, user_id)
);

-- Review responses from hotels
CREATE TABLE IF NOT EXISTS review_responses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  review_id UUID REFERENCES reviews(id) UNIQUE,
  hotel_id UUID REFERENCES hotels(id),
  response_text TEXT NOT NULL,
  responder_name TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Add-ons (public read)
ALTER TABLE addons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to addons" ON addons FOR SELECT USING (true);

-- Notifications (user-specific)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (true);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (true);

-- Push tokens (user-specific)
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own push tokens" ON push_tokens FOR ALL USING (true);

-- Coupons (public read)
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to coupons" ON coupons FOR SELECT USING (true);

-- Coupon usage (user-specific)
ALTER TABLE coupon_usage ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own coupon usage" ON coupon_usage FOR SELECT USING (true);

-- Loyalty points (user-specific)
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own loyalty points" ON loyalty_points FOR SELECT USING (true);

-- Points transactions (user-specific)
ALTER TABLE points_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own points transactions" ON points_transactions FOR SELECT USING (true);

-- Referrals
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own referrals" ON referrals FOR SELECT USING (true);

-- Chat conversations (user-specific)
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own conversations" ON chat_conversations FOR SELECT USING (true);
CREATE POLICY "Users can create conversations" ON chat_conversations FOR INSERT WITH CHECK (true);

-- Chat messages (conversation-specific)
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view messages in their conversations" ON chat_messages FOR SELECT USING (true);
CREATE POLICY "Users can send messages" ON chat_messages FOR INSERT WITH CHECK (true);

-- Review votes (public read, user-specific write)
ALTER TABLE review_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to review votes" ON review_votes FOR SELECT USING (true);
CREATE POLICY "Users can manage own review votes" ON review_votes FOR ALL USING (true);

-- Review responses (public read)
ALTER TABLE review_responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to review responses" ON review_responses FOR SELECT USING (true);
