import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/services/database_service.dart';
import 'dart:ui';

class HotelDetailsScreenModern extends StatefulWidget {
  final String hotelId;
  
  const HotelDetailsScreenModern({super.key, required this.hotelId});

  @override
  State<HotelDetailsScreenModern> createState() => _HotelDetailsScreenModernState();
}

class _HotelDetailsScreenModernState extends State<HotelDetailsScreenModern> {
  Map<String, dynamic>? _hotelData;
  List<dynamic> _rooms = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHotelDetails();
  }

  Future<void> _loadHotelDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.accessToken != null) {
      final databaseService = DatabaseService(authService.accessToken!);
      
      final hotel = await databaseService.getHotelDetails(widget.hotelId);
      final rooms = await databaseService.getRooms(widget.hotelId);
      
      setState(() {
        _hotelData = hotel;
        _rooms = rooms;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<String> _getHotelImages() {
    if (_hotelData != null && _hotelData!['images'] != null && _hotelData!['images'] is List) {
      return List<String>.from(_hotelData!['images']);
    }
    return ['https://images.unsplash.com/photo-1566073771259-6a8506099945'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_hotelData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hotel Details')),
        body: const Center(child: Text('Hotel not found')),
      );
    }

    final hotelName = _hotelData!['name'] ?? 'Hotel';
    final hotelCity = _hotelData!['city'] ?? 'Location';
    final hotelRating = (_hotelData!['couple_rating'] ?? 4.5).toDouble();
    final hotelPrice = _hotelData!['base_price'] ?? _hotelData!['price_per_night'] ?? 200;
    final hotelImages = _getHotelImages();
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Hero Image Section
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Main Image
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: hotelImages.length,
                        onPageChanged: (index) => setState(() => _selectedImageIndex = index),
                        itemBuilder: (context, index) {
                          return Image.network(
                            hotelImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.hotel, size: 80),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              isDark ? const Color(0xFF230F13).withOpacity(0.9) : const Color(0xFFF8F5F6).withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Top Actions
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(Icons.arrow_back, () => context.pop()),
                          Row(
                            children: [
                              _buildActionButton(Icons.share, () {}),
                              const SizedBox(width: 12),
                              _buildActionButton(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                () => setState(() => _isFavorite = !_isFavorite),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Hotel Info Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.volunteer_activism, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'COUPLE-FRIENDLY',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hotelRating.toStringAsFixed(1)} (2.1k)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              hotelName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '$hotelCity, ${_hotelData!['address'] ?? 'Private Island'}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Thumbnail Gallery
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotelImages.length.clamp(0, 4),
                    itemBuilder: (context, index) {
                      if (index == 3 && hotelImages.length > 4) {
                        return _buildMoreImagesThumb(hotelImages.length - 3, isDark);
                      }
                      return _buildImageThumb(hotelImages[index], index == _selectedImageIndex, isDark);
                    },
                  ),
                ),
              ),
              
              // Rating Bars
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      _buildRatingBar('Privacy Rating', 'Exceptional', 0.95, isDark),
                      const SizedBox(height: 20),
                      _buildRatingBar('Romance Factor', '10/10', 0.98, isDark),
                    ],
                  ),
                ),
              ),
              
              // Divider
              SliverToBoxAdapter(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300],
                ),
              ),
              
              // Amenities for Two
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amenities for Two',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _buildAmenityCard(Icons.pool, 'Private Pool', 'Secluded infinity edge', isDark),
                          _buildAmenityCard(Icons.restaurant, 'Private Dining', 'Beach candlelight', isDark),
                          _buildAmenityCard(Icons.spa, 'Couples Spa', 'In-villa treatments', isDark),
                          _buildAmenityCard(Icons.bathtub, 'Jacuzzi', 'Ocean facing', isDark),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View All Amenities', style: TextStyle(color: AppColors.primary)),
                            Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // About Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About the Resort',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hotelData!['description'] ?? 'Experience the ultimate romantic escape. Nestled on a private atoll, our resort is designed exclusively for couples seeking intimacy and luxury.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Location Preview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '20 mins by Seaplane',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(
                              height: 128,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Image.network(
                                'https://images.unsplash.com/photo-1524850011238-e3d235c7d4c9',
                                fit: BoxFit.cover,
                                color: Colors.grey,
                                colorBlendMode: BlendMode.saturation,
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[800] : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map, color: AppColors.primary, size: 16),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'View on Map',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1a0b0e).withOpacity(0.8) : Colors.white.withOpacity(0.8),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start from',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '\$$hotelPrice',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' / night',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/book/${widget.hotelId}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Select Room',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, {Color? color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: IconButton(
            icon: Icon(icon, color: color ?? Colors.white, size: 20),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumb(String imageUrl, bool isSelected, bool isDark) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
            ),
            if (!isSelected)
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreImagesThumb(int count, bool isDark) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(String title, String value, double progress, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  title.contains('Privacy') ? Icons.security : Icons.favorite,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityCard(IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
