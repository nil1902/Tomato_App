# 🚀 Payment Integration - Quick Start Guide

## ⚡ 5-Minute Setup

### Step 1: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 2: Get Razorpay Test Keys

1. Sign up at https://razorpay.com/
2. Go to Dashboard → Settings → API Keys
3. Copy your Test Mode keys:
   - Key ID (starts with `rzp_test_`)
   - Key Secret

### Step 3: Update Flutter App

Open `lib/services/payment_service.dart` and update:

```dart
static const String razorpayTestKeyId = 'rzp_test_YOUR_KEY_ID';
static const String razorpayTestKeySecret = 'YOUR_TEST_KEY_SECRET';
```

### Step 4: Test Payment (Without Backend)

You can test the payment UI immediately:

```dart
// Add to your main.dart or any screen
import 'package:lovenest/screens/payment_test_screen.dart';

// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentTestScreen(
      authToken: 'test_token',
      userName: 'Test User',
      userEmail: 'test@example.com',
      userPhone: '+919876543210',
    ),
  ),
);
```

### Step 5: Run the App

```bash
flutter run
```

---

## 🎯 Test Payment Flow

1. Open the Payment Test Screen
2. Fill in the booking details
3. Click "Proceed to Payment"
4. Use test card: **4111 1111 1111 1111**
5. Expiry: Any future date
6. CVV: Any 3 digits (e.g., 123)
7. Complete payment

---

## 🔧 Backend Setup (Optional - For Full Integration)

### Prerequisites
- Node.js 16+ installed
- PostgreSQL database
- Gmail account (for email receipts)

### Quick Backend Setup

1. **Create backend folder:**
```bash
mkdir lovenest-backend
cd lovenest-backend
npm init -y
```

2. **Install dependencies:**
```bash
npm install express razorpay pg dotenv nodemailer crypto cors
```

3. **Copy backend file:**
Copy `backend_payment_api.js` to your backend folder

4. **Create .env file:**
Copy `.env.example` and fill in your credentials

5. **Create database tables:**
```sql
-- Run this in your PostgreSQL database
CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  booking_id VARCHAR(50) UNIQUE NOT NULL,
  hotel_id VARCHAR(50),
  room_id VARCHAR(50),
  user_id VARCHAR(50),
  checkin_date TIMESTAMP,
  checkout_date TIMESTAMP,
  total_nights INTEGER,
  room_price DECIMAL(10,2),
  addons_price DECIMAL(10,2),
  tax_amount DECIMAL(10,2),
  total_amount DECIMAL(10,2),
  addons JSONB,
  occasion VARCHAR(100),
  special_requests TEXT,
  guest_name VARCHAR(255),
  guest_email VARCHAR(255),
  guest_phone VARCHAR(20),
  partner_name VARCHAR(255),
  status VARCHAR(20) DEFAULT 'pending',
  payment_status VARCHAR(20) DEFAULT 'pending',
  payment_method VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE payment_orders (
  id SERIAL PRIMARY KEY,
  order_id VARCHAR(100) UNIQUE NOT NULL,
  booking_id VARCHAR(50) NOT NULL,
  payment_id VARCHAR(100),
  signature VARCHAR(255),
  amount INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  receipt VARCHAR(100),
  status VARCHAR(20) DEFAULT 'created',
  created_at TIMESTAMP DEFAULT NOW(),
  paid_at TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

CREATE TABLE refunds (
  id SERIAL PRIMARY KEY,
  refund_id VARCHAR(100) UNIQUE NOT NULL,
  payment_id VARCHAR(100) NOT NULL,
  booking_id VARCHAR(50) NOT NULL,
  amount INTEGER NOT NULL,
  reason TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
```

6. **Start backend server:**
```bash
node backend_payment_api.js
```

7. **Update Flutter API URL:**
In `lib/services/api_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:3000'; // or your backend URL
```

---

## 📱 Testing Checklist

- [ ] Flutter app runs without errors
- [ ] Payment test screen opens
- [ ] Razorpay checkout opens
- [ ] Test card payment succeeds
- [ ] Success screen appears
- [ ] (With backend) Email receipt received
- [ ] (With backend) Database updated

---

## 🎨 UI Components Created

1. **PaymentScreen** - Main payment screen with booking summary
2. **PaymentSuccessScreen** - Success confirmation screen
3. **PaymentTestScreen** - Test/demo screen (remove in production)

---

## 🔑 Test Credentials

### Test Cards
| Card | Number | Result |
|------|--------|--------|
| Visa | 4111 1111 1111 1111 | Success |
| Mastercard | 5555 5555 5555 4444 | Success |
| Failure | 4000 0000 0000 0002 | Failure |

### Test UPI
- `success@razorpay` - Success
- `failure@razorpay` - Failure

### Test Wallets
All wallets work in test mode

---

## 🐛 Troubleshooting

### Issue: Razorpay not opening
**Solution:** Make sure you've added the key in `payment_service.dart`

### Issue: Payment fails immediately
**Solution:** Check if you're using test mode keys (starts with `rzp_test_`)

### Issue: Email not received
**Solution:** 
- Check spam folder
- Verify email credentials in `.env`
- For Gmail, use App Password instead of regular password

### Issue: Backend connection error
**Solution:**
- Make sure backend is running
- Check API URL in `api_constants.dart`
- Verify CORS is enabled

---

## 📚 Documentation Files

- `RAZORPAY_PAYMENT_SETUP.md` - Complete setup guide
- `backend_payment_api.js` - Backend implementation
- `.env.example` - Environment variables template
- `PAYMENT_QUICK_START.md` - This file

---

## 🎯 Next Steps

1. ✅ Test payment flow works
2. ✅ Backend integration complete
3. ✅ Email receipts working
4. 🔄 Integrate with your booking flow
5. 🔄 Add payment history screen
6. 🔄 Implement refund UI
7. 🔄 Add payment analytics

---

## 💡 Pro Tips

- Always test with test mode keys first
- Keep test and live keys separate
- Never commit keys to git
- Use environment variables
- Test all payment methods
- Handle all error cases
- Send email receipts
- Log all transactions

---

## 🚀 Ready to Go Live?

When ready for production:

1. Complete Razorpay KYC
2. Get Live API keys
3. Update keys in production
4. Test with small amounts
5. Enable webhooks
6. Set up monitoring
7. Add analytics

---

**Need Help?**
- Razorpay Docs: https://razorpay.com/docs/
- Razorpay Support: support@razorpay.com
- Flutter Razorpay: https://pub.dev/packages/razorpay_flutter

---

**Happy Coding! 💻✨**
