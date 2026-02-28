// Platform-specific payment service
// Uses Razorpay native SDK on mobile, web-compatible implementation on web
export 'payment_service_mobile.dart'
    if (dart.library.html) 'payment_service_web.dart';
