# 🏗️ LoveNest App Structure

## Complete Navigation Map

```
┌─────────────────────────────────────────────────────────────┐
│                      LOVENEST APP                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Splash Screen  │
                    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Login/Register │
                    └─────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │                                         │
        ▼                                         ▼
┌───────────────┐                       ┌───────────────┐
│  Home Screen  │                       │ Profile Screen│
└───────────────┘                       └───────────────┘
        │                                         │
        │                                         │
        ├─► Search Hotels                        ├─► ACCOUNT SETTINGS ⭐NEW
        ├─► Hotel Details                        │   ├─► Privacy & Security
        ├─► Booking                              │   ├─► Notifications
        ├─► Bookings List                        │   ├─► Data & Privacy
        ├─► Wishlist                             │   └─► Payment Methods
        └─► Notifications                        │
                                                  ├─► Edit Profile
                                                  │
                                                  ├─► Booking History
                                                  │
                                                  ├─► Saved Nests
                                                  │
                                                  ├─► REWARDS & OFFERS
                                                  │   ├─► Loyalty Points ⭐ENHANCED
                                                  │   ├─► Coupons & Offers ⭐ENHANCED
                                                  │   └─► Romantic Add-ons ⭐ENHANCED
                                                  │
                                                  ├─► COMMUNICATION
                                                  │   ├─► Messages & Chat ⭐IMPROVED
                                                  │   └─► Notifications
                                                  │
                                                  └─► SUPPORT & INFO
                                                      ├─► AI Assistant ⭐NEW
                                                      ├─► Help & Support ⭐NEW
                                                      ├─► Safety Center
                                                      └─► Terms & Conditions
```

---

## Screen Hierarchy

### 🏠 Main Screens
```
├── Splash Screen
├── Login Screen
├── Register Screen
├── Home Screen (Main Hub)
├── Search Screen
└── Profile Screen (Settings Hub)
```

### 🏨 Hotel & Booking
```
├── Hotel Details Screen
├── Booking Screen
├── Bookings List Screen
└── Wishlist Screen
```

### 👤 Profile & Settings
```
├── Profile Screen
├── Edit Profile Screen
├── Account Settings Screen ⭐NEW
│   ├── Privacy & Security
│   ├── Notification Preferences
│   ├── Data & Privacy
│   └── Payment Methods
```

### 🎁 Rewards & Offers
```
├── Loyalty Screen ⭐ENHANCED
│   ├── Points Dashboard
│   ├── Tier Information
│   ├── How It Works
│   └── Transaction History
│
├── Coupons Screen ⭐ENHANCED
│   ├── Active Offers
│   ├── Statistics
│   └── Coupon Cards
│
└── Add-ons Screen ⭐ENHANCED
    ├── Decorations
    ├── Food & Beverages
    ├── Experiences
    └── Gifts
```

### 💬 Communication
```
├── Chat List Screen
├── Chat Screen ⭐IMPROVED BOT
├── AI Chatbot Screen ⭐NEW
└── Notifications Screen
```

### 🆘 Support & Help
```
├── Help & Support Screen ⭐NEW
│   ├── Quick Actions
│   ├── FAQ Section
│   ├── Contact Options
│   ├── Resources
│   └── Feedback
│
├── AI Assistant Screen ⭐NEW
│   ├── Quick Actions
│   ├── Suggested Questions
│   └── Chat Interface
│
├── Safety Center
└── Terms & Conditions
```

---

## Services Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      SERVICES LAYER                      │
└─────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Auth Service │    │ Chat Service │    │ AI Chatbot   │
│              │    │ ⭐IMPROVED   │    │ Service      │
│              │    │              │    │ ⭐NEW        │
└──────────────┘    └──────────────┘    └──────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Booking      │    │ Loyalty      │    │ Coupon       │
│ Service      │    │ Service      │    │ Service      │
└──────────────┘    └──────────────┘    └──────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Notification │    │ Add-on       │    │ Storage      │
│ Service      │    │ Service      │    │ Service      │
└──────────────┘    └──────────────┘    └──────────────┘
```

---

## Data Flow

### User Authentication Flow
```
Login Screen → Auth Service → API → Database
                    ↓
              Store Session
                    ↓
              Navigate to Home
```

### Booking Flow
```
Browse Hotels → Select Hotel → Hotel Details
                                    ↓
                              Choose Dates
                                    ↓
                              Select Room
                                    ↓
                              Add Extras (Add-ons)
                                    ↓
                              Apply Coupons
                                    ↓
                              Payment
                                    ↓
                              Confirmation
                                    ↓
                              Earn Loyalty Points
```

### AI Assistant Flow
```
User Question → AI Chatbot Service → Knowledge Base
                                            ↓
                                    Generate Response
                                            ↓
                                    Display to User
```

### Support Flow
```
User Issue → Help & Support Screen → FAQ Check
                                          ↓
                                    Not Found?
                                          ↓
                                    AI Assistant
                                          ↓
                                    Still Need Help?
                                          ↓
                                    Contact Support
```

---

## Feature Matrix

| Feature | Status | Screen | Access Path |
|---------|--------|--------|-------------|
| Account Settings | ⭐NEW | Account Settings | Profile → Account & Privacy |
| AI Assistant | ⭐NEW | AI Chatbot | Profile → AI Assistant |
| Help & Support | ⭐NEW | Help Support | Profile → Help & Support |
| Enhanced Loyalty | ⭐IMPROVED | Loyalty | Profile → Loyalty Points |
| Enhanced Coupons | ⭐IMPROVED | Coupons | Profile → Coupons & Offers |
| Enhanced Add-ons | ⭐IMPROVED | Add-ons | Profile → Romantic Add-ons |
| Improved Chat Bot | ⭐IMPROVED | Chat | Profile → Messages & Chat |
| Hotel Booking | ✅ EXISTING | Multiple | Home → Hotels |
| User Profile | ✅ EXISTING | Profile | Bottom Nav → Profile |
| Notifications | ✅ EXISTING | Notifications | Profile → Notifications |

---

## Bottom Navigation Structure

```
┌─────────────────────────────────────────────────────────┐
│  🏠 Nests  │  🔍 Explore  │  📚 Bookings  │  👤 Profile │
└─────────────────────────────────────────────────────────┘
      │             │              │               │
      ▼             ▼              ▼               ▼
   Home         Search        Bookings         Profile
   Screen       Screen         List           Settings
                                              & More
```

---

## Key Integrations

### External Services
- **Payment Gateway**: Razorpay
- **Image Caching**: Cached Network Image
- **URL Launcher**: Phone calls, emails
- **Google Sign-In**: OAuth authentication

### Internal Services
- **State Management**: Provider
- **Routing**: GoRouter
- **Storage**: SharedPreferences
- **HTTP**: http package

---

## File Structure

```
lib/
├── main.dart
├── models/
│   ├── addon.dart
│   ├── chat.dart
│   ├── coupon.dart
│   ├── loyalty_points.dart
│   └── notification.dart
├── screens/
│   ├── account_settings_screen.dart ⭐NEW
│   ├── ai_chatbot_screen.dart ⭐NEW
│   ├── help_support_screen.dart ⭐NEW
│   ├── addons_screen.dart ⭐ENHANCED
│   ├── coupons_screen.dart ⭐ENHANCED
│   ├── loyalty_screen.dart ⭐ENHANCED
│   ├── chat_screen.dart ⭐IMPROVED
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── booking_screen.dart
│   ├── hotel_details_screen.dart
│   └── ... (other screens)
├── services/
│   ├── ai_chatbot_service.dart ⭐NEW
│   ├── chat_service.dart ⭐IMPROVED
│   ├── auth_service.dart
│   ├── booking_service.dart
│   ├── loyalty_service.dart
│   ├── coupon_service.dart
│   ├── addon_service.dart
│   └── notification_service.dart
├── theme/
│   ├── app_theme.dart
│   └── app_colors.dart
└── utils/
```

---

## Summary

✅ **7 New/Enhanced Features**
✅ **3 New Screens**
✅ **1 New Service**
✅ **4 Enhanced Screens**
✅ **Professional UI/UX**
✅ **Complete Navigation**
✅ **Comprehensive Support**

Your LoveNest app is now feature-complete with professional-grade functionality! 🎉
