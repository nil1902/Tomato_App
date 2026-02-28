import 'dart:io';

/// Custom HTTP overrides for Windows to handle SSL and network issues
class WindowsHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // Increase timeout for Windows
    client.connectionTimeout = const Duration(seconds: 30);
    client.idleTimeout = const Duration(seconds: 30);
    
    // Allow bad certificates (for development with self-signed certs)
    // TODO: Remove in production and use proper certificate validation
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true; // Allow all certificates for now
    };
    
    // Set user agent to avoid blocking
    client.userAgent = 'LoveNest-Flutter-Windows/1.0';
    
    return client;
  }
}
