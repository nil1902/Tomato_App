import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lovenest/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  // Filter states
  RangeValues _priceRange = const RangeValues(100, 500);
  int _guestCount = 2;
  DateTimeRange? _selectedDateRange;
  Set<String> _selectedAmenities = {};
  
  bool _isSearching = false;
  
  final List<String> _recentSearches = [
    'Goa',
    'Private Villa in Bali',
    'Honeymoon Suites Paris'
  ];

  final List<Map<String, dynamic>> _dummyResults = [
    {
      'id': 'hotel_search_1',
      'name': 'The Lovina Resort',
      'location': 'Bali, Indonesia',
      'price': 150,
      'rating': 4.9,
      'imageUrl': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'isPrivacyAssured': true,
    },
    {
      'id': 'hotel_search_2',
      'name': 'Mountain Whisper Treehouse',
      'location': 'Aspen, Colorado',
      'price': 250,
      'rating': 4.8,
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'isPrivacyAssured': false,
    },
    {
      'id': 'hotel_search_3',
      'name': 'Grand Heritage Palace',
      'location': 'Udaipur, India',
      'price': 420,
      'rating': 4.7,
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'isPrivacyAssured': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
    // Request focus initially
    Future.microtask(() => _searchFocus.requestFocus());
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _showFilterPanel() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
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
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Date Range
                          Text('Dates', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                            title: Text(
                              _selectedDateRange == null 
                                  ? 'Select Check-in / Check-out' 
                                  : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                final DateTimeRange? picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: theme.colorScheme.copyWith(
                                          primary: AppColors.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  }
                                );
                                if (picked != null) {
                                  setModalState(() => _selectedDateRange = picked);
                                  setState(() => _selectedDateRange = picked);
                                }
                              },
                              child: const Text('Change', style: TextStyle(color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Guests
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Guests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (_guestCount > 1) {
                                        setModalState(() => _guestCount--);
                                        setState(() => _guestCount = _guestCount);
                                      }
                                    },
                                  ),
                                  Text('$_guestCount', style: theme.textTheme.titleMedium),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      if (_guestCount < 4) {
                                        setModalState(() => _guestCount++);
                                        setState(() => _guestCount = _guestCount);
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Price Range', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              Text('\$${_priceRange.start.round()} - \$${_priceRange.end.round()}+', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          RangeSlider(
                            values: _priceRange,
                            min: 50,
                            max: 1000,
                            divisions: 19,
                            activeColor: AppColors.primary,
                            labels: RangeLabels('\$${_priceRange.start.round()}', '\$${_priceRange.end.round()}'),
                            onChanged: (RangeValues values) {
                              setModalState(() => _priceRange = values);
                              setState(() => _priceRange = values);
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Amenities
                          Text('Romantic Amenities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Private Jacuzzi', 'Private Pool', 'Balcony', 'Fireplace', 'Canopy Bed', 'Couples Massage'
                            ].map((amenity) {
                              final isSelected = _selectedAmenities.contains(amenity);
                              return FilterChip(
                                label: Text(amenity),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                onSelected: (bool selected) {
                                  setModalState(() {
                                    if (selected) {
                                      _selectedAmenities.add(amenity);
                                    } else {
                                      _selectedAmenities.remove(amenity);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Show Results', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                       context.pop();
                    }
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          hintText: 'Where to next?',
                          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showFilterPanel,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isSearching ? _buildSearchResults(theme) : _buildRecentSearches(theme),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSearches(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text('Recent Searches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._recentSearches.map((search) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history, color: AppColors.textSecondary),
          title: Text(search, style: theme.textTheme.bodyMedium ?? const TextStyle()),
          trailing: const Icon(Icons.north_west, color: AppColors.textSecondary, size: 16),
          onTap: () {
            _searchController.text = search;
          },
        )),
        const SizedBox(height: 24),
        Text('Curated For Couples', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCuratedChip(theme, 'Hilltop Romance'),
            _buildCuratedChip(theme, 'Beach Escape'),
            _buildCuratedChip(theme, 'City Luxury'),
            _buildCuratedChip(theme, 'Budget Romantic'),
          ],
        ),
      ],
    );
  }

  Widget _buildCuratedChip(ThemeData theme, String label) {
    return InkWell(
      onTap: () {
        _searchController.text = label;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
        ),
        child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _dummyResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_dummyResults.length} properties found',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 18),
                  label: const Text('Sort'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
          );
        }
        
        final hotel = _dummyResults[index - 1];
        return _buildSearchResultCard(context, hotel);
      },
    );
  }

  Widget _buildSearchResultCard(BuildContext context, Map<String, dynamic> hotel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Hero(
                tag: 'hotel_image_${hotel['id']}',
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(hotel['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border, color: AppColors.primary, size: 20),
                        ),
                      ),
                      if (hotel['isPrivacyAssured'] == true)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Couples Love This',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hotel['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              hotel['rating'].toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel['location'],
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        const Icon(Icons.hot_tub, size: 16, color: AppColors.primary),
                        const Icon(Icons.pool, size: 16, color: AppColors.primary),
                        const Icon(Icons.spa, size: 16, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '\$${hotel['price']}',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
