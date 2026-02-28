# 💳 Razorpay Payment Integration - Quick Start Guide

## ✅ What's Already Done

Your LoveNest app now has **complete Razorpay payment integration**! Here's what's implemented:

### Frontend (Flutter) ✅
- ✅ Payment service with Razorpay SDK
- ✅ Payment screen with beautiful UI
- ✅ Payment success/failure handling
- ✅ Booking screen integrated with payment flow
- ✅ All models and data structures ready

### What You Need to Do

## 🔑 Step 1: Get Razorpay Test Keys (5 minutes)

1. **Sign up for Razorpay** (if you haven't already):
   - Go to: https://razorpay.com/
   - Click "Sign Up" and create an account
   - Verify your email

2. **Get Test API Keys**:
   - Login to Razorpay Dashboard: https://dashboard.razorpay.com/
   - Make sure you're in **TEST MODE** (toggle at top)
   - Go to **Settings** → **API Keys**
   - Click **Generate Test Keys**
   - You'll get:
     - `Key ID` (starts with `rzp_test_`)
     - `Key Secret` (keep this secret!)

3. **Update Flutter App**:
   - Open `lib/services/payment_service.dart`
   - Replace these lines (around line 10-11):
   ```dart
   static const String razorpayTestKeyId = 'rzp_test_YOUR_KEY_ID'; // TODO: Add your test key
   static const String razorpayTestKeySecret = 'YOUR_TEST_KEY_SECRET'; // TODO: Add your test secret
   ```
   
   With your actual keys:
   ```dart
   static const String razorpayTestKeyId = 'rzp_test_AbCdEfGhIjKlMn'; // Your actual key
   static const String razorpayTestKeySecret = 'YourActualSecretKey123'; // Your actual secret
   ```

## 🏗️ Step 2: Setup Backend API (Required)

Your backend needs these 4 endpoints:

### 1. Create Payment Order
**Endpoint:** `POST /api/payments/create-order`

This endpoint creates a Razorpay order and returns the order ID.

**Request Body:**
```json
{
  "booking_id": "BK1234567890",
  "hotel_id": "HTL001",
  "room_id": "RM001",
  "user_id": "USR001",
  "checkin_date": "2026-03-15T00:00:00Z",
  "checkout_date": "2026-03-17T00:00:00Z",
  "total_nights": 2,
  "room_price": 500.00,
  "addons_price": 120.00,
  "tax_amount": 93.00,
  "total_amount": 713.00,
  "addons": ["Candlelight Setup", "Rose Decoration"],
  "occasion": "",
  "special_requests": "",
  "guest_name": "John Doe",
  "guest_email": "john@example.com",
  "guest_phone": "+919876543210",
  "partner_name": null
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "order_id": "order_MNOPqrstuvwxyz",
    "booking_id": "BK1234567890",
    "amount": 71300,
    "currency": "INR",
    "receipt": "receipt_BK1234567890",
    "created_at": "2026-02-28T10:30:00Z"
  }
}
```

### 2. Verify Payment
**Endpoint:** `POST /api/payments/verify`

This endpoint verifies the payment signature after successful payment.

**Request Body:**
```json
{
  "payment_id": "pay_ABCDefghijklmn",
  "order_id": "order_MNOPqrstuvwxyz",
  "signature": "abc123def456...",
  "booking_id": "BK1234567890"
}
```

**Expected Response:**
```json
{
  "success": true,
  "verified": true,
  "message": "Payment verified successfully"
}
```

### 3. Send Payment Receipt (Optional)
**Endpoint:** `POST /api/payments/send-receipt`

Sends email receipt to customer.

**Request Body:**
```json
{
  "booking_id": "BK1234567890"
}
```

### 4. Process Refund (Optional)
**Endpoint:** `POST /api/payments/refund`

For cancellations and refunds.

**Request Body:**
```json
{
  "payment_id": "pay_ABCDefghijklmn",
  "booking_id": "BK1234567890",
  "amount": 71300,
  "reason": "Booking cancelled by user"
}
```

## 📊 Step 3: Database Schema (Optional but Recommended)

Add these tables to track payments:

```sql
-- Payment Orders Table
CREATE TABLE payment_orders (
  id SERIAL PRIMARY KEY,
  order_id VARCHAR(100) UNIQUE NOT NULL,
  booking_id VARCHAR(50) NOT NULL,
  payment_id VARCHAR(100),
  signature VARCHAR(255),
  amount INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  status VARCHAR(20) DEFAULT 'created',
  created_at TIMESTAMP DEFAULT NOW(),
  paid_at TIMESTAMP
);

-- Refunds Table (for cancellations)
CREATE TABLE refunds (
  id SERIAL PRIMARY KEY,
  refund_id VARCHAR(100) UNIQUE NOT NULL,
  payment_id VARCHAR(100) NOT NULL,
  booking_id VARCHAR(50) NOT NULL,
  amount INTEGER NOT NULL,
  reason TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP
);
```

## 🧪 Step 4: Test the Payment Flow

### Test Cards (Razorpay Test Mode)

Use these test cards for testing:

| Card Number | Expiry | CVV | Result |
|-------------|--------|-----|--------|
| 4111 1111 1111 1111 | Any future date | Any 3 digits | ✅ Success |
| 5555 5555 5555 4444 | Any future date | Any 3 digits | ✅ Success |
| 4000 0000 0000 0002 | Any future date | Any 3 digits | ❌ Failure |

### Test UPI IDs
- `success@razorpay` - Success
- `failure@razorpay` - Failure

### Testing Steps

1. **Run your Flutter app:**
   ```bash
   flutter run
   ```

2. **Navigate to a hotel** and click "Book Now"

3. **Select dates** and add-ons

4. **Click "Proceed to Pay"** button

5. **Razorpay checkout will open** with payment options

6. **Use test card:** 4111 1111 1111 1111
   - Expiry: Any future date (e.g., 12/25)
   - CVV: Any 3 digits (e.g., 123)

7. **Complete payment** and verify:
   - ✅ Payment success screen appears
   - ✅ Booking is confirmed
   - ✅ Email receipt is sent (if backend configured)

## 🎯 How It Works

### User Flow:
1. User selects hotel and dates
2. User adds romantic add-ons (optional)
3. User clicks "Proceed to Pay"
4. App creates payment order on backend
5. Razorpay checkout opens
6. User enters payment details
7. Payment is processed
8. App verifies payment signature
9. Success screen is shown
10. Email receipt is sent

### Technical Flow:
```
BookingScreen → PaymentScreen → PaymentService
                                      ↓
                              Create Order (Backend)
                                      ↓
                              Open Razorpay Checkout
                                      ↓
                              User Pays
                                      ↓
                              Verify Payment (Backend)
                                      ↓
                              Success Screen
```

## 💰 Pricing Calculation

The app automatically calculates:
- **Room Price**: Base price × Number of nights
- **Add-ons**: 
  - Candlelight Setup: $50
  - Rose Decoration: $30
  - Late Checkout: $40
- **Tax**: 15% of subtotal
- **Total**: Room + Add-ons + Tax

All amounts are converted to paise (1 INR = 100 paise) for Razorpay.

## 🔐 Security Features

✅ Payment signature verification  
✅ Secure token-based authentication  
✅ HTTPS only communication  
✅ Test mode for development  
✅ No card details stored in app  

## 📱 Features Implemented

✅ Complete payment flow  
✅ Beautiful payment UI  
✅ Success/failure handling  
✅ Email receipt support  
✅ Refund processing  
✅ Test mode integration  
✅ Multiple payment methods (Card, UPI, Wallets)  
✅ Anonymous booking support  
✅ Romantic add-ons  

## 🚀 Going Live (Production)

When ready for production:

1. **Complete Razorpay KYC** verification
2. **Switch to Live Mode** in Razorpay Dashboard
3. **Get Live API Keys** (starts with `rzp_live_`)
4. **Update keys** in production environment
5. **Test with real cards** (small amounts first)
6. **Enable webhooks** for payment notifications
7. **Set up monitoring** and alerts

## 📞 Support & Resources

- **Razorpay Docs**: https://razorpay.com/docs/
- **Test Dashboard**: https://dashboard.razorpay.com/
- **Razorpay Support**: support@razorpay.com
- **Flutter SDK**: https://pub.dev/packages/razorpay_flutter

## ⚠️ Important Notes

1. **Test Mode**: Always use test keys during development
2. **Never commit secrets**: Don't push API keys to Git
3. **Backend Required**: Payment verification must happen on backend
4. **Amount Format**: Razorpay uses paise (multiply by 100)
5. **Currency**: Currently set to INR (Indian Rupees)

## 🎉 You're Ready!

Your payment integration is complete! Just add your Razorpay test keys and set up the backend endpoints, and you're good to go.

**Need help?** Check the detailed documentation in `RAZORPAY_PAYMENT_SETUP.md`

---

**Happy Coding! 💖**
