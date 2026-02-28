/**
 * LoveNest Payment API - Backend Implementation
 * Node.js + Express + Razorpay + PostgreSQL
 * 
 * Install dependencies:
 * npm install express razorpay pg dotenv nodemailer crypto
 */

const express = require('express');
const Razorpay = require('razorpay');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
app.use(express.json());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Razorpay instance
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_TEST_KEY_ID,
  key_secret: process.env.RAZORPAY_TEST_KEY_SECRET,
});

// Email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required' });
  }

  // TODO: Verify JWT token here
  // For now, we'll just pass through
  req.user = { id: 'user_id_from_token' };
  next();
};

/**
 * 1. CREATE PAYMENT ORDER
 * POST /api/payments/create-order
 */
app.post('/api/payments/create-order', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const {
      booking_id,
      hotel_id,
      room_id,
      user_id,
      checkin_date,
      checkout_date,
      total_nights,
      room_price,
      addons_price,
      tax_amount,
      total_amount,
      addons,
      occasion,
      special_requests,
      guest_name,
      guest_email,
      guest_phone,
      partner_name,
    } = req.body;

    // Validate required fields
    if (!booking_id || !total_amount || !guest_email) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields',
      });
    }

    // Convert amount to paise (1 INR = 100 paise)
    const amountInPaise = Math.round(total_amount * 100);

    // Create Razorpay order
    const razorpayOrder = await razorpay.orders.create({
      amount: amountInPaise,
      currency: 'INR',
      receipt: `receipt_${booking_id}`,
      notes: {
        booking_id: booking_id,
        guest_email: guest_email,
        guest_name: guest_name,
      },
    });

    console.log('Razorpay order created:', razorpayOrder.id);

    // Start transaction
    await client.query('BEGIN');

    // Save booking to database
    await client.query(
      `INSERT INTO bookings (
        booking_id, hotel_id, room_id, user_id, 
        checkin_date, checkout_date, total_nights,
        room_price, addons_price, tax_amount, total_amount,
        addons, occasion, special_requests,
        guest_name, guest_email, guest_phone, partner_name,
        status, payment_status, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, NOW())
      ON CONFLICT (booking_id) DO UPDATE SET
        status = 'pending',
        payment_status = 'pending'`,
      [
        booking_id, hotel_id, room_id, user_id,
        checkin_date, checkout_date, total_nights,
        room_price, addons_price, tax_amount, total_amount,
        JSON.stringify(addons), occasion, special_requests,
        guest_name, guest_email, guest_phone, partner_name,
        'pending', 'pending'
      ]
    );

    // Save payment order to database
    await client.query(
      `INSERT INTO payment_orders (
        order_id, booking_id, amount, currency, receipt, status, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
      [razorpayOrder.id, booking_id, amountInPaise, 'INR', razorpayOrder.receipt, 'created']
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      data: {
        order_id: razorpayOrder.id,
        booking_id: booking_id,
        amount: amountInPaise,
        currency: 'INR',
        receipt: razorpayOrder.receipt,
        created_at: new Date().toISOString(),
      },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create payment order',
      error: error.message,
    });
  } finally {
    client.release();
  }
});

/**
 * 2. VERIFY PAYMENT
 * POST /api/payments/verify
 */
app.post('/api/payments/verify', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { payment_id, order_id, signature, booking_id } = req.body;

    // Validate required fields
    if (!payment_id || !order_id || !signature || !booking_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields',
      });
    }

    // Verify signature
    const generatedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_TEST_KEY_SECRET)
      .update(`${order_id}|${payment_id}`)
      .digest('hex');

    const isValid = generatedSignature === signature;

    if (!isValid) {
      return res.status(400).json({
        success: false,
        verified: false,
        message: 'Invalid payment signature',
      });
    }

    // Start transaction
    await client.query('BEGIN');

    // Update payment order
    await client.query(
      `UPDATE payment_orders 
       SET payment_id = $1, signature = $2, status = $3, paid_at = NOW() 
       WHERE order_id = $4`,
      [payment_id, signature, 'paid', order_id]
    );

    // Update booking status
    await client.query(
      `UPDATE bookings 
       SET status = $1, payment_status = $2, payment_method = $3 
       WHERE booking_id = $4`,
      ['confirmed', 'paid', 'razorpay', booking_id]
    );

    await client.query('COMMIT');

    console.log('Payment verified successfully:', payment_id);

    res.json({
      success: true,
      verified: true,
      message: 'Payment verified successfully',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Verify payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Payment verification failed',
      error: error.message,
    });
  } finally {
    client.release();
  }
});

/**
 * 3. SEND PAYMENT RECEIPT
 * POST /api/payments/send-receipt
 */
app.post('/api/payments/send-receipt', authenticateToken, async (req, res) => {
  try {
    const { booking_id } = req.body;

    if (!booking_id) {
      return res.status(400).json({
        success: false,
        message: 'Booking ID required',
      });
    }

    // Fetch booking and payment details
    const result = await pool.query(
      `SELECT 
        b.booking_id, b.checkin_date, b.checkout_date, b.total_nights,
        b.room_price, b.addons_price, b.tax_amount, b.total_amount,
        b.guest_name, b.guest_email, b.guest_phone, b.partner_name,
        b.occasion, b.special_requests,
        p.payment_id, p.amount, p.paid_at, p.order_id,
        h.name as hotel_name, h.address as hotel_address,
        r.type as room_type
       FROM bookings b
       JOIN payment_orders p ON b.booking_id = p.booking_id
       LEFT JOIN hotels h ON b.hotel_id = h.id
       LEFT JOIN rooms r ON b.room_id = r.id
       WHERE b.booking_id = $1 AND p.status = 'paid'`,
      [booking_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found or payment not completed',
      });
    }

    const booking = result.rows[0];

    // Create email HTML
    const emailHTML = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
          }
          .container {
            max-width: 600px;
            margin: 0 auto;
            background: #ffffff;
          }
          .header {
            background: linear-gradient(135deg, #8B1538 0%, #A91D4A 100%);
            color: white;
            padding: 30px 20px;
            text-align: center;
          }
          .header h1 {
            margin: 0;
            font-size: 32px;
          }
          .header p {
            margin: 10px 0 0 0;
            font-size: 16px;
            opacity: 0.9;
          }
          .content {
            padding: 30px 20px;
          }
          .greeting {
            font-size: 18px;
            margin-bottom: 20px;
          }
          .section {
            margin-bottom: 30px;
          }
          .section-title {
            font-size: 20px;
            font-weight: bold;
            color: #8B1538;
            margin-bottom: 15px;
            border-bottom: 2px solid #8B1538;
            padding-bottom: 5px;
          }
          .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #eee;
          }
          .detail-label {
            color: #666;
            font-size: 14px;
          }
          .detail-value {
            font-weight: 600;
            font-size: 14px;
            text-align: right;
          }
          .total-row {
            background: #f9f9f9;
            padding: 15px;
            margin-top: 10px;
            border-radius: 8px;
          }
          .total-row .detail-label {
            font-size: 18px;
            font-weight: bold;
            color: #333;
          }
          .total-row .detail-value {
            font-size: 24px;
            font-weight: bold;
            color: #8B1538;
          }
          .info-box {
            background: #f0f8ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
          }
          .footer {
            background: #f9f9f9;
            padding: 20px;
            text-align: center;
            font-size: 12px;
            color: #666;
          }
          .button {
            display: inline-block;
            padding: 12px 30px;
            background: #8B1538;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin: 20px 0;
            font-weight: bold;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🏩 LoveNest</h1>
            <p>Payment Receipt & Booking Confirmation</p>
          </div>
          
          <div class="content">
            <div class="greeting">
              Dear ${booking.guest_name}${booking.partner_name ? ' & ' + booking.partner_name : ''},
            </div>
            
            <p>
              Thank you for choosing LoveNest! Your payment has been successfully processed 
              and your booking is confirmed. We're excited to host you for your special ${booking.occasion || 'stay'}.
            </p>
            
            <div class="section">
              <div class="section-title">📋 Booking Details</div>
              <div class="detail-row">
                <span class="detail-label">Booking ID</span>
                <span class="detail-value">${booking.booking_id}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Hotel</span>
                <span class="detail-value">${booking.hotel_name || 'N/A'}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Room Type</span>
                <span class="detail-value">${booking.room_type || 'N/A'}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Check-in</span>
                <span class="detail-value">${new Date(booking.checkin_date).toLocaleDateString('en-IN', { 
                  day: 'numeric', 
                  month: 'long', 
                  year: 'numeric' 
                })}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Check-out</span>
                <span class="detail-value">${new Date(booking.checkout_date).toLocaleDateString('en-IN', { 
                  day: 'numeric', 
                  month: 'long', 
                  year: 'numeric' 
                })}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Number of Nights</span>
                <span class="detail-value">${booking.total_nights}</span>
              </div>
              ${booking.occasion ? `
              <div class="detail-row">
                <span class="detail-label">Occasion</span>
                <span class="detail-value">${booking.occasion}</span>
              </div>
              ` : ''}
            </div>
            
            <div class="section">
              <div class="section-title">💰 Payment Details</div>
              <div class="detail-row">
                <span class="detail-label">Payment ID</span>
                <span class="detail-value">${booking.payment_id}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Order ID</span>
                <span class="detail-value">${booking.order_id}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Payment Date</span>
                <span class="detail-value">${new Date(booking.paid_at).toLocaleString('en-IN')}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Room Charges (${booking.total_nights} nights)</span>
                <span class="detail-value">₹${booking.room_price.toFixed(2)}</span>
              </div>
              ${booking.addons_price > 0 ? `
              <div class="detail-row">
                <span class="detail-label">Add-ons</span>
                <span class="detail-value">₹${booking.addons_price.toFixed(2)}</span>
              </div>
              ` : ''}
              <div class="detail-row">
                <span class="detail-label">Taxes & Fees</span>
                <span class="detail-value">₹${booking.tax_amount.toFixed(2)}</span>
              </div>
              <div class="total-row">
                <div class="detail-row" style="border: none; padding: 0;">
                  <span class="detail-label">Total Amount Paid</span>
                  <span class="detail-value">₹${booking.total_amount.toFixed(2)}</span>
                </div>
              </div>
            </div>
            
            <div class="info-box">
              <strong>📧 Contact Information</strong><br>
              Email: ${booking.guest_email}<br>
              Phone: ${booking.guest_phone}
            </div>
            
            ${booking.special_requests ? `
            <div class="info-box">
              <strong>📝 Special Requests</strong><br>
              ${booking.special_requests}
            </div>
            ` : ''}
            
            <p style="margin-top: 30px;">
              We look forward to making your ${booking.occasion || 'stay'} truly memorable! 
              If you have any questions or need assistance, please don't hesitate to contact us.
            </p>
            
            <center>
              <a href="https://lovenest.com/bookings/${booking.booking_id}" class="button">
                View Booking Details
              </a>
            </center>
          </div>
          
          <div class="footer">
            <strong>LoveNest - Where Love Finds Home</strong><br>
            Email: support@lovenest.com | Phone: +91-1234567890<br>
            <br>
            This is an automated email. Please do not reply to this message.<br>
            © 2026 LoveNest. All rights reserved.
          </div>
        </div>
      </body>
      </html>
    `;

    // Send email
    await transporter.sendMail({
      from: '"LoveNest" <noreply@lovenest.com>',
      to: booking.guest_email,
      subject: `Payment Receipt - Booking ${booking_id} Confirmed 🏩`,
      html: emailHTML,
    });

    console.log('Receipt sent to:', booking.guest_email);

    res.json({
      success: true,
      message: 'Receipt sent successfully',
    });
  } catch (error) {
    console.error('Send receipt error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send receipt',
      error: error.message,
    });
  }
});

/**
 * 4. PROCESS REFUND
 * POST /api/payments/refund
 */
app.post('/api/payments/refund', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { payment_id, booking_id, amount, reason } = req.body;

    if (!payment_id || !booking_id || !amount) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields',
      });
    }

    // Create refund
    const refund = await razorpay.payments.refund(payment_id, {
      amount: amount, // Amount in paise
      notes: {
        booking_id: booking_id,
        reason: reason || 'Booking cancelled',
      },
    });

    console.log('Refund created:', refund.id);

    // Start transaction
    await client.query('BEGIN');

    // Save refund to database
    await client.query(
      `INSERT INTO refunds (
        refund_id, payment_id, booking_id, amount, reason, status, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
      [refund.id, payment_id, booking_id, amount, reason, refund.status]
    );

    // Update booking status
    await client.query(
      `UPDATE bookings 
       SET status = $1, payment_status = $2 
       WHERE booking_id = $3`,
      ['cancelled', 'refunded', booking_id]
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      refund_id: refund.id,
      status: refund.status,
      message: 'Refund processed successfully',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Refund error:', error);
    res.status(500).json({
      success: false,
      message: 'Refund processing failed',
      error: error.message,
    });
  } finally {
    client.release();
  }
});

/**
 * 5. GET PAYMENT DETAILS
 * GET /api/payments/:booking_id
 */
app.get('/api/payments/:booking_id', authenticateToken, async (req, res) => {
  try {
    const { booking_id } = req.params;

    const result = await pool.query(
      `SELECT 
        p.payment_id, p.order_id, p.signature, p.amount, 
        p.currency, p.status, p.paid_at,
        b.booking_id, b.total_amount
       FROM payment_orders p
       JOIN bookings b ON p.booking_id = b.booking_id
       WHERE p.booking_id = $1`,
      [booking_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found',
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Get payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch payment details',
      error: error.message,
    });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Payment API server running on port ${PORT}`);
  console.log(`📝 Test mode: ${process.env.RAZORPAY_TEST_KEY_ID ? 'ENABLED' : 'DISABLED'}`);
});

module.exports = app;
