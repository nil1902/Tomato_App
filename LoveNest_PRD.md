# 🏩 LoveNest — Product Requirements Document (PRD)
**Version:** 1.0  
**Date:** February 2026  
**Platform:** Flutter (iOS + Android) + Full-Stack Backend  
**Status:** In Development  

---

## 1. Executive Summary

**LoveNest** is a couple-focused hotel and room booking application designed exclusively for romantic getaways, anniversary stays, honeymoon trips, and intimate couple escapes. Unlike generic booking platforms, LoveNest curates hotels and rooms tailored for couples — offering romantic packages, couple-centric amenities, and a seamless, emotionally-driven user experience.

The app is built with Flutter for cross-platform mobile delivery and a Node.js + PostgreSQL backend with RESTful APIs, ensuring a scalable and maintainable full-stack architecture.

---

## 2. Problem Statement

Couples planning romantic hotel stays face significant friction on generic platforms like Booking.com or MakeMyTrip:
- No specialized filters for romance (jacuzzi rooms, private pools, candlelight setups)
- No romantic package bundles (flowers, wine, couples massage)
- No mood-based or occasion-based search (anniversary, honeymoon, weekend escape)
- Uninspiring UI with no emotional resonance
- No couple-specific trust signals (privacy policies, discreet billing)

**LoveNest** solves all of the above with a purpose-built platform.

---

## 3. Goals & Objectives

### Business Goals
- Capture the underserved romantic travel niche in Tier 1 & Tier 2 cities
- Onboard 500+ partner hotels within 6 months of launch
- Achieve 10,000+ bookings in Month 3
- Generate revenue via commission (15–20% per booking) + premium hotel listing fees

### User Goals
- Discover romantic hotels and packages effortlessly
- Book with confidence via trusted reviews and verified properties
- Personalize the stay with add-ons (flowers, wine, surprise decor)
- Manage bookings and anniversary reminders from one place

---

## 4. Target Audience

| Segment | Description |
|---|---|
| **Newlyweds** | Honeymoon planning, 1st anniversary stays |
| **Long-term couples** | Weekend getaways, anniversary surprises |
| **Dating couples** | First romantic trips, special date nights |
| **Married couples** | Rekindling romance, solo couple time |

**Age Range:** 22–45  
**Primary Markets:** India (Phase 1), Southeast Asia (Phase 2), Global (Phase 3)

---

## 5. App Architecture Overview

### Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) |
| **State Management** | Riverpod / BLoC |
| **Backend** | Node.js + Express.js |
| **Database** | PostgreSQL (primary), Redis (cache/sessions) |
| **Authentication** | Firebase Auth + JWT tokens |
| **File Storage** | AWS S3 / Firebase Storage |
| **Payment Gateway** | Razorpay (India) + Stripe (Global) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Maps & Location** | Google Maps API |
| **Real-time** | Socket.io (for live booking status) |
| **Search** | Elasticsearch / PostgreSQL Full-Text Search |
| **Email Service** | SendGrid |
| **SMS / OTP** | Twilio / MSG91 |
| **Hosting** | AWS EC2 / Railway / Render |

---

## 6. User Roles

| Role | Description |
|---|---|
| **Guest** | Browse hotels, view listings (no booking) |
| **Registered User (Couple)** | Full booking, profile, wishlist, reviews |
| **Hotel Partner (Admin)** | Manage hotel listings, rooms, bookings |
| **Super Admin** | Platform management, analytics, approvals |

---

## 7. Feature Modules

---

### MODULE 1: Authentication & Onboarding ✅ (Already Built)

**Completed Features:**
- User Registration (Email + Password)
- User Login (Email + Password)
- Authentication pages

**Remaining Tasks in This Module:**
- Social Login: Google OAuth, Apple Sign-In
- OTP-based Mobile Login (via Twilio/MSG91)
- JWT token issuance + Refresh token logic
- Forgot Password / Reset Password flow
- Email verification on registration
- Couple profile setup (partner name, anniversary date, preferences)
- Onboarding carousel (3–4 screens showing app value proposition)
- Account deletion flow (GDPR compliant)

---

### MODULE 2: Home & Discovery

**Screens:** Home Feed, Category Browse, Featured Banners

**Features:**
- Personalized home feed based on location + past searches
- Mood-based discovery tiles: "Romantic Escape", "Surprise Weekend", "Honeymoon Suite", "Anniversary Special"
- Hero banner carousel (featured hotels, seasonal offers)
- "Near You" section with distance filter
- "Trending This Weekend" dynamic section
- Occasion-based quick filters: Anniversary, Honeymoon, Babymoon, Date Night
- Flash Deals section (time-limited offers with countdown timer)
- Recently Viewed hotels (local + server sync)
- Curated Collections: "Hilltop Romance", "Beach Escape", "City Luxury", "Budget Romantic"
- City/Destination-based quick links

---

### MODULE 3: Hotel Search & Filters

**Screens:** Search Page, Filter Panel, Search Results

**Features:**
- Search by city, hotel name, landmark, or area
- Date range picker (Check-in / Check-out) with calendar view
- Guest count selector (1 or 2 guests — default 2 for couple)
- Smart autocomplete with recent and popular searches
- Saved search history

**Filter Options:**
- Price range slider
- Star rating (1–5 stars)
- Amenities: Private jacuzzi, private pool, balcony, fireplace, canopy bed
- Hotel type: Boutique, Resort, Heritage, Treehouse, Houseboat
- Package type: Room only, Breakfast included, Romantic package, All-inclusive
- Distance from city center
- Couple-specific: Pet-friendly, Same-sex couple friendly, Late checkout
- Instant booking vs. request-based booking
- Cancellation policy: Free cancellation, Partially refundable, Non-refundable

**Results Display:**
- List view + Map view toggle
- Sort by: Price (low/high), Rating, Distance, Popularity
- Hotel card with: thumbnail, rating, key amenities icons, price/night, "Couples Love This" badge

---

### MODULE 4: Hotel Detail Page

**Screens:** Hotel Profile, Room List, Room Detail

**Features:**
- Full-screen image gallery with pinch-to-zoom
- Hotel name, location, star rating, couple rating score (separate from general rating)
- "Why Couples Love This" highlight section (e.g., private balcony, in-room dining)
- Amenities grid with icons
- Room types listing with individual pricing
- Romantic Add-ons section (can be added during booking):
  - Rose petal decoration
  - Candle-light dinner
  - Couple massage
  - Champagne/wine on arrival
  - Customized anniversary cake
  - Balloon decoration
- Nearby attractions map view
- Hotel policies: Check-in time, Check-out time, Couple policy, ID proof required
- Reviews section with couple-specific tags ("Perfect for anniversary", "Very private")
- "Ask a Question" feature (Q&A)
- Similar hotels recommendation carousel

---

### MODULE 5: Room Booking Flow

**Screens:** Room Selection → Add-ons → Guest Details → Payment → Confirmation

**Step 1 — Room Selection:**
- Room images, description, size, max occupancy
- Inclusion list (WiFi, breakfast, parking)
- Pricing breakdown per night + taxes
- Availability calendar

**Step 2 — Romantic Add-ons:**
- Checkbox selection for add-ons
- Each add-on shows price + preview image
- Surprise mode: "Let the hotel surprise us" toggle

**Step 3 — Guest Details:**
- Primary guest name + contact
- Partner name (optional)
- Special requests text field
- Occasion selector: Honeymoon / Anniversary / Birthday / Just us

**Step 4 — Payment:**
- Booking summary with full price breakdown
- Coupon/promo code input
- Wallet/loyalty points redemption
- Payment methods: Credit/Debit Card, UPI, Net Banking, Wallets (Paytm, PhonePe), EMI option
- Razorpay / Stripe integration
- Secure payment badge + SSL indicator
- Auto-save card option (encrypted token)

**Step 5 — Confirmation:**
- Animated booking success screen (romantic animation — hearts, sparkles)
- Booking ID + QR code for check-in
- Email + SMS confirmation trigger
- Add to Google Calendar option
- Share itinerary to partner via WhatsApp/email
- "Plan your trip" suggestions (nearby restaurants, activities)

---

### MODULE 6: Booking Management

**Screens:** My Bookings, Booking Detail, Modify/Cancel

**Features:**
- Tabs: Upcoming, Completed, Cancelled
- Booking card: hotel thumbnail, dates, status badge, booking ID
- View full booking details
- Modify booking: Change dates (if allowed), upgrade room (subject to availability)
- Cancel booking with refund policy display
- Cancellation reason selector
- Download invoice (PDF)
- Re-book previous stay with one tap
- Contact hotel directly (in-app chat or phone)
- Add/edit special requests pre-stay

---

### MODULE 7: Couple Profile & Personalization

**Screens:** Profile Page, Edit Profile, Partner Profile, Anniversary Reminder

**Features:**
- User profile: Name, photo, email, phone, city
- Partner profile: Partner name, photo (optional), partner email
- Anniversary date + reminder settings
- Birthday of partner (for surprise suggestions)
- Travel preferences: Beach, Hills, City, Heritage, Budget range
- Notification preferences
- Linked couple account option (invite partner to link profiles)
- Travel stats: Trips together, Hotels stayed, Cities explored
- Profile completeness indicator
- Account settings: Change password, Manage payment methods, Linked accounts

---

### MODULE 8: Wishlist & Collections

**Screens:** Wishlist, Create Collection, Shared Wishlist

**Features:**
- Save hotels to wishlist with heart icon from any listing
- Organize into named collections: "Honeymoon Ideas", "Budget Escapes", "Dream Stays"
- Share wishlist with partner (via link or in-app)
- Partner can add/remove from shared wishlist
- Price drop alert on wishlisted hotels (push notification)
- Availability check on saved hotels

---

### MODULE 9: Reviews & Ratings

**Screens:** Write Review, Hotel Reviews Feed

**Features:**
- Post-stay review prompt (triggered 24hrs after checkout)
- Overall rating + sub-ratings: Cleanliness, Romance factor, Privacy, Value for money, Staff
- Text review (min 50 characters)
- Photo upload (up to 5 images)
- "Would you recommend for couples?" Yes/No
- Occasion tag: Honeymoon, Anniversary, Weekend Getaway
- Hotel response to reviews
- Helpful vote on reviews
- Review editing within 7 days of posting
- Report inappropriate review
- Verified stay badge on reviews

---

### MODULE 10: Notifications & Alerts

**Features:**
- Push notifications via FCM
- Booking confirmation, modification, cancellation
- Check-in reminder (24 hours before)
- Anniversary/birthday reminder with hotel suggestions
- Flash deal alerts (opt-in)
- Price drop alerts on wishlisted hotels
- Review request post-checkout
- Partner shared wishlist activity
- In-app notification center with read/unread state
- Email notifications (SendGrid) with beautiful HTML templates
- SMS alerts for booking confirmation + OTP

---

### MODULE 11: Offers, Coupons & Loyalty

**Screens:** Offers Page, Apply Coupon, Loyalty Dashboard

**Features:**
- Browse active promo codes and hotel-specific offers
- Category-based offers: Honeymoon special, Weekend deal, Last-minute discount
- Apply coupon at checkout with real-time validation
- Referral program: Earn credits when a friend books
- LoveNest Rewards (Loyalty Program):
  - Earn "Love Points" on every booking (1 point = ₹1 spend)
  - Redeem points for discounts on future bookings
  - Tier system: Silver Couple, Gold Couple, Platinum Couple
  - Tier benefits: Early check-in, Room upgrades, Exclusive deals
- Gift card purchase and redemption

---

### MODULE 12: In-App Chat & Support

**Screens:** Chat with Hotel, Help Center, Live Support

**Features:**
- In-app chat with hotel (pre-booking queries, special requests)
- Chat with LoveNest support
- AI-powered chatbot for common queries (FAQs, booking help)
- Help Center with searchable FAQs
- Raise support ticket with booking reference
- Ticket status tracking
- Escalation to human agent

---

### MODULE 13: Maps & Location Services

**Features:**
- Google Maps integration on hotel detail and search results
- Hotel location pin with info card
- Nearby attractions markers: Restaurants, Cafés, Spas, Viewpoints
- Distance calculation from user's current location
- Directions integration (Google Maps / Apple Maps)
- Location-based hotel suggestions on home screen
- City guide: Top romantic spots in each city

---

### MODULE 14: Admin Panel (Web Dashboard)

**Platform:** React.js Web App (for Hotel Partners + Super Admin)

**Hotel Partner Features:**
- Login / Secure dashboard
- Add/edit hotel profile (name, description, photos, amenities, policies)
- Add/edit rooms (type, pricing, availability calendar, photos)
- Manage romantic add-on packages
- View and respond to bookings (Accept / Reject for request-based)
- View and respond to guest reviews
- Revenue dashboard: Earnings, Booking count, Occupancy rate
- Promotional offers creation

**Super Admin Features:**
- Hotel partner onboarding + approval workflow
- User management (view, suspend, delete)
- Booking overview across all hotels
- Revenue reports + commission tracking
- Coupon and offer management
- App banner / content management (CMS)
- Analytics dashboard (DAU, MAU, Conversion rate, Revenue)
- Fraud detection flags
- Notification broadcast (push + email campaigns)

---

## 8. API Design (Backend Endpoints Summary)

### Auth APIs
- `POST /api/auth/register` — User registration
- `POST /api/auth/login` — Email/password login
- `POST /api/auth/google` — Google OAuth login
- `POST /api/auth/otp/send` — Send OTP
- `POST /api/auth/otp/verify` — Verify OTP
- `POST /api/auth/refresh-token` — Refresh JWT
- `POST /api/auth/forgot-password` — Send reset email
- `POST /api/auth/reset-password` — Reset with token

### User APIs
- `GET /api/users/me` — Get current user profile
- `PUT /api/users/me` — Update profile
- `POST /api/users/partner/invite` — Invite partner to link
- `GET /api/users/bookings` — List user bookings
- `GET /api/users/wishlist` — Get wishlist
- `POST /api/users/wishlist/:hotelId` — Add to wishlist
- `DELETE /api/users/wishlist/:hotelId` — Remove from wishlist

### Hotel APIs
- `GET /api/hotels` — Search/list hotels (with filters + pagination)
- `GET /api/hotels/:id` — Get hotel detail
- `GET /api/hotels/:id/rooms` — Get rooms of hotel
- `GET /api/hotels/:id/reviews` — Get reviews
- `POST /api/hotels/:id/reviews` — Post review

### Booking APIs
- `POST /api/bookings` — Create booking
- `GET /api/bookings/:id` — Get booking detail
- `PUT /api/bookings/:id` — Modify booking
- `POST /api/bookings/:id/cancel` — Cancel booking
- `GET /api/bookings/:id/invoice` — Download invoice PDF

### Payment APIs
- `POST /api/payments/initiate` — Initiate payment order
- `POST /api/payments/verify` — Verify payment signature
- `POST /api/payments/refund` — Process refund

### Offers APIs
- `GET /api/offers` — List active offers
- `POST /api/coupons/validate` — Validate coupon code

### Admin APIs (Protected)
- `POST /api/admin/hotels` — Add hotel
- `PUT /api/admin/hotels/:id` — Update hotel
- `GET /api/admin/analytics` — Dashboard metrics
- `PUT /api/admin/bookings/:id/status` — Update booking status

---

## 9. Database Schema (Key Tables)

### users
`id, email, password_hash, phone, name, partner_name, anniversary_date, avatar_url, role, created_at`

### hotels
`id, partner_id, name, description, city, address, lat, lng, star_rating, couple_rating, amenities (JSON), policies (JSON), is_approved, created_at`

### rooms
`id, hotel_id, type, description, price_per_night, max_occupancy, amenities (JSON), images (JSON), is_available`

### bookings
`id, user_id, hotel_id, room_id, checkin_date, checkout_date, total_nights, addons (JSON), total_amount, status, occasion, special_requests, created_at`

### payments
`id, booking_id, user_id, amount, currency, gateway, gateway_order_id, gateway_payment_id, status, created_at`

### reviews
`id, hotel_id, booking_id, user_id, overall_rating, cleanliness_rating, romance_rating, privacy_rating, value_rating, comment, images (JSON), occasion, verified_stay, created_at`

### wishlists
`id, user_id, hotel_id, collection_name, created_at`

### offers
`id, code, type (percent/flat), value, min_order_amount, max_discount, valid_from, valid_to, usage_limit, is_active`

---

## 10. Non-Functional Requirements

| Requirement | Target |
|---|---|
| **App Launch Time** | < 2 seconds cold start |
| **API Response Time** | < 300ms for 95th percentile |
| **Uptime SLA** | 99.9% |
| **Search Latency** | < 500ms |
| **Payment Success Rate** | > 98% |
| **Image Load Time** | < 1 second (CDN cached) |
| **Offline Support** | Wishlist + Booking details cached offline |
| **Security** | HTTPS, JWT, bcrypt, PCI-DSS compliant payments |
| **Data Privacy** | GDPR + India DPDP compliant |
| **Scalability** | Horizontal scaling on AWS (Docker + Load Balancer) |
| **Localization** | English (Phase 1), Hindi, Tamil (Phase 2) |

---

## 11. Flutter App Architecture

```
lib/
├── core/
│   ├── constants/         # App colors, strings, dimensions
│   ├── theme/             # Light/Dark theme config
│   ├── utils/             # Date helpers, formatters, validators
│   ├── network/           # Dio HTTP client, interceptors
│   └── errors/            # Exception handling
├── features/
│   ├── auth/              # ✅ Login, Register, OTP
│   ├── home/              # Home feed, banners, categories
│   ├── search/            # Search, filters, results
│   ├── hotel/             # Hotel detail, rooms, gallery
│   ├── booking/           # Booking flow, add-ons, payment
│   ├── profile/           # User profile, partner, settings
│   ├── wishlist/          # Save hotels, collections
│   ├── reviews/           # Post and view reviews
│   ├── notifications/     # Notification center
│   ├── offers/            # Coupons, deals, loyalty
│   └── support/           # Chat, FAQ, tickets
├── shared/
│   ├── widgets/           # Reusable UI components
│   ├── models/            # Data models (User, Hotel, Booking, etc.)
│   └── providers/         # Riverpod providers
└── main.dart
```

---

## 12. UI/UX Design Guidelines

- **Design Language:** Warm, romantic, luxurious — deep burgundy + soft rose + champagne gold palette
- **Typography:** Playfair Display (headings) + Lato (body)
- **Animations:** Subtle entrance animations, heart-pulse on wishlist, confetti on booking success
- **Dark Mode:** Full dark mode support with warm tones (deep plum, soft amber)
- **Accessibility:** WCAG 2.1 AA compliant, minimum tap target 48dp
- **Image Style:** Full-bleed hotel photography, soft vignette overlays
- **Micro-interactions:** Haptic feedback on booking confirm, swipe-to-dismiss on notifications
- **Empty States:** Illustrated romantic empty states (e.g., couple illustration for empty wishlist)

---

## 13. Security Requirements

- All API communication over HTTPS (TLS 1.3)
- JWT tokens with 24-hour expiry + refresh token rotation
- Password hashing with bcrypt (salt rounds: 12)
- Input validation and SQL injection prevention (parameterized queries)
- Rate limiting on auth endpoints (max 5 attempts / 15 min)
- Payment data never stored on app servers (tokenized via Razorpay/Stripe)
- OWASP Mobile Top 10 compliance
- Discreet billing: Transactions appear as "LN Technologies" on bank statement
- No third-party ad trackers (privacy-first approach)

---

## 14. Monetization Strategy

| Revenue Stream | Details |
|---|---|
| **Commission** | 15–20% on every booking from hotel partner |
| **Featured Listings** | Hotels pay for top placement in search results |
| **Promotional Banners** | Hotels pay for home screen banner placements |
| **Premium Packages** | Curated "LoveNest Exclusive" packages with higher margin |
| **Subscription (Future)** | "LoveNest Plus" — members get exclusive deals, early access |
| **Gift Cards** | Revenue from unredeemed balances |

---

## 15. Launch Phases

### Phase 1 — MVP (Months 1–3)
- Authentication ✅
- Hotel search + filters
- Hotel detail + room listing
- Basic booking flow + Razorpay payment
- Booking management
- User profile
- Push notifications

### Phase 2 — Growth (Months 4–6)
- Romantic add-ons at checkout
- Wishlist + Collections
- Reviews & Ratings
- Couple profile + Partner linking
- Loyalty Points system
- In-app support chat
- Admin web dashboard

### Phase 3 — Scale (Months 7–12)
- AI-based personalized recommendations
- Shared couple wishlist
- Anniversary reminder + auto-suggestion engine
- Multi-city expansion
- Multi-language support
- International payment support (Stripe)
- B2B API for travel agents

---

## 16. Success Metrics (KPIs)

| Metric | Month 1 Target | Month 6 Target |
|---|---|---|
| Registered Users | 1,000 | 50,000 |
| Active Hotel Listings | 50 | 500 |
| Monthly Bookings | 200 | 5,000 |
| Avg. Booking Value | ₹4,000 | ₹6,000 |
| App Store Rating | — | 4.5+ |
| Monthly Revenue | ₹1.2L | ₹15L+ |
| Booking Conversion Rate | 3% | 8% |
| D7 Retention | — | 40% |

---

## 17. Risk & Mitigation

| Risk | Mitigation |
|---|---|
| Low hotel partner onboarding | Dedicated B2B sales team + easy self-onboarding portal |
| Payment failure | Retry mechanism + fallback payment gateway |
| Fake reviews | Verified-stay badge + AI moderation |
| Privacy concerns | Discreet billing + privacy-first policy + no ad tracking |
| Seasonal demand | Dynamic pricing tools + off-season deals for hotels |
| App Store rejection | Pre-submission review against Apple/Google guidelines |

---

## 18. Appendix — Glossary

| Term | Definition |
|---|---|
| **Romantic Add-on** | Extra service added to a booking (flowers, cake, massage) |
| **Couple Rating** | A separate rating metric for how couple-friendly a hotel is |
| **Love Points** | LoveNest loyalty currency earned per booking |
| **Partner Link** | Feature to connect two user accounts as a couple |
| **Flash Deal** | Time-limited price drop available for 24–48 hours |
| **Verified Stay** | Review confirmed by actual booking data |
| **Occasion Tag** | Label applied to booking/review (Honeymoon, Anniversary, etc.) |

---

*Document prepared for LoveNest development team. All features subject to prioritization based on business and technical feasibility review.*
