/**
 * LoveNest Image Storage API - Backend Implementation
 * Node.js + Express + PostgreSQL
 */
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
app.use(express.json());

// Serve static files so the user dashboard can read image URLs directly without accessing filesystem directly
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Create temp directory for Multer
const tempDir = path.join(__dirname, 'temp');
if (!fs.existsSync(tempDir)) {
  fs.mkdirSync(tempDir, { recursive: true });
}

// Multer configuration
const upload = multer({ dest: tempDir });

// Admin-only authentication middleware
const authenticateAdmin = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required' });
  }

  // TODO: Verify JWT token and check if role is 'admin'
  req.user = { id: 'admin_id_from_token', role: 'admin' };
  next();
};

// Helper: Slugify hotel name for a stable, slug-based hotelId
const generateHotelId = (name) => {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');
};

// Helper: Ensure directory exists
const ensureDir = (dirPath) => {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
};

/**
 * 1. UPLOAD NEW IMAGE
 * POST /api/images/upload
 * Requires: hotel_uuid, hotel_name, category, image (file)
 */
app.post('/api/images/upload', authenticateAdmin, upload.single('image'), async (req, res) => {
  const { hotel_uuid, hotel_name, category } = req.body;
  if (!hotel_uuid || !hotel_name || !category || !req.file) {
    if (req.file) fs.unlinkSync(req.file.path);
    return res.status(400).json({ success: false, message: 'Missing required fields or image file' });
  }

  const client = await pool.connect();
  try {
    const hotelId = generateHotelId(hotel_name);
    const imageId = Date.now().toString(); // unique ID
    const ext = path.extname(req.file.originalname);
    const filename = `${imageId}${ext}`;
    
    // Structured path: /uploads/hotels/{hotelId}/{category}/
    const targetDir = path.join(__dirname, `uploads/hotels/${hotelId}/${category}`);
    ensureDir(targetDir);
    
    const targetPath = path.join(targetDir, filename);
    const fileUrl = `/uploads/hotels/${hotelId}/${category}/${filename}`;

    // Move file from temp to final destination
    fs.renameSync(req.file.path, targetPath);

    // Update database in the same request
    await client.query('BEGIN');
    
    const result = await client.query('SELECT images FROM hotels WHERE id = $1', [hotel_uuid]);
    if (result.rows.length === 0) {
      throw new Error('Hotel not found');
    }
    
    // Parse existing JSONB array or initialize new
    let images = result.rows[0].images;
    if (typeof images === 'string') {
      try { images = JSON.parse(images); } catch (e) { images = []; }
    }
    if (!Array.isArray(images)) images = [];
    
    // Add new image metadata
    const newImageData = { imageId, category, url: fileUrl };
    images.push(newImageData);
    
    await client.query('UPDATE hotels SET images = $1::jsonb WHERE id = $2', [JSON.stringify(images), hotel_uuid]);
    
    await client.query('COMMIT');
    
    res.status(201).json({ success: true, message: 'Image uploaded successfully', data: newImageData });
  } catch (error) {
    await client.query('ROLLBACK');
    if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    res.status(500).json({ success: false, message: 'Failed to upload image', error: error.message });
  } finally {
    client.release();
  }
});

/**
 * 2. UPDATE IMAGE
 * PUT /api/images/update
 * Requires: hotel_uuid, hotel_name, category, imageId, image (file)
 */
app.put('/api/images/update', authenticateAdmin, upload.single('image'), async (req, res) => {
  const { hotel_uuid, hotel_name, category, imageId } = req.body;
  if (!hotel_uuid || !hotel_name || !category || !imageId || !req.file) {
    if (req.file) fs.unlinkSync(req.file.path);
    return res.status(400).json({ success: false, message: 'Missing required fields or image file' });
  }

  const client = await pool.connect();
  try {
    const hotelId = generateHotelId(hotel_name);
    const ext = path.extname(req.file.originalname);
    const filename = `${imageId}${ext}`; // Keeping stable name
    
    const targetDir = path.join(__dirname, `uploads/hotels/${hotelId}/${category}`);
    ensureDir(targetDir);
    const targetPath = path.join(targetDir, filename);
    const newFileUrl = `/uploads/hotels/${hotelId}/${category}/${filename}`;

    await client.query('BEGIN');
    
    const result = await client.query('SELECT images FROM hotels WHERE id = $1', [hotel_uuid]);
    if (result.rows.length === 0) throw new Error('Hotel not found');
    
    let images = result.rows[0].images;
    if (typeof images === 'string') {
      try { images = JSON.parse(images); } catch (e) { images = []; }
    }
    if (!Array.isArray(images)) images = [];
    
    const imageIndex = images.findIndex(img => img.imageId === imageId);
    if (imageIndex === -1) {
      throw new Error('Image reference not found in database');
    }

    // Attempt to remove old file if the URL or extension changed
    const oldUrl = images[imageIndex].url;
    const oldPath = path.join(__dirname, oldUrl);
    if (fs.existsSync(oldPath) && oldUrl !== newFileUrl) {
      fs.unlinkSync(oldPath);
    }
    
    // Replace file in directory
    if (fs.existsSync(targetPath)) fs.unlinkSync(targetPath); // Remove existing exactly matching name if any
    fs.renameSync(req.file.path, targetPath);
    
    // Update reference without duplicates
    images[imageIndex] = { imageId, category, url: newFileUrl };
    
    await client.query('UPDATE hotels SET images = $1::jsonb WHERE id = $2', [JSON.stringify(images), hotel_uuid]);
    
    await client.query('COMMIT');
    res.json({ success: true, message: 'Image updated successfully', data: images[imageIndex] });
  } catch (error) {
    await client.query('ROLLBACK');
    if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    res.status(500).json({ success: false, message: 'Failed to update image', error: error.message });
  } finally {
    client.release();
  }
});

/**
 * 3. DELETE IMAGE
 * DELETE /api/images/delete
 * Requires: hotel_uuid, imageId
 */
app.delete('/api/images/delete', authenticateAdmin, async (req, res) => {
  const { hotel_uuid, imageId } = req.body;
  if (!hotel_uuid || !imageId) {
    return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    const result = await client.query('SELECT images FROM hotels WHERE id = $1', [hotel_uuid]);
    if (result.rows.length === 0) throw new Error('Hotel not found');
    
    let images = result.rows[0].images;
    if (typeof images === 'string') {
      try { images = JSON.parse(images); } catch (e) { images = []; }
    }
    if (!Array.isArray(images)) images = [];
    
    const imageIndex = images.findIndex(img => img.imageId === imageId);
    if (imageIndex === -1) throw new Error('Image reference not found in database');
    
    const fileUrl = images[imageIndex].url;
    const filePath = path.join(__dirname, fileUrl);
    
    // Remove the file from the filesystem
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
    
    // Remove the image record from the database
    images.splice(imageIndex, 1);
    
    await client.query('UPDATE hotels SET images = $1::jsonb WHERE id = $2', [JSON.stringify(images), hotel_uuid]);
    
    await client.query('COMMIT');
    res.json({ success: true, message: 'Image deleted from system completely' });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ success: false, message: 'Failed to delete image', error: error.message });
  } finally {
    client.release();
  }
});

/**
 * 4. CASCADE DELETE HOTEL IMAGES
 * DELETE /api/hotels/:id
 * This endpoints deletes the hotel and all its images from the system.
 */
app.delete('/api/hotels/:id', authenticateAdmin, async (req, res) => {
  const { id } = req.params;
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const result = await client.query('SELECT name FROM hotels WHERE id = $1', [id]);
    if (result.rows.length === 0) throw new Error('Hotel not found');
    
    const hotelName = result.rows[0].name;
    const hotelId = generateHotelId(hotelName);
    
    // Delete database record
    await client.query('DELETE FROM hotels WHERE id = $1', [id]);
    
    // Recursively remove all images under /uploads/hotels/{hotelId}/
    const dirPath = path.join(__dirname, `uploads/hotels/${hotelId}`);
    if (fs.existsSync(dirPath)) {
      fs.rmSync(dirPath, { recursive: true, force: true });
    }
    
    await client.query('COMMIT');
    res.json({ success: true, message: 'Hotel and all associated storage cleanly deleted' });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ success: false, message: 'Failed to delete hotel', error: error.message });
  } finally {
    client.release();
  }
});

// Start server
const PORT = process.env.IMAGE_PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Image Storage API Server running on port ${PORT}`);
});

module.exports = app;
