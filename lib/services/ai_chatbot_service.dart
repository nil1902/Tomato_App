// import 'dart:convert'; // Unused
// import 'package:http/http.dart' as http; // Unused
// import 'api_constants.dart'; // Unused

class AIChatbotService {
  // Knowledge base for the chatbot
  static const Map<String, dynamic> knowledgeBase = {
    'booking': {
      'keywords': ['book', 'booking', 'reserve', 'reservation', 'stay'],
      'responses': [
        'To make a booking:\n1. Browse our romantic hotels\n2. Select your dates\n3. Choose your room\n4. Add romantic extras (optional)\n5. Complete payment\n\nNeed help with a specific booking? Please share your booking ID.',
        'You can book a hotel by:\n• Browsing the "Nests" tab\n• Using the search feature\n• Checking our special offers\n\nAll bookings come with instant confirmation!',
      ],
    },
    'cancellation': {
      'keywords': ['cancel', 'cancellation', 'refund', 'change booking'],
      'responses': [
        'Cancellation Policy:\n• Free cancellation up to 24 hours before check-in\n• After 24 hours, cancellation fees may apply\n• Refunds processed within 5-7 business days\n\nTo cancel: Go to My Bookings → Select booking → Cancel',
        'Need to cancel? Here\'s how:\n1. Open "My Bookings"\n2. Select your reservation\n3. Tap "Cancel Booking"\n4. Confirm cancellation\n\nRefunds are processed automatically based on the hotel policy.',
      ],
    },
    'payment': {
      'keywords': ['payment', 'pay', 'card', 'credit', 'debit', 'paypal'],
      'responses': [
        'We accept:\n• Visa, Mastercard, Amex\n• Debit Cards\n• PayPal\n• Apple Pay & Google Pay\n\nAll payments are secure and encrypted. Need help with a payment issue? Contact support@lovenest.com',
        'Payment is easy and secure! We support all major credit cards, debit cards, and digital wallets. Your payment information is encrypted and never stored.',
      ],
    },
    'loyalty': {
      'keywords': ['points', 'loyalty', 'rewards', 'earn', 'redeem'],
      'responses': [
        'Loyalty Program:\n• Earn 1 point per \$1 spent\n• 100 points = \$1 discount\n• Bonus points for reviews\n• Referral rewards: 500 points\n\nCheck your points in the "Loyalty" section!',
        'Our loyalty program rewards you for every booking!\n\nTiers:\n🥉 Bronze: 0-999 points\n🥈 Silver: 1,000-4,999 points\n🥇 Gold: 5,000+ points\n\nHigher tiers unlock exclusive perks!',
      ],
    },
    'addons': {
      'keywords': ['addon', 'add-on', 'extra', 'rose', 'champagne', 'spa', 'romantic'],
      'responses': [
        'Romantic Add-ons:\n🌹 Rose Petals & Candles\n🍾 Champagne & Chocolates\n💆 Couples Spa Package\n🎁 Gift Baskets\n🎵 Live Music\n\nAdd them during booking or anytime before check-in!',
        'Make your stay extra special with our romantic add-ons! Choose from decorations, food & beverages, spa experiences, and gifts. Available in the "Romantic Add-ons" section.',
      ],
    },
    'coupons': {
      'keywords': ['coupon', 'discount', 'offer', 'promo', 'deal'],
      'responses': [
        'Current Offers:\n• Check "Coupons & Offers" for active deals\n• First booking discount available\n• Seasonal promotions\n• Loyalty member exclusives\n\nCoupons are automatically applied at checkout!',
        'Save more with our exclusive offers! Visit the "Coupons & Offers" section to see all available deals. Don\'t forget to check your email for personalized discounts!',
      ],
    },
    'account': {
      'keywords': ['account', 'profile', 'password', 'email', 'settings'],
      'responses': [
        'Account Management:\n• Update profile: Profile → Edit\n• Change password: Settings → Security\n• Email preferences: Settings → Notifications\n• Privacy settings: Settings → Privacy\n\nNeed to reset your password? Use "Forgot Password" on login.',
        'Manage your account in the Profile section. You can update personal info, change password, manage notifications, and control privacy settings.',
      ],
    },
    'safety': {
      'keywords': ['safe', 'safety', 'secure', 'privacy', 'protection'],
      'responses': [
        'Your Safety Matters:\n✓ All hotels verified\n✓ Secure payment processing\n✓ Privacy protection\n✓ 24/7 support available\n✓ COVID-19 protocols\n\nView full safety guidelines in Help & Support.',
        'We prioritize your safety and privacy. All bookings are secure, hotels are verified, and your data is protected. Emergency support available 24/7.',
      ],
    },
    'contact': {
      'keywords': ['contact', 'support', 'help', 'call', 'email', 'phone'],
      'responses': [
        'Contact Us:\n📧 Email: support@lovenest.com\n📞 Phone: 1-800-LOVE-NEST (24/7)\n💬 Live Chat: Available now\n📍 Visit: 123 Romance Street, Love City\n\nWe\'re here to help!',
        'Need immediate assistance?\n• Chat with us (fastest)\n• Call 1-800-LOVE-NEST\n• Email support@lovenest.com\n\nOur team responds within minutes!',
      ],
    },
    'checkin': {
      'keywords': ['check in', 'check-in', 'checkin', 'arrival', 'check out', 'checkout'],
      'responses': [
        'Check-in/Check-out:\n• Standard check-in: 3:00 PM\n• Standard check-out: 11:00 AM\n• Early check-in: Subject to availability\n• Late check-out: Request at front desk\n\nSpecific times vary by hotel.',
        'Check-in is typically at 3 PM and check-out at 11 AM. Need early check-in or late check-out? Contact the hotel directly or request it in your booking notes.',
      ],
    },
    'amenities': {
      'keywords': ['amenity', 'amenities', 'facility', 'facilities', 'wifi', 'pool', 'gym'],
      'responses': [
        'Common Amenities:\n• Free WiFi\n• Swimming Pool\n• Fitness Center\n• Restaurant & Bar\n• Room Service\n• Spa Services\n• Parking\n\nCheck each hotel\'s page for specific amenities.',
        'Our hotels offer various amenities including WiFi, pools, gyms, restaurants, and more. Each hotel listing shows available facilities. Look for the amenities section on the hotel details page!',
      ],
    },
  };

  // Generate intelligent response based on user message
  String generateResponse(String userMessage) {
    final msg = userMessage.toLowerCase().trim();

    // Greetings
    if (_containsAny(msg, ['hello', 'hi', 'hey', 'good morning', 'good evening'])) {
      return '👋 Hello! Welcome to LoveNest! I\'m here to help you plan the perfect romantic getaway. What can I assist you with today?';
    }

    // Thanks
    if (_containsAny(msg, ['thank', 'thanks', 'appreciate'])) {
      return '💕 You\'re very welcome! Is there anything else I can help you with? I\'m here to make your experience perfect!';
    }

    // Goodbye
    if (_containsAny(msg, ['bye', 'goodbye', 'see you', 'later'])) {
      return '👋 Goodbye! Have a wonderful day and enjoy your romantic getaway! Feel free to chat anytime you need help. 💕';
    }

    // Search knowledge base
    for (var entry in knowledgeBase.entries) {
      final category = entry.value as Map<String, dynamic>;
      final keywords = category['keywords'] as List<String>;
      
      if (_containsAny(msg, keywords)) {
        final responses = category['responses'] as List<String>;
        // Return a random response from the category
        return responses[DateTime.now().millisecond % responses.length];
      }
    }

    // Check for specific questions
    if (msg.contains('how') && msg.contains('work')) {
      return 'LoveNest makes booking romantic getaways easy!\n\n'
          '1. Browse curated romantic hotels\n'
          '2. Select your perfect dates\n'
          '3. Choose your room & add-ons\n'
          '4. Book securely\n'
          '5. Earn loyalty points\n\n'
          'What would you like to know more about?';
    }

    if (msg.contains('price') || msg.contains('cost') || msg.contains('expensive')) {
      return 'Our hotels range from budget-friendly to luxury options. Prices vary based on:\n'
          '• Location\n'
          '• Room type\n'
          '• Season\n'
          '• Add-ons\n\n'
          'Check our "Coupons & Offers" section for great deals! You can also earn loyalty points to save on future bookings.';
    }

    if (msg.contains('recommend') || msg.contains('suggestion') || msg.contains('best')) {
      return '🌟 For the best romantic experience, I recommend:\n\n'
          '• Browse hotels with high ratings (4.5+ stars)\n'
          '• Add romantic extras like rose petals & champagne\n'
          '• Book during weekdays for better rates\n'
          '• Check our seasonal offers\n\n'
          'What type of experience are you looking for?';
    }

    if (msg.contains('location') || msg.contains('where') || msg.contains('city')) {
      return 'We have romantic hotels in amazing locations:\n'
          '• Beach resorts\n'
          '• Mountain retreats\n'
          '• City escapes\n'
          '• Countryside hideaways\n\n'
          'Use the search feature to find hotels in your preferred location!';
    }

    // Default response with helpful suggestions
    return 'I\'m here to help! Here are some things I can assist you with:\n\n'
        '📅 Making bookings\n'
        '❌ Cancellations & refunds\n'
        '🎁 Loyalty points & rewards\n'
        '💳 Payment methods\n'
        '🌹 Romantic add-ons\n'
        '🏷️ Coupons & offers\n'
        '🛡️ Safety & security\n'
        '📞 Contact support\n\n'
        'What would you like to know?';
  }

  // Helper method to check if message contains any of the keywords
  bool _containsAny(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  // Get suggested questions
  List<String> getSuggestedQuestions() {
    return [
      'How do I make a booking?',
      'What is your cancellation policy?',
      'How do loyalty points work?',
      'What romantic add-ons are available?',
      'Do you have any current offers?',
      'How can I contact support?',
      'What payment methods do you accept?',
      'Is my booking secure?',
    ];
  }

  // Get quick action buttons
  List<Map<String, String>> getQuickActions() {
    return [
      {'label': '📅 Make Booking', 'action': 'booking'},
      {'label': '🎁 View Offers', 'action': 'offers'},
      {'label': '💳 Loyalty Points', 'action': 'loyalty'},
      {'label': '📞 Contact Support', 'action': 'support'},
    ];
  }
}
