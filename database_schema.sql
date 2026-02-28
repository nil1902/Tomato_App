-- LoveNest Database Schema for InsForge PostgreSQL
-- Run this SQL in your InsForge database to create the necessary tables

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends auth)
-- This table stores additional user profile information
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  partner_name TEXT,
  anniversary_date DATE,
  avatar_url TEXT,
  phone TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);

-- Hotels table
CREATE TABLE IF NOT EXISTS hotels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  city TEXT,
  address TEXT,
  lat DECIMAL,
  lng DECIMAL,
  star_rating INTEGER,
  couple_rating DECIMAL,
  privacy_assured BOOLEAN DEFAULT true,
  amenities JSONB,
  images JSONB,
  price_per_night DECIMAL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Rooms table
CREATE TABLE IF NOT EXISTS rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  hotel_id UUID REFERENCES hotels(id),
  type TEXT,
  description TEXT,
  price_per_night DECIMAL,
  max_occupancy INTEGER,
  amenities JSONB,
  images JSONB,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  hotel_id UUID REFERENCES hotels(id),
  room_id UUID REFERENCES rooms(id),
  check_in DATE,
  check_out DATE,
  total_nights INTEGER,
  addons JSONB,
  total_amount DECIMAL,
  status TEXT DEFAULT 'pending',
  occasion TEXT,
  special_requests TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Wishlist table
CREATE TABLE IF NOT EXISTS wishlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  hotel_id UUID REFERENCES hotels(id),
  collection_name TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, hotel_id)
);

-- Reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  hotel_id UUID REFERENCES hotels(id),
  booking_id UUID REFERENCES bookings(id),
  user_id UUID REFERENCES auth.users(id),
  overall_rating INTEGER,
  cleanliness_rating INTEGER,
  romance_rating INTEGER,
  privacy_rating INTEGER,
  value_rating INTEGER,
  comment TEXT,
  images JSONB,
  occasion TEXT,
  verified_stay BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sample data for hotels
INSERT INTO hotels (name, description, city, address, star_rating, couple_rating, privacy_assured, amenities, images, price_per_night) VALUES
('Grand Royal Hotel', 'Luxurious hotel with romantic suites and couple-friendly amenities', 'New York', '123 Park Avenue, Manhattan', 5, 4.8, true, '["Free WiFi", "Spa", "Pool", "Gym", "Room Service"]', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]', 250),
('Ocean View Resort', 'Beachfront resort with private balconies and ocean views', 'Bali', '456 Beach Road, Kuta', 4, 4.9, true, '["Free WiFi", "Pool", "Beach Access", "Spa", "Restaurant"]', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]', 180),
('Mountain Retreat', 'Secluded mountain lodge with fireplace suites', 'Aspen', '789 Mountain Road, Colorado', 4, 4.7, true, '["Free WiFi", "Fireplace", "Hot Tub", "Ski Storage", "Restaurant"]', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]', 320),
('Romantic Palace', 'Historic palace converted into luxury romantic hotel', 'Paris', '101 Love Street, Montmartre', 5, 4.9, true, '["Free WiFi", "Spa", "Historic Building", "Fine Dining", "Wine Cellar"]', '["https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]', 280),
('Sunset Villa', 'Private villas with sunset views and personal butler', 'Maldives', '202 Island Road, Malé', 5, 4.8, true, '["Private Pool", "Butler Service", "Beach Access", "Spa", "Water Sports"]', '["https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]', 450);

-- Sample data for rooms
INSERT INTO rooms (hotel_id, type, description, price_per_night, max_occupancy, amenities, images) VALUES
((SELECT id FROM hotels WHERE name = 'Grand Royal Hotel'), 'Deluxe Suite', 'Spacious suite with king bed and city view', 250, 2, '["King Bed", "City View", "Jacuzzi", "Mini Bar"]', '["https://images.unsplash.com/photo-1611892440504-42a792e24d32?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]'),
((SELECT id FROM hotels WHERE name = 'Grand Royal Hotel'), 'Executive Suite', 'Luxury suite with separate living area', 350, 2, '["King Bed", "Living Room", "Kitchenette", "Work Desk"]', '["https://images.unsplash.com/photo-1566665797739-1674de7a421a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]'),
((SELECT id FROM hotels WHERE name = 'Ocean View Resort'), 'Beachfront Villa', 'Private villa with direct beach access', 180, 2, '["Beach Access", "Private Terrace", "Outdoor Shower", "Hammock"]', '["https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]'),
((SELECT id FROM hotels WHERE name = 'Ocean View Resort'), 'Ocean View Room', 'Room with panoramic ocean views', 220, 2, '["Ocean View", "Balcony", "King Bed", "Air Conditioning"]', '["https://images.unsplash.com/photo-1540541338287-41700207dee6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]'),
((SELECT id FROM hotels WHERE name = 'Mountain Retreat'), 'Fireplace Suite', 'Cozy suite with fireplace and mountain views', 320, 2, '["Fireplace", "Mountain View", "King Bed", "Hot Tub Access"]', '["https://images.unsplash.com/photo-1590490360182-c33d57733427?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"]');

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Create policies for public access to hotels and rooms
CREATE POLICY "Allow public read access to hotels" ON hotels FOR SELECT USING (true);
CREATE POLICY "Allow public read access to rooms" ON rooms FOR SELECT USING (true);

-- Create policies for user profiles
CREATE POLICY "Users can view all profiles" ON user_profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (true);
CREATE POLICY "Users can delete own profile" ON user_profiles FOR DELETE USING (true);

CREATE POLICY "Users can view own bookings" ON bookings FOR SELECT USING (true);
CREATE POLICY "Users can create own bookings" ON bookings FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own bookings" ON bookings FOR UPDATE USING (true);

CREATE POLICY "Users can view own wishlist" ON wishlists FOR SELECT USING (true);
CREATE POLICY "Users can manage own wishlist" ON wishlists FOR ALL USING (true);

CREATE POLICY "Users can view all reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can create own reviews" ON reviews FOR INSERT WITH CHECK (true);