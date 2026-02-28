import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lovenest/services/auth_service.dart';
import 'package:lovenest/services/database_service.dart';
import 'package:lovenest/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _hotels = [];
  bool _isLoading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadHotels();
    _loadUnreadNotifications();
  }

  Future<void> _loadHotels() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.accessToken != null) {
      final databaseService = DatabaseService(authService.accessToken!);
      final hotels = await databaseService.getHotels();
      setState(() {
        _hotels = hotels;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      final notificationService = NotificationService();
      final count = await notificationService.getUnreadCount(currentUser['id']);
      setState(() {
        _unreadNotifications = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'New York, USA',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push('/notifications');
                            setState(() => _unreadNotifications = 0);
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                              ),
                              if (_unreadNotifications > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Hero(
                            tag: 'avatar_image',
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                image: currentUser?['avatar_url'] != null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(currentUser!['avatar_url']),
                                        fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: CachedNetworkImageProvider('https://i.pravatar.cc/150?img=11'),
                                      ),
                              ),
                              child: currentUser?['avatar_url'] == null
                                  ? const Icon(Icons.person, color: AppColors.textSecondary)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () => context.push('/search'),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search hotels, cities...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showFilterBottomSheet(context);
                        },
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      _buildCategoryChip(theme, 'Couple Friendly ❤️', true),
                      _buildCategoryChip(theme, 'Privacy Assured 🔒', false),
                      _buildCategoryChip(theme, 'Romantic', false),
                      _buildCategoryChip(theme, 'Popular', false),
                      _buildCategoryChip(theme, 'Local ID Accepted', false),
                    ],
                  ),
                ),
              ),
            ),

            // Featured Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Romantic Getaways',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal ListView for Featured Hotels (Using SliverToBoxAdapter + ListView)
            if (_isLoading)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else if (_hotels.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No hotels available',
                          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for romantic getaways',
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _hotels.length > 5 ? 5 : _hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = _hotels[index];
                      return _buildHotelCard(
                        context,
                        id: hotel['id']?.toString() ?? 'hotel_$index',
                        name: hotel['name']?.toString() ?? 'Hotel Name',
                        location: hotel['city']?.toString() ?? 'Location',
                        price: (hotel['price_per_night'] ?? hotel['starting_price'] ?? 200).toInt(),
                        rating: (hotel['couple_rating'] ?? hotel['star_rating'] ?? 4.5).toDouble(),
                        isPrivacyAssured: hotel['privacy_assured'] ?? true,
                        imageUrl: _getHotelImage(hotel),
                      );
                    },
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
             context.push('/search');
          } else if (index == 2) {
             context.push('/bookings');
          } else if (index == 3) {
             context.push('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Nests'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(
    BuildContext context, {
    required String id,
    required String name,
    required String location,
    required int price,
    required double rating,
    required String imageUrl,
    bool isPrivacyAssured = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            context.push('/hotel/$id', extra: imageUrl);
          },
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Hero(
              tag: 'hotel_image_$id',
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: AppColors.primary, size: 20),
                    ),
                  ),
                  if (isPrivacyAssured)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Privacy Assured',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
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
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\$$price',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/night',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Price Range', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              // Dummy slider visual
              Row(
                children: [
                   Text('\$50', style: theme.textTheme.bodyMedium),
                   Expanded(child: Slider(value: 150, min: 50, max: 500, activeColor: AppColors.primary, onChanged: (v){})),
                   Text('\$500+', style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 24),
              Text('Amenities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterChip(theme, 'Free WiFi', true),
                  _buildFilterChip(theme, 'Pool', false),
                  _buildFilterChip(theme, 'Spa', false),
                  _buildFilterChip(theme, 'Gym', true),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  String _getHotelImage(Map<String, dynamic> hotel) {
    // Try to get image from images array
    if (hotel['images'] != null && hotel['images'] is List && (hotel['images'] as List).isNotEmpty) {
      return hotel['images'][0];
    }
    
    // Try to get image from image_url field
    if (hotel['image_url'] != null) {
      return hotel['image_url'].toString();
    }
    
    // Fallback to default images based on index
    final index = _hotels.indexOf(hotel) % 3;
    return [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    ][index];
  }
}
