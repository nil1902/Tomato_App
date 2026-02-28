# 🚀 LoveNest Implementation Roadmap

Based on your comprehensive PRD, here's the step-by-step implementation plan.

## ⚠️ CRITICAL FIRST STEPS

### Step 1: Test Simple App (NOW)
1. Install `build\app\outputs\flutter-apk\app-debug.apk` on your phone
2. Confirm it opens without crashing (shows pink heart)
3. **Tell me if it works!**

### Step 2: Restore Full Auth System
Once simple app works, we'll restore:
```bash
copy lib\main_backup.dart lib\main.dart
flutter build apk --debug
```

This brings back:
- ✅ Login/Register screens
- ✅ Authentication service
- ✅ Splash screen
- ✅ Profile screen
- ✅ Home screen skeleton

---

## 📅 Implementation Phases

### PHASE 1: Foundation (Week 1-2) - MVP Core

#### 1.1 Complete Authentication Module
**Status**: 80% done, needs:
- [ ] Google OAuth integration (code ready, needs Google Cloud setup)
- [ ] OTP login via Twilio/MSG91
- [ ] Forgot password flow
- [ ] Email verification
- [ ] Couple profile setup (partner name, anniversary)

#### 1.2 Backend Setup with InsForge
- [ ] Set up InsForge database tables
- [ ] Create API endpoints for hotels
- [ ] Set up authentication with InsForge
- [ ] Configure storage for images

#### 1.3 Home Screen Implementation
- [ ] Hero banner carousel
- [ ] "Near You" section
- [ ] Mood-based tiles
- [ ] Featured hotels grid
- [ ] Navigation to search

---

### PHASE 2: Core Booking Flow (Week 3-4)

#### 2.1 Hotel Search & Filters
- [ ] Search bar with autocomplete
- [ ] Date picker (check-in/out)
- [ ] Filter panel UI
- [ ] Search results list
- [ ] Map view toggle
- [ ] Sort options

#### 2.2 Hotel Detail Page
- [ ] Image gallery
- [ ] Hotel info display
- [ ] Room list
- [ ] Amenities grid
- [ ] Reviews section
- [ ] "Book Now" button

#### 2.3 Basic Booking Flow
- [ ] Room selection
- [ ] Guest details form
- [ ] Booking summary
- [ ] Payment integration (Razorpay)
- [ ] Booking confirmation

---

### PHASE 3: User Features (Week 5-6)

#### 3.1 Booking Management
- [ ] My Bookings list
- [ ] Booking details
- [ ] Cancel booking
- [ ] Download invoice

#### 3.2 Profile & Personalization
- [ ] Edit profile
- [ ] Partner profile
- [ ] Anniversary reminder
- [ ] Preferences

#### 3.3 Wishlist
- [ ] Add to wishlist
- [ ] View wishlist
- [ ] Remove from wishlist
- [ ] Collections

---

### PHASE 4: Enhanced Features (Week 7-8)

#### 4.1 Romantic Add-ons
- [ ] Add-ons selection UI
- [ ] Add-ons in booking flow
- [ ] Price calculation with add-ons

#### 4.2 Reviews & Ratings
- [ ] Post review form
- [ ] View reviews
- [ ] Rating system
- [ ] Photo upload

#### 4.3 Notifications
- [ ] Push notifications setup
- [ ] Booking confirmations
- [ ] Reminders
- [ ] Offers alerts

---

### PHASE 5: Advanced Features (Week 9-12)

#### 5.1 Offers & Loyalty
- [ ] Coupon system
- [ ] Loyalty points
- [ ] Referral program

#### 5.2 In-App Chat
- [ ] Chat with hotel
- [ ] Support chat
- [ ] Chatbot

#### 5.3 Maps Integration
- [ ] Google Maps
- [ ] Location services
- [ ] Nearby attractions

---

## 🎯 Immediate Next Steps (After Test App Works)

### Step 1: Database Schema Setup
Create these tables in InsForge:

```sql
-- Users table (extends auth)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  partner_name TEXT,
  anniversary_date DATE,
  avatar_url TEXT,
  phone TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Hotels table
CREATE TABLE hotels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  city TEXT,
  address TEXT,
  lat DECIMAL,
  lng DECIMAL,
  star_rating INTEGER,
  couple_rating DECIMAL,
  amenities JSONB,
  images JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Rooms table
CREATE TABLE rooms (
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
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  hotel_id UUID REFERENCES hotels(id),
  room_id UUID REFERENCES rooms(id),
  checkin_date DATE,
  checkout_date DATE,
  total_nights INTEGER,
  addons JSONB,
  total_amount DECIMAL,
  status TEXT DEFAULT 'pending',
  occasion TEXT,
  special_requests TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Wishlist table
CREATE TABLE wishlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  hotel_id UUID REFERENCES hotels(id),
  collection_name TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, hotel_id)
);

-- Reviews table
CREATE TABLE reviews (
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
```

### Step 2: Create Sample Data
Add 5-10 sample hotels with rooms for testing

### Step 3: Build Home Screen
Start with the home screen showing sample hotels

---

## 🛠️ Development Approach

### For Each Feature:
1. **Design UI first** (show you mockup/screenshot)
2. **Get your approval**
3. **Implement frontend**
4. **Create backend API** (if needed)
5. **Test on your phone**
6. **Get feedback**
7. **Refine**
8. **Move to next feature**

### Code Quality Standards:
- Clean, readable code
- Proper error handling
- Loading states
- Empty states
- Offline support where possible
- Smooth animations
- Responsive design

---

## 📱 Testing Strategy

After each feature:
1. Build APK
2. Install on your phone
3. Test functionality
4. Check UI/UX
5. Fix issues
6. Repeat

---

## 🎨 Design System

We'll create:
- Color palette (burgundy, rose, gold)
- Typography system
- Reusable components
- Icon set
- Animation library

---

## ⏱️ Realistic Timeline

| Phase | Duration | Deliverable |
|---|---|---|
| Phase 1 | 2 weeks | Auth + Home + Backend setup |
| Phase 2 | 2 weeks | Search + Hotel Detail + Basic Booking |
| Phase 3 | 2 weeks | Bookings + Profile + Wishlist |
| Phase 4 | 2 weeks | Add-ons + Reviews + Notifications |
| Phase 5 | 4 weeks | Advanced features + Polish |

**Total: ~12 weeks for full MVP**

---

## 🚦 Current Status

✅ Project renamed to LoveNest
✅ Authentication screens built
✅ Android 16 compatibility fixed
✅ Build system working
⏳ Waiting for test app confirmation
⏳ Ready to restore full auth
⏳ Ready to start Phase 1

---

## 💬 What I Need From You

1. **Confirm test app works** (pink heart shows without crash)
2. **Approve this roadmap** or suggest changes
3. **Provide InsForge backend details** (URL, keys)
4. **Share any design preferences** (colors, fonts, style)
5. **Prioritize features** if you want different order

---

**Let's build this step by step, testing on your phone after each feature!** 🚀

Once you confirm the test app works, we'll start with Phase 1 immediately.
