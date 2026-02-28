import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<Map<String, dynamic>> _wishlist = [
    {
      'id': 'hotel_101',
      'name': 'The Lovina Resort',
      'location': 'Bali, Indonesia',
      'price': 150,
      'rating': 4.9,
      'imageUrl': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
    },
    {
      'id': 'hotel_102',
      'name': 'Grand Heritage Palace',
      'location': 'Udaipur, India',
      'price': 420,
      'rating': 4.7,
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Nests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist shared with partner! 💖')),
              );
            },
          ),
        ],
      ),
      body: _wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No saved nests yet',
                    style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wishlist.length,
              itemBuilder: (context, index) {
                final hotel = _wishlist[index];
                return _buildWishlistCard(context, hotel, isDark);
              },
            ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, Map<String, dynamic> hotel, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/hotel/${hotel['id']}', extra: hotel['imageUrl']);
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Hero(
                  tag: 'hotel_image_${hotel['id']}',
                  child: CachedNetworkImage(
                    imageUrl: hotel['imageUrl'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              hotel['name'],
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.favorite, color: AppColors.primary, size: 20),
                            onPressed: () {
                              setState(() {
                                _wishlist.removeWhere((item) => item['id'] == hotel['id']);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel['location'],
                              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\$${hotel['price']}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('/night', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text('${hotel['rating']}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
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
}
