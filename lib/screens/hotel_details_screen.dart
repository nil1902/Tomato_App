import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/services/database_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelDetailsScreen extends StatefulWidget {
  final String hotelId;
  final String? imageUrl;
  
  const HotelDetailsScreen({super.key, required this.hotelId, this.imageUrl});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _hotelData;
  List<dynamic> _rooms = [];
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  late TabController _tabController;
  int _selectedImageIndex = 0;

  final List<String> _categories = [
    'Overview',
    'Rooms',
    'Amenities',
    'Reviews',
    'Location',
    'Policies',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadHotelDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.accessToken != null) {
      final databaseService = DatabaseService(authService.accessToken!);
      
      final hotel = await databaseService.getHotelDetails(widget.hotelId);
      final rooms = await databaseService.getRooms(widget.hotelId);
      final reviews = await databaseService.getHotelReviews(widget.hotelId);
      
      setState(() {
        _hotelData = hotel;
        _rooms = rooms;
        _reviews = reviews;
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
    return [
      widget.imageUrl ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_hotelData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hotel Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Hotel not found', style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      );
    }

    final hotelName = _hotelData!['name'] ?? 'Hotel';
    final hotelCity = _hotelData!['city'] ?? 'Location';
    final hotelRating = (_hotelData!['couple_rating'] ?? 4.5).toDouble();
    final hotelPrice = _hotelData!['price_per_night'] ?? _hotelData!['starting_price'] ?? 200;
    final hotelImages = _getHotelImages();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: hotelImages.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'hotel_image_${widget.hotelId}',
                        child: CachedNetworkImage(
                          imageUrl: hotelImages[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedImageIndex + 1}/${hotelImages.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Hotel Info Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotelName,
                          style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              hotelRating.toStringAsFixed(1),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$hotelCity • ${_hotelData!['address'] ?? 'Address'}',
                          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildQuickStat(theme, Icons.hotel, '${_rooms.length} Rooms'),
                      const SizedBox(width: 16),
                      _buildQuickStat(theme, Icons.reviews, '${_reviews.length} Reviews'),
                      const SizedBox(width: 16),
                      _buildQuickStat(theme, Icons.verified, 'Verified'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Category Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: _categories.map((cat) => Tab(text: cat)).toList(),
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildRoomsTab(theme),
                _buildAmenitiesTab(theme),
                _buildReviewsTab(theme),
                _buildLocationTab(theme),
                _buildPoliciesTab(theme),
              ],
            ),
          ),
        ],
      ),

      // Bottom Booking Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Starting from', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  Row(
                    children: [
                      Text(
                        '\$$hotelPrice',
                        style: theme.textTheme.displayMedium?.copyWith(color: AppColors.primary, fontSize: 24),
                      ),
                      Text('/night', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 180,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/book/${widget.hotelId}'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Book Now'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Overview Tab
  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy Promise
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'LoveNest Privacy Promise',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPrivacyFeature(theme, 'Local IDs Accepted'),
                _buildPrivacyFeature(theme, 'No Irrelevant Questions'),
                _buildPrivacyFeature(theme, 'Secure & Private Check-in'),
                _buildPrivacyFeature(theme, 'Couple-Friendly Staff'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text('About This Nest', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            _hotelData!['description'] ?? 'Experience luxury and romance at this beautiful hotel. Perfect for couples seeking privacy and comfort.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 15),
          ),
          
          const SizedBox(height: 32),
          Text('Perfect For', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildOccasionChip(theme, '💑 Romantic Getaway'),
              _buildOccasionChip(theme, '🎂 Anniversary'),
              _buildOccasionChip(theme, '💍 Honeymoon'),
              _buildOccasionChip(theme, '🎉 Special Celebration'),
              _buildOccasionChip(theme, '🌙 Weekend Escape'),
            ],
          ),
          
          const SizedBox(height: 32),
          Text('Highlights', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildHighlight(theme, Icons.restaurant, 'In-Room Dining', 'Romantic meals delivered to your room'),
          _buildHighlight(theme, Icons.spa, 'Couple Spa', 'Relaxing spa treatments for two'),
          _buildHighlight(theme, Icons.pool, 'Private Pool', 'Exclusive pool access'),
          _buildHighlight(theme, Icons.local_bar, 'Rooftop Bar', 'Stunning city views'),
        ],
      ),
    );
  }

  Widget _buildPrivacyFeature(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildOccasionChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildHighlight(ThemeData theme, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Rooms Tab
  Widget _buildRoomsTab(ThemeData theme) {
    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No rooms available', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Check back later for availability', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return _buildRoomCard(theme, room);
      },
    );
  }

  Widget _buildRoomCard(ThemeData theme, Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: room['image_url'] ?? 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['name'] ?? 'Room',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  room['description'] ?? 'Comfortable room with modern amenities',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${room['capacity'] ?? 2} Guests', style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 16),
                    Icon(Icons.square_foot, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${room['size'] ?? 300} sq ft', style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        Text(
                          '\$${room['price'] ?? 200}/night',
                          style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/book/${widget.hotelId}'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Select Room'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Amenities Tab
  Widget _buildAmenitiesTab(ThemeData theme) {
    // final amenities = _hotelData!['amenities'] as Map<String, dynamic>? ?? {}; // Unused
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Room Features', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAmenityGrid(theme, [
            {'icon': Icons.wifi, 'name': 'Free WiFi'},
            {'icon': Icons.ac_unit, 'name': 'Air Conditioning'},
            {'icon': Icons.tv, 'name': 'Smart TV'},
            {'icon': Icons.coffee, 'name': 'Coffee Maker'},
            {'icon': Icons.bathtub, 'name': 'Bathtub'},
            {'icon': Icons.balcony, 'name': 'Balcony'},
          ]),
          
          const SizedBox(height: 32),
          Text('Hotel Facilities', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAmenityGrid(theme, [
            {'icon': Icons.pool, 'name': 'Swimming Pool'},
            {'icon': Icons.fitness_center, 'name': 'Fitness Center'},
            {'icon': Icons.spa, 'name': 'Spa & Wellness'},
            {'icon': Icons.restaurant, 'name': 'Restaurant'},
            {'icon': Icons.local_bar, 'name': 'Bar/Lounge'},
            {'icon': Icons.room_service, 'name': '24/7 Room Service'},
          ]),
          
          const SizedBox(height: 32),
          Text('Services', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAmenityGrid(theme, [
            {'icon': Icons.local_parking, 'name': 'Free Parking'},
            {'icon': Icons.airport_shuttle, 'name': 'Airport Shuttle'},
            {'icon': Icons.support_agent, 'name': 'Concierge'},
            {'icon': Icons.luggage, 'name': 'Luggage Storage'},
            {'icon': Icons.dry_cleaning, 'name': 'Laundry Service'},
            {'icon': Icons.security, 'name': '24/7 Security'},
          ]),
        ],
      ),
    );
  }

  Widget _buildAmenityGrid(ThemeData theme, List<Map<String, dynamic>> amenities) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(amenity['icon'] as IconData, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                amenity['name'] as String,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // Reviews Tab
  Widget _buildReviewsTab(ThemeData theme) {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No reviews yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Be the first to review!', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(theme, review);
      },
    );
  }

  Widget _buildReviewCard(ThemeData theme, Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (review['user_name'] ?? 'U')[0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user_name'] ?? 'Anonymous',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (review['overall_rating'] ?? 5) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              if (review['verified_stay'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text('Verified', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? 'Great stay!',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (review['occasion'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Occasion: ${review['occasion']}',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  // Location Tab
  Widget _buildLocationTab(ThemeData theme) {
    final lat = (_hotelData!['lat'] as num?)?.toDouble() ?? 40.7128;
    final lng = (_hotelData!['lng'] as num?)?.toDouble() ?? -74.0060;
    final LatLng hotelLocation = LatLng(lat, lng);
    final isDesktop = !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: isDesktop
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Map View (Desktop)', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Use Android/iOS device to view the actual Google Map', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(target: hotelLocation, zoom: 15),
                    markers: {
                      Marker(
                        markerId: MarkerId('hotel_${widget.hotelId}'),
                        position: hotelLocation,
                        infoWindow: InfoWindow(
                          title: _hotelData!['name'] ?? 'Hotel',
                          snippet: _hotelData!['address'] ?? 'Hotel Address',
                        ),
                      ),
                    },
                    myLocationEnabled: false,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                  ),
          ),
          
          const SizedBox(height: 24),
          Text('Address', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _hotelData!['address'] ?? 'Address not available',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Text('Nearby Attractions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildNearbyPlace(theme, '🏛️ City Museum', '0.5 km'),
          _buildNearbyPlace(theme, '🍽️ Fine Dining District', '0.8 km'),
          _buildNearbyPlace(theme, '🎭 Theater District', '1.2 km'),
          _buildNearbyPlace(theme, '🛍️ Shopping Mall', '1.5 km'),
          _buildNearbyPlace(theme, '🌳 Central Park', '2.0 km'),
        ],
      ),
    );
  }

  Widget _buildNearbyPlace(ThemeData theme, String name, String distance) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.place, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: theme.textTheme.bodyLarge),
          ),
          Text(distance, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // Policies Tab
  Widget _buildPoliciesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Check-in & Check-out', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPolicyItem(theme, Icons.login, 'Check-in', '2:00 PM onwards'),
          _buildPolicyItem(theme, Icons.logout, 'Check-out', '11:00 AM'),
          
          const SizedBox(height: 32),
          Text('Cancellation Policy', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPolicyItem(theme, Icons.cancel, 'Free Cancellation', 'Up to 24 hours before check-in'),
          _buildPolicyItem(theme, Icons.money_off, 'Partial Refund', '50% refund within 24 hours'),
          _buildPolicyItem(theme, Icons.block, 'No Refund', 'After check-in time'),
          
          const SizedBox(height: 32),
          Text('House Rules', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPolicyItem(theme, Icons.no_photography, 'No Smoking', 'Smoking is not allowed'),
          _buildPolicyItem(theme, Icons.pets, 'Pets Allowed', 'Small pets welcome'),
          _buildPolicyItem(theme, Icons.child_care, 'Children Welcome', 'All ages welcome'),
          _buildPolicyItem(theme, Icons.celebration, 'Parties', 'No loud parties after 10 PM'),
          
          const SizedBox(height: 32),
          Text('Payment Methods', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPolicyItem(theme, Icons.credit_card, 'Credit/Debit Cards', 'All major cards accepted'),
          _buildPolicyItem(theme, Icons.account_balance_wallet, 'Digital Wallets', 'UPI, PayPal, etc.'),
          _buildPolicyItem(theme, Icons.money, 'Cash', 'Cash payment at property'),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(ThemeData theme, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tab Bar Delegate for Sticky Tabs
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
