# 💳 Razorpay Payment Integration - Complete Setup Guide

## 🎯 Overview

This guide covers the complete Razorpay payment integration for LoveNest app with:
- ✅ Test mode payment processing
- ✅ Payment verification
- ✅ Email receipt sending
- ✅ Refund processing
- ✅ All payments in Indian Rupees (INR)

---

## 📋 Prerequisites

1. **Razorpay Account** (Test Mode)
   - Sign up at: https://razorpay.com/
   - Get your Test API Keys from Dashboard

2. **Flutter Dependencies** (Already Added)
   ```yaml
   razorpay_flutter: ^1.3.7
   mailer: ^6.1.2
   ```

---

## 🔑 Step 1: Get Razorpay Test Keys

1. Login to Razorpay Dashboard: https://dashboard.razorpay.com/
2. Go to **Settings** → **API Keys**
3. Under **Test Mode**, generate keys:
   - `Key ID` (starts with `rzp_test_`)
   - `Key Secret`

4. Update in `lib/services/payment_service.dart`:
   ```dart
   static const String razorpayTestKeyId = 'rzp_test_YOUR_KEY_ID';
   static const String razorpayTestKeySecret = 'YOUR_TEST_KEY_SECRET';
   ```

---

## 🏗️ Step 2: Backend API Implementation

### Required Backend Endpoints

#### 1. Create Payment Order
**Endpoint:** `POST /api/payments/create-order`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer <user_token>"
}
```

**Request Body:**
```json
{
  "booking_id": "BK123456",
  "hotel_id": "HTL001",
  "room_id": "RM001",
  "user_id": "USR001",
  "checkin_date": "2026-03-15T00:00:00Z",
  "checkout_date": "2026-03-17T00:00:00Z",
  "total_nights": 2,
  "room_price": 8000.00,
  "addons_price": 1500.00,
  "tax_amount": 1425.00,
  "total_amount": 10925.00,
  "addons": ["Rose Decoration", "Candlelight Dinner"],
  "occasion": "Anniversary",
  "special_requests": "Late checkout if possible",
  "guest_name": "John Doe",
  "guest_email": "john@example.com",
  "guest_phone": "+919876543210",
  "partner_name": "Jane Doe"
}
```

**Backend Implementation (Node.js):**
```javascript
const Razorpay = require('razorpay');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_TEST_KEY_ID,
  key_secret: process.env.RAZORPAY_TEST_KEY_SECRET
});

app.post('/api/payments/create-order', async (req, res) => {
  try {
    const { booking_id, total_amount, guest_email } = req.body;
    
    // Convert amount to paise (1 INR = 100 paise)
    const amountInPaise = Math.round(total_amount * 100);
    
    // Create Razorpay order
    const order = await razorpay.orders.create({
      amount: amountInPaise,
      currency: 'INR',
      receipt: `receipt_${booking_id}`,
      notes: {
        booking_id: booking_id,
        guest_email: guest_email
      }
    });
    
    // Save order to database
    await db.query(
      `INSERT INTO payment_orders 
       (order_id, booking_id, amount, currency, status, created_at) 
       VALUES ($1, $2, $3, $4, $5, NOW())`,
      [order.id, booking_id, amountInPaise, 'INR', 'created']
    );
    
    res.status(201).json({
      success: true,
      data: {
        order_id: order.id,
        booking_id: booking_id,
        amount: amountInPaise,
        currency: 'INR',
        receipt: order.receipt,
        created_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create payment order'
    });
  }
});
```

**Response:**
```json
{
  "success": true,
  "data": {
    "order_id": "order_MNOPqrstuvwxyz",
    "booking_id": "BK123456",
    "amount": 1092500,
    "currency": "INR",
    "receipt": "receipt_BK123456",
    "created_at": "2026-02-28T10:30:00Z"
  }
}
```

---

#### 2. Verify Payment
**Endpoint:** `POST /api/payments/verify`

**Request Body:**
```json
{
  "payment_id": "pay_ABCDefghijklmn",
  "order_id": "order_MNOPqrstuvwxyz",
  "signature": "abc123def456...",
  "booking_id": "BK123456"
}
```

**Backend Implementation:**
```javascript
const crypto = require('crypto');

app.post('/api/payments/verify', async (req, res) => {
  try {
    const { payment_id, order_id, signature, booking_id } = req.body;
    
    // Verify signature
    const generatedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_TEST_KEY_SECRET)
      .update(`${order_id}|${payment_id}`)
      .digest('hex');
    
    const isValid = generatedSignature === signature;
    
    if (isValid) {
      // Update payment status in database
      await db.query(
        `UPDATE payment_orders 
         SET payment_id = $1, signature = $2, status = $3, paid_at = NOW() 
         WHERE order_id = $4`,
        [payment_id, signature, 'paid', order_id]
      );
      
      // Update booking status
      await db.query(
        `UPDATE bookings 
         SET status = $1, payment_status = $2 
         WHERE booking_id = $3`,
        ['confirmed', 'paid', booking_id]
      );
      
      res.json({
        success: true,
        verified: true,
        message: 'Payment verified successfully'
      });
    } else {
      res.status(400).json({
        success: false,
        verified: false,
        message: 'Invalid payment signature'
      });
    }
  } catch (error) {
    console.error('Verify payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Payment verification failed'
    });
  }
});
```

**Response:**
```json
{
  "success": true,
  "verified": true,
  "message": "Payment verified successfully"
}
```

---

#### 3. Send Payment Receipt
**Endpoint:** `POST /api/payments/send-receipt`

**Request Body:**
```json
{
  "booking_id": "BK123456"
}
```

**Backend Implementation:**
```javascript
const nodemailer = require('nodemailer');

// Configure email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail', // or your email service
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

app.post('/api/payments/send-receipt', async (req, res) => {
  try {
    const { booking_id } = req.body;
    
    // Fetch booking and payment details
    const result = await db.query(
      `SELECT b.*, p.payment_id, p.amount, p.paid_at, 
              h.name as hotel_name, r.type as room_type,
              u.email as guest_email, u.name as guest_name
       FROM bookings b
       JOIN payment_orders p ON b.booking_id = p.booking_id
       JOIN hotels h ON b.hotel_id = h.id
       JOIN rooms r ON b.room_id = r.id
       JOIN users u ON b.user_id = u.id
       WHERE b.booking_id = $1`,
      [booking_id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }
    
    const booking = result.rows[0];
    
    // Create email HTML
    const emailHTML = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #8B1538; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .detail-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #ddd; }
          .total { font-size: 20px; font-weight: bold; color: #8B1538; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🏩 LoveNest</h1>
            <h2>Payment Receipt</h2>
          </div>
          <div class="content">
            <h3>Dear ${booking.guest_name},</h3>
            <p>Thank you for your booking! Your payment has been successfully processed.</p>
            
            <h3>Booking Details</h3>
            <div class="detail-row">
              <span>Booking ID:</span>
              <strong>${booking.booking_id}</strong>
            </div>
            <div class="detail-row">
              <span>Hotel:</span>
              <strong>${booking.hotel_name}</strong>
            </div>
            <div class="detail-row">
              <span>Room Type:</span>
              <strong>${booking.room_type}</strong>
            </div>
            <div class="detail-row">
              <span>Check-in:</span>
              <strong>${new Date(booking.checkin_date).toLocaleDateString()}</strong>
            </div>
            <div class="detail-row">
              <span>Check-out:</span>
              <strong>${new Date(booking.checkout_date).toLocaleDateString()}</strong>
            </div>
            
            <h3>Payment Details</h3>
            <div class="detail-row">
              <span>Payment ID:</span>
              <strong>${booking.payment_id}</strong>
            </div>
            <div class="detail-row">
              <span>Payment Date:</span>
              <strong>${new Date(booking.paid_at).toLocaleString()}</strong>
            </div>
            <div class="detail-row total">
              <span>Total Amount Paid:</span>
              <strong>₹${(booking.amount / 100).toFixed(2)}</strong>
            </div>
            
            <p style="margin-top: 30px;">
              We look forward to hosting you! If you have any questions, please contact us.
            </p>
            
            <p>
              <strong>LoveNest Support</strong><br>
              Email: support@lovenest.com<br>
              Phone: +91-1234567890
            </p>
          </div>
        </div>
      </body>
      </html>
    `;
    
    // Send email
    await transporter.sendMail({
      from: '"LoveNest" <noreply@lovenest.com>',
      to: booking.guest_email,
      subject: `Payment Receipt - Booking ${booking_id}`,
      html: emailHTML
    });
    
    res.json({
      success: true,
      message: 'Receipt sent successfully'
    });
  } catch (error) {
    console.error('Send receipt error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send receipt'
    });
  }
});
```

---

#### 4. Process Refund
**Endpoint:** `POST /api/payments/refund`

**Request Body:**
```json
{
  "payment_id": "pay_ABCDefghijklmn",
  "booking_id": "BK123456",
  "amount": 1092500,
  "reason": "Booking cancelled by user"
}
```

**Backend Implementation:**
```javascript
app.post('/api/payments/refund', async (req, res) => {
  try {
    const { payment_id, booking_id, amount, reason } = req.body;
    
    // Create refund
    const refund = await razorpay.payments.refund(payment_id, {
      amount: amount, // Amount in paise
      notes: {
        booking_id: booking_id,
        reason: reason
      }
    });
    
    // Save refund to database
    await db.query(
      `INSERT INTO refunds 
       (refund_id, payment_id, booking_id, amount, reason, status, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
      [refund.id, payment_id, booking_id, amount, reason, refund.status]
    );
    
    // Update booking status
    await db.query(
      `UPDATE bookings 
       SET status = $1, payment_status = $2 
       WHERE booking_id = $3`,
      ['cancelled', 'refunded', booking_id]
    );
    
    res.json({
      success: true,
      refund_id: refund.id,
      message: 'Refund processed successfully'
    });
  } catch (error) {
    console.error('Refund error:', error);
    res.status(500).json({
      success: false,
      message: 'Refund processing failed'
    });
  }
});
```

---

## 📊 Step 3: Database Schema

```sql
-- Payment Orders Table
CREATE TABLE payment_orders (
  id SERIAL PRIMARY KEY,
  order_id VARCHAR(100) UNIQUE NOT NULL,
  booking_id VARCHAR(50) NOT NULL,
  payment_id VARCHAR(100),
  signature VARCHAR(255),
  amount INTEGER NOT NULL, -- Amount in paise
  currency VARCHAR(3) DEFAULT 'INR',
  status VARCHAR(20) DEFAULT 'created', -- created, paid, failed
  created_at TIMESTAMP DEFAULT NOW(),
  paid_at TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Refunds Table
CREATE TABLE refunds (
  id SERIAL PRIMARY KEY,
  refund_id VARCHAR(100) UNIQUE NOT NULL,
  payment_id VARCHAR(100) NOT NULL,
  booking_id VARCHAR(50) NOT NULL,
  amount INTEGER NOT NULL, -- Amount in paise
  reason TEXT,
  status VARCHAR(20) DEFAULT 'pending', -- pending, processed, failed
  created_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Add payment columns to bookings table
ALTER TABLE bookings 
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'pending', -- pending, paid, refunded, failed
ADD COLUMN payment_method VARCHAR(50);
```

---

## 🧪 Step 4: Testing Payment Flow

### Test Cards (Razorpay Test Mode)

| Card Number | Expiry | CVV | Result |
|-------------|--------|-----|--------|
| 4111 1111 1111 1111 | Any future date | Any 3 digits | Success |
| 5555 5555 5555 4444 | Any future date | Any 3 digits | Success |
| 4000 0000 0000 0002 | Any future date | Any 3 digits | Failure |

### Test UPI IDs
- `success@razorpay` - Success
- `failure@razorpay` - Failure

### Testing Steps

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Navigate to payment screen** with test booking data

3. **Click "Pay Now"** button

4. **Use test card:** 4111 1111 1111 1111

5. **Verify:**
   - Payment success screen appears
   - Email receipt is sent
   - Backend updates booking status
   - Payment details saved in database

---

## 🔐 Step 5: Environment Variables

Create `.env` file in your backend:

```env
# Razorpay Test Keys
RAZORPAY_TEST_KEY_ID=rzp_test_YOUR_KEY_ID
RAZORPAY_TEST_KEY_SECRET=YOUR_TEST_KEY_SECRET

# Email Configuration
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/lovenest

# App
NODE_ENV=development
PORT=3000
```

---

## 📱 Step 6: Flutter Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:lovenest/screens/payment_screen.dart';
import 'package:lovenest/models/payment_model.dart';

// Navigate to payment screen
void initiatePayment(BuildContext context) {
  final bookingRequest = BookingPaymentRequest(
    bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
    hotelId: 'HTL001',
    roomId: 'RM001',
    userId: 'USR001',
    checkInDate: DateTime.now().add(Duration(days: 7)),
    checkOutDate: DateTime.now().add(Duration(days: 9)),
    totalNights: 2,
    roomPrice: 8000.00,
    addonsPrice: 1500.00,
    taxAmount: 1425.00,
    totalAmount: 10925.00,
    addons: ['Rose Decoration', 'Candlelight Dinner'],
    occasion: 'Anniversary',
    specialRequests: 'Late checkout if possible',
    guestName: 'John Doe',
    guestEmail: 'john@example.com',
    guestPhone: '+919876543210',
    partnerName: 'Jane Doe',
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentScreen(
        bookingRequest: bookingRequest,
        authToken: 'your-auth-token',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        userPhone: '+919876543210',
      ),
    ),
  );
}
```

---

## ✅ Checklist

- [ ] Razorpay account created
- [ ] Test API keys obtained
- [ ] Keys updated in `payment_service.dart`
- [ ] Backend endpoints implemented
- [ ] Database tables created
- [ ] Email service configured
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Test payment with test card
- [ ] Verify email receipt sent
- [ ] Test refund flow

---

## 🚀 Going Live (Production)

When ready for production:

1. **Switch to Live Mode** in Razorpay Dashboard
2. **Get Live API Keys** (starts with `rzp_live_`)
3. **Update keys** in production environment
4. **Complete KYC** verification on Razorpay
5. **Test with real cards** (small amounts)
6. **Enable webhooks** for payment status updates
7. **Set up monitoring** and alerts

---

## 📞 Support

- **Razorpay Docs:** https://razorpay.com/docs/
- **Razorpay Support:** support@razorpay.com
- **Test Dashboard:** https://dashboard.razorpay.com/

---

## 🎉 Features Implemented

✅ Complete payment flow with Razorpay  
✅ Test mode integration  
✅ Payment verification  
✅ Email receipt sending  
✅ Refund processing  
✅ All amounts in INR  
✅ Beautiful payment UI  
✅ Success/failure handling  
✅ Secure payment processing  

---

**Ready to accept payments! 💰**
