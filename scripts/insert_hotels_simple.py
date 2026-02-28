#!/usr/bin/env python3
"""
Simple script to insert 20 hotels into LoveNest database
Usage: python scripts/insert_hotels_simple.py YOUR_ACCESS_TOKEN
"""

import sys
import json
import requests

BASE_URL = 'https://nukpc39r.ap-southeast.insforge.app'

# 20 Hotels Data
hotels = [
    # Luxury Hotels (1-3)
    {
        "name": "The Royal Romance Palace",
        "description": "Experience ultimate luxury in our palatial suites with private pools, butler service, and breathtaking mountain views.",
        "city": "Udaipur",
        "address": "Lake Palace Road, Pichola Lake, Udaipur, Rajasthan 313001",
        "lat": 24.5760,
        "lng": 73.6810,
        "star_rating": 5,
        "couple_rating": 4.9,
        "price_per_night": 25000,
        "privacy_assured": True,
        "category": "luxury",
        "amenities": {"wifi": True, "pool": True, "spa": True, "restaurant": True, "bar": True, "gym": True, "room_service": True, "parking": True, "couples_massage": True, "jacuzzi": True, "butler_service": True},
        "images": ["https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800", "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800", "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800"],
        "is_active": True
    },
